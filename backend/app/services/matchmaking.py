"""服装/摄影撮合服务。

Tasks 17.1-17.3: 根据用户位置和偏好（类别、朝代标签），检索附近的
汉服租赁 / 古风摄影商家，并按综合评分（距离 40% + 评分 30% + 朝代匹配 30%）排序。
"""

from __future__ import annotations

import math
from typing import Sequence

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.merchant import Merchant

import structlog

logger = structlog.get_logger()


class MatchmakingService:
    """服装/摄影撮合服务"""

    # Weights for the composite scoring formula
    WEIGHT_DISTANCE: float = 0.4
    WEIGHT_RATING: float = 0.3
    WEIGHT_DYNASTY: float = 0.3
    # Distance normalisation denominator (km)
    MAX_DISTANCE_KM: float = 50.0

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    async def get_nearby_merchants(
        self,
        latitude: float,
        longitude: float,
        radius_km: float = 50.0,
        category: str | None = None,
        dynasty_tags: list[str] | None = None,
        limit: int = 10,
    ) -> Sequence[Merchant]:
        """Find nearby merchants sorted by composite score.

        The query first applies a coarse bounding-box filter in SQL
        (approx ±1 degree ≈ 111 km) to keep the result set manageable,
        then refines with the Haversine formula and ranks by a weighted
        composite of distance, rating, and dynasty-tag overlap.
        """
        # Coarse bounding-box filter (≈ ±1 degree)
        lat_lo, lat_hi = latitude - 1, latitude + 1
        lon_lo, lon_hi = longitude - 1, longitude + 1

        stmt = select(Merchant).where(
            Merchant.is_active.is_(True),
            Merchant.latitude.between(lat_lo, lat_hi),
            Merchant.longitude.between(lon_lo, lon_hi),
        )

        if category:
            stmt = stmt.where(Merchant.category == category)

        result = await self.db.execute(stmt)
        merchants = list(result.scalars().all())

        # Annotate each merchant with its actual distance
        for m in merchants:
            m._distance = self._haversine(
                latitude, longitude, m.latitude, m.longitude
            )

        # Discard merchants beyond the requested radius
        merchants = [m for m in merchants if m._distance <= radius_km]

        # Rank by composite score (descending – we negate for sort)
        merchants.sort(key=lambda m: self._composite_score(m, dynasty_tags))

        logger.info(
            "matchmaking_search",
            lat=latitude,
            lon=longitude,
            radius_km=radius_km,
            category=category,
            dynasty_tags=dynasty_tags,
            results=len(merchants[:limit]),
        )

        return merchants[:limit]

    # ------------------------------------------------------------------
    # Scoring helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Return the great-circle distance in kilometres between two points."""
        R = 6371.0  # Earth radius in km
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (
            math.sin(dlat / 2) ** 2
            + math.cos(math.radians(lat1))
            * math.cos(math.radians(lat2))
            * math.sin(dlon / 2) ** 2
        )
        return R * 2 * math.asin(math.sqrt(a))

    def _composite_score(
        self,
        merchant: Merchant,
        dynasty_tags: list[str] | None,
    ) -> float:
        """Return the *negated* composite score suitable for ascending sort.

        Components:
          dist_score   = max(0, 1 − distance / MAX_DISTANCE_KM)   [0..1]
          rating_score = rating / 5.0                               [0..1]
          dynasty_score = |overlap| / |user_tags|                   [0..1]

        Higher is better, so we return the negative value so that
        ``list.sort(key=…)`` places the best match first.
        """
        dist_score = max(0.0, 1.0 - getattr(merchant, "_distance", 0) / self.MAX_DISTANCE_KM)
        rating_score = (merchant.rating or 0.0) / 5.0

        dynasty_score = 0.0
        if dynasty_tags and merchant.dynasty_tags:
            overlap = set(dynasty_tags) & set(merchant.dynasty_tags)
            dynasty_score = len(overlap) / len(dynasty_tags)

        return -(
            dist_score * self.WEIGHT_DISTANCE
            + rating_score * self.WEIGHT_RATING
            + dynasty_score * self.WEIGHT_DYNASTY
        )
