"""Image generation API routes - AI-powered historical image creation."""

from __future__ import annotations

import asyncio
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, WebSocket, WebSocketDisconnect
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.database import get_db
from app.models.trip import GeneratedImage

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class ImageGenerateResponse(BaseModel):
    """Response after submitting an image generation task."""

    task_id: str
    status: str = "pending"
    message: str = "Task submitted successfully"


class ImageStatusResponse(BaseModel):
    """Current status of an image generation task."""

    task_id: str
    status: str  # pending / processing / completed / failed
    original_image_url: str | None = None
    generated_image_url: str | None = None
    progress: int = Field(0, ge=0, le=100, description="Percentage complete")
    error_message: str | None = None
    created_at: datetime | None = None


# ---------------------------------------------------------------------------
# In-memory progress tracker (for WebSocket updates)
# ---------------------------------------------------------------------------

_progress_store: dict[str, int] = {}


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/generate", response_model=ImageGenerateResponse, status_code=202)
async def generate_image(
    photo: UploadFile = File(..., description="User-uploaded photo"),
    role_type: str = Form("traveler", description="Character role, e.g. traveler, guide"),
    style: str = Form("ink_wash", description="Art style: ink_wash / gongbi"),
    dynasty: str | None = Form(None, description="Target dynasty for costume / scenery"),
    prompt: str | None = Form(None, description="Additional generation prompt"),
    db: AsyncSession = Depends(get_db),
) -> ImageGenerateResponse:
    """Submit an image generation task.

    Accepts a multipart upload containing the user's photo along with style
    and role parameters.  Returns a task ID that can be polled via the status
    endpoint or monitored in real-time through the WebSocket endpoint.
    """
    # Validate file type
    if photo.content_type and photo.content_type not in (
        "image/jpeg",
        "image/png",
        "image/webp",
    ):
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported image format: {photo.content_type}. "
            "Use JPEG, PNG, or WebP.",
        )

    task_id = str(uuid.uuid4())

    # Save placeholder to database
    image_record = GeneratedImage(
        original_image_url=f"pending://{task_id}",
        role_type=role_type,
        prompt=prompt or f"style={style}, dynasty={dynasty}",
        status="pending",
        task_id=task_id,
    )
    db.add(image_record)
    await db.flush()

    _progress_store[task_id] = 0

    # TODO: Dispatch actual generation task to background worker / GPU service
    # e.g. await image_generation_queue.enqueue(task_id, photo_bytes, ...)

    return ImageGenerateResponse(
        task_id=task_id,
        status="pending",
        message="Image generation task submitted. Poll /status or connect via WebSocket.",
    )


@router.get("/{task_id}/status", response_model=ImageStatusResponse)
async def get_image_status(
    task_id: str,
    db: AsyncSession = Depends(get_db),
) -> ImageStatusResponse:
    """Get the current status of an image generation task."""
    stmt = select(GeneratedImage).where(GeneratedImage.task_id == task_id)
    result = await db.execute(stmt)
    record = result.scalar_one_or_none()

    if record is None:
        raise HTTPException(status_code=404, detail=f"Task {task_id} not found")

    progress = _progress_store.get(task_id, 0)
    if record.status == "completed":
        progress = 100
    elif record.status == "failed":
        progress = 0

    return ImageStatusResponse(
        task_id=task_id,
        status=record.status,
        original_image_url=(
            record.original_image_url
            if not record.original_image_url.startswith("pending://")
            else None
        ),
        generated_image_url=record.generated_image_url,
        progress=progress,
        created_at=record.created_at,
    )


@router.websocket("/{task_id}/ws")
async def image_progress_ws(websocket: WebSocket, task_id: str) -> None:
    """WebSocket endpoint for real-time image generation progress updates.

    The server pushes progress messages as JSON with the shape
    ``{"task_id": ..., "progress": 0-100, "status": "..."}`` until the task
    reaches a terminal state (completed / failed).
    """
    await websocket.accept()

    try:
        # Verify task exists
        last_progress = -1
        while True:
            progress = _progress_store.get(task_id, 0)

            if progress != last_progress:
                await websocket.send_json({
                    "task_id": task_id,
                    "progress": progress,
                    "status": "processing",
                })
                last_progress = progress

            # Check for terminal states
            if progress >= 100:
                await websocket.send_json({
                    "task_id": task_id,
                    "progress": 100,
                    "status": "completed",
                })
                break

            await asyncio.sleep(0.5)

    except WebSocketDisconnect:
        pass
    except Exception:
        try:
            await websocket.send_json({
                "task_id": task_id,
                "progress": 0,
                "status": "failed",
                "error": "Unexpected error during progress streaming",
            })
        except Exception:
            pass
    finally:
        try:
            await websocket.close()
        except Exception:
            pass
