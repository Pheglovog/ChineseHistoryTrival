"""地理围栏服务 - 使用 Redis GEO 命令实现历史遗址邻近检测。

Tasks 16.1-16.6: 基于 Redis GEOADD / GEOSEARCH 实现地理围栏，
按汉代行政区划（州/郡/县）分级检测用户位置，并生成古典文言风格推送通知。
"""

from __future__ import annotations

import redis.asyncio as redis
from app.config import settings
import structlog

logger = structlog.get_logger()


class GeofenceService:
    """地理围栏服务 - 使用 Redis GEO 命令"""

    GEOFENCE_RADII: dict[str, int] = {
        "zhou": 50000,  # 50km  — 州级
        "jun": 20000,   # 20km  — 郡级
        "xian": 5000,   # 5km   — 县级
    }
    NOTIFICATION_KEY_PREFIX = "geofence:notif:"

    def __init__(self) -> None:
        self.redis: redis.Redis | None = None

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    async def connect(self) -> None:
        """Initialize the Redis connection pool."""
        self.redis = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,
        )
        logger.info("geofence_service_connected")

    async def close(self) -> None:
        """Gracefully close the Redis connection."""
        if self.redis:
            await self.redis.close()
            self.redis = None
            logger.info("geofence_service_disconnected")

    # ------------------------------------------------------------------
    # Data loading
    # ------------------------------------------------------------------

    async def load_locations(self, locations: list[dict]) -> None:
        """Load all historical location coordinates into Redis GEO sorted sets.

        Each *locations* item is expected to have the keys:
            id, name, admin_level, latitude, longitude

        The data is stored under keys ``geofence:<admin_level>`` so that
        each administrative level gets its own GEO set for radius queries.
        """
        if not self.redis:
            raise RuntimeError("Redis connection not initialised – call connect() first")

        pipe = self.redis.pipeline()
        for loc in locations:
            key = f"geofence:{loc['admin_level']}"
            pipe.geoadd(
                key,
                (float(loc["longitude"]), float(loc["latitude"]), str(loc["id"])),
            )
        await pipe.execute()
        logger.info(
            "geofence_locations_loaded",
            count=len(locations),
            levels=list({loc["admin_level"] for loc in locations}),
        )

    # ------------------------------------------------------------------
    # Geofence check
    # ------------------------------------------------------------------

    async def check_geofence(
        self,
        latitude: float,
        longitude: float,
        user_id: str,
    ) -> list[dict]:
        """Check whether the given position falls within any geofence.

        Returns a list of dicts with keys:
            location_id, admin_level, distance, coordinates

        A 24-hour dedup mechanism prevents the same user from receiving
        repeated notifications for the same location within a day.
        """
        if not self.redis:
            raise RuntimeError("Redis connection not initialised – call connect() first")

        results: list[dict] = []

        for level, radius in self.GEOFENCE_RADII.items():
            key = f"geofence:{level}"
            nearby = await self.redis.geosearch(
                key,
                longitude=float(longitude),
                latitude=float(latitude),
                unit="m",
                radius=radius,
                withdist=True,
                withcoord=True,
            )

            for item in nearby:
                location_id = item[0]
                distance = item[1]
                coords = item[2]

                # 24-hour dedup: skip if we already notified this user for
                # this location within the last 24 hours.
                dedup_key = f"{self.NOTIFICATION_KEY_PREFIX}{user_id}:{location_id}"
                if await self.redis.exists(dedup_key):
                    continue

                results.append(
                    {
                        "location_id": location_id,
                        "admin_level": level,
                        "distance": distance,
                        "coordinates": coords,
                    }
                )
                # Mark as notified – TTL = 86 400 s (24 h)
                await self.redis.setex(dedup_key, 86400, "1")

        if results:
            logger.info(
                "geofence_hits",
                user_id=user_id,
                hit_count=len(results),
            )

        return results

    # ------------------------------------------------------------------
    # Notification generation
    # ------------------------------------------------------------------

    async def generate_notification_content(
        self,
        location_name: str,
        admin_level: str,
        llm_service,
    ) -> str:
        """Use an LLM to generate classical Chinese style notification text.

        Parameters
        ----------
        location_name:
            The historical name of the nearby location.
        admin_level:
            Administrative level (zhou / jun / xian).
        llm_service:
            Any object exposing ``ainvoke(prompt) -> AIMessage`` (e.g. a
            LangChain ``BaseChatModel`` instance).

        Returns
        -------
        str
            Classical Chinese push notification text (<= 50 chars).
        """
        level_map = {"zhou": "州", "jun": "郡", "xian": "县"}
        level_cn = level_map.get(admin_level, admin_level)

        prompt = (
            f"你是一个中国古代历史专家。用户正在靠近汉代{level_cn}级地点"
            f"\u201c{location_name}\u201d的遗址。\n"
            "请用古典文言风格写一条简短的推送通知（不超过50字），描述此地历史意义。"
            "格式要求：开头用一个吸引人的称呼。"
        )

        try:
            response = await llm_service.ainvoke(prompt)
            content = response.content
            logger.info(
                "geofence_notification_generated",
                location_name=location_name,
                admin_level=admin_level,
            )
            return content
        except Exception:
            logger.exception(
                "geofence_notification_failed",
                location_name=location_name,
                admin_level=admin_level,
            )
            # Fallback static text so the caller can still function
            return (
                f"旅人止步——前方即{level_cn}\u201c{location_name}\u201d故地，"
                "千年风华犹在脚下，何不驻足一览？"
            )
