"""AI换装与历史场景生成服务。

Tasks 18.1-18.8: 接收用户照片 + 角色类型，通过 Stable Diffusion
（IP-Adapter + ControlNet）生成汉服/古风形象，使用 Redis 队列管理异步任务。
"""

from __future__ import annotations

import json
from typing import Any

import httpx
import redis.asyncio as redis

from app.config import settings
import structlog

logger = structlog.get_logger()


class ImageGenerationService:
    """AI换装与历史场景生成服务"""

    # Historical character role prompt library
    ROLE_PROMPTS: dict[str, str] = {
        "emperor": (
            "Emperor of Han Dynasty, wearing golden dragon robe with jade crown, "
            "sitting on throne in Weiyang Palace"
        ),
        "minister": (
            "Han Dynasty civil official, wearing dark blue official robe with jade belt, "
            "standing in court"
        ),
        "general": (
            "Han Dynasty military general, wearing armor with red cape, "
            "holding sword on battlefield"
        ),
        "maid": (
            "Han Dynasty palace maid, wearing light silk ruqun in pastel colors, "
            "in imperial garden"
        ),
        "eunuch": (
            "Han Dynasty court eunuch, wearing dark official attire, "
            "in palace hallway"
        ),
        "scholar": (
            "Han Dynasty scholar, wearing white linen robes, "
            "reading bamboo slips in study"
        ),
    }

    # Redis key prefixes / queue name
    TASK_KEY_PREFIX = "image_task:"
    QUEUE_NAME = "image_generation_queue"

    def __init__(self) -> None:
        self.client: httpx.AsyncClient = httpx.AsyncClient(timeout=120.0)
        self.redis: redis.Redis | None = None

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    async def connect_redis(self) -> None:
        """Initialise the Redis connection used for task queuing."""
        self.redis = redis.from_url(
            settings.REDIS_URL,
            decode_responses=True,
        )
        logger.info("image_gen_service_connected")

    async def close(self) -> None:
        """Gracefully shut down HTTP client and Redis connection."""
        await self.client.aclose()
        if self.redis:
            await self.redis.close()
            self.redis = None
        logger.info("image_gen_service_disconnected")

    # ------------------------------------------------------------------
    # Task submission
    # ------------------------------------------------------------------

    async def submit_generation_task(
        self,
        task_id: str,
        original_image_url: str,
        role_type: str,
        scene: str | None = None,
        user_id: str | None = None,
    ) -> dict[str, Any]:
        """Submit an AI image generation task to the Redis queue.

        Parameters
        ----------
        task_id:
            Unique identifier for this generation task (typically a UUID).
        original_image_url:
            URL of the user-uploaded photo to transform.
        role_type:
            One of the keys in :attr:`ROLE_PROMPTS`.
        scene:
            Optional textual scene description to append to the prompt.
        user_id:
            Optional user identifier for tracking / analytics.

        Returns
        -------
        dict
            ``{"task_id": ..., "status": "queued"}``
        """
        if not self.redis:
            raise RuntimeError("Redis not initialised – call connect_redis() first")

        role_prompt = self.ROLE_PROMPTS.get(role_type, self.ROLE_PROMPTS["scholar"])

        prompt = (
            f"{role_prompt}, {scene or 'in traditional Han Dynasty setting'}, "
            "ultra detailed, high quality, professional photography style, "
            "maintaining facial features of the original person"
        )
        negative_prompt = "low quality, blurry, deformed, ugly, bad anatomy"

        task_data: dict[str, Any] = {
            "task_id": task_id,
            "original_image_url": original_image_url,
            "prompt": prompt,
            "negative_prompt": negative_prompt,
            "role_type": role_type,
            "user_id": user_id,
        }

        # Enqueue for worker processing
        await self.redis.lpush(self.QUEUE_NAME, json.dumps(task_data))
        # Immediately record initial status so clients can poll
        await self.redis.set(
            f"{self.TASK_KEY_PREFIX}{task_id}",
            json.dumps({"status": "queued"}),
        )

        logger.info(
            "image_gen_task_submitted",
            task_id=task_id,
            role_type=role_type,
            user_id=user_id,
        )

        return {"task_id": task_id, "status": "queued"}

    # ------------------------------------------------------------------
    # Status polling
    # ------------------------------------------------------------------

    async def get_task_status(self, task_id: str) -> dict[str, Any]:
        """Return the current status dict for *task_id*.

        Possible ``status`` values:
            ``queued`` | ``processing`` | ``completed`` | ``failed`` | ``not_found``
        """
        if not self.redis:
            raise RuntimeError("Redis not initialised – call connect_redis() first")

        data = await self.redis.get(f"{self.TASK_KEY_PREFIX}{task_id}")
        if not data:
            return {"status": "not_found"}
        return json.loads(data)

    # ------------------------------------------------------------------
    # Worker processing
    # ------------------------------------------------------------------

    async def process_task(self, task_data: dict[str, Any]) -> dict[str, Any]:
        """Process a single image generation task (called by background worker).

        Calls the Stable Diffusion WebUI ``/sdapi/v1/img2img`` endpoint with
        the compiled prompt and the user's original image.  Progress and
        results are persisted in Redis for the client to poll.

        Returns
        -------
        dict
            Result dict containing at least ``task_id``, ``status``, and
            (on success) ``image_url``.
        """
        if not self.redis:
            raise RuntimeError("Redis not initialised – call connect_redis() first")

        task_id = task_data["task_id"]
        task_key = f"{self.TASK_KEY_PREFIX}{task_id}"

        try:
            # Mark as processing
            await self.redis.set(
                task_key,
                json.dumps({"status": "processing", "progress": 0}),
            )

            logger.info("image_gen_processing", task_id=task_id)

            # Call Stable Diffusion API (IP-Adapter + ControlNet)
            response = await self.client.post(
                f"{settings.SD_API_URL}/sdapi/v1/img2img",
                json={
                    "init_images": [task_data["original_image_url"]],
                    "prompt": task_data["prompt"],
                    "negative_prompt": task_data["negative_prompt"],
                    "width": 512,
                    "height": 768,
                    "steps": 30,
                    "cfg_scale": 7,
                    "sampler_name": "DPM++ 2M Karras",
                    "override_settings": {
                        "sd_model_checkpoint": "sd_xl_base_1.0",
                    },
                },
            )

            if response.status_code == 200:
                result = response.json()
                image_url: str | None = result.get("images", [None])[0]

                result_data: dict[str, Any] = {
                    "status": "completed",
                    "image_url": image_url,
                    "task_id": task_id,
                }
                await self.redis.set(task_key, json.dumps(result_data))

                logger.info(
                    "image_gen_completed",
                    task_id=task_id,
                    has_image=image_url is not None,
                )
                return result_data

            # Non-200 response from SD API
            error_msg = (
                f"SD API returned HTTP {response.status_code}: "
                f"{response.text[:200]}"
            )
            raise Exception(error_msg)

        except Exception as exc:
            logger.exception(
                "image_generation_failed",
                task_id=task_id,
                error=str(exc),
            )
            error_data: dict[str, Any] = {
                "status": "failed",
                "error": str(exc),
                "task_id": task_id,
            }
            await self.redis.set(task_key, json.dumps(error_data))
            return error_data
