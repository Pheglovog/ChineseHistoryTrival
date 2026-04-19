"""Summary API routes - trip summary generation and video export."""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.database import get_db
from app.models.trip import TripPlan, TripSummary

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class SummaryGenerateRequest(BaseModel):
    """Request body for generating a trip summary."""

    trip_id: int = Field(..., gt=0)
    style: str = Field(
        "ink_wash",
        description="Visual style for generated assets: ink_wash / gongbi",
    )
    include_images: bool = Field(True, description="Whether to generate summary images")
    include_video: bool = Field(False, description="Whether to generate a summary video")


class SummaryItem(BaseModel):
    """A generated trip summary."""

    id: int
    trip_id: int
    content: str | None = None
    images: list[str] | None = None
    video_url: str | None = None
    style: str | None = None
    status: str  # generating / completed / failed
    created_at: datetime | None = None


class SummaryGenerateResponse(BaseModel):
    """Response after submitting a summary generation task."""

    summary_id: int
    trip_id: int
    status: str
    message: str


class VideoResponse(BaseModel):
    """Response containing the summary video URL."""

    summary_id: int
    trip_id: int
    video_url: str | None = None
    status: str


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/generate", response_model=SummaryGenerateResponse, status_code=202)
async def generate_summary(
    request: SummaryGenerateRequest,
    db: AsyncSession = Depends(get_db),
) -> SummaryGenerateResponse:
    """Generate a trip summary.

    Creates a textual summary of the trip, optionally with styled images and
    a video montage.  This is an async operation; poll the status via the
    ``GET /summary/{summary_id}`` endpoint.
    """
    # Verify trip exists
    stmt = select(TripPlan).where(TripPlan.id == request.trip_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Trip {request.trip_id} not found")

    # Create or update summary record
    existing_stmt = select(TripSummary).where(
        TripSummary.trip_plan_id == request.trip_id
    )
    existing = (await db.execute(existing_stmt)).scalar_one_or_none()

    if existing is not None:
        existing.status = "generating"
        existing.style = request.style
        summary = existing
    else:
        summary = TripSummary(
            trip_plan_id=request.trip_id,
            style=request.style,
            status="generating",
        )
        db.add(summary)

    await db.flush()

    # TODO: Dispatch summary generation to background worker
    # Steps:
    #   1. Generate textual summary via LLM
    #   2. Generate styled images if include_images=True
    #   3. Generate video montage if include_video=True
    #   4. Update summary record with results

    return SummaryGenerateResponse(
        summary_id=summary.id,
        trip_id=request.trip_id,
        status=summary.status,
        message="Summary generation started. Poll status via GET endpoint.",
    )


@router.get("/{summary_id}", response_model=SummaryItem)
async def get_summary(
    summary_id: int,
    db: AsyncSession = Depends(get_db),
) -> SummaryItem:
    """Retrieve a generated trip summary by its ID."""
    stmt = select(TripSummary).where(TripSummary.id == summary_id)
    result = await db.execute(stmt)
    summary = result.scalar_one_or_none()

    if summary is None:
        raise HTTPException(status_code=404, detail=f"Summary {summary_id} not found")

    return SummaryItem(
        id=summary.id,
        trip_id=summary.trip_plan_id,
        content=summary.content,
        images=summary.images,
        video_url=summary.video_url,
        style=summary.style,
        status=summary.status,
        created_at=summary.created_at,
    )


@router.get("/{summary_id}/video", response_model=VideoResponse)
async def get_summary_video(
    summary_id: int,
    db: AsyncSession = Depends(get_db),
) -> VideoResponse:
    """Get the video associated with a trip summary.

    Returns the video URL if generation is complete, or the current status
    if still processing.
    """
    stmt = select(TripSummary).where(TripSummary.id == summary_id)
    result = await db.execute(stmt)
    summary = result.scalar_one_or_none()

    if summary is None:
        raise HTTPException(status_code=404, detail=f"Summary {summary_id} not found")

    if summary.status == "generating":
        raise HTTPException(
            status_code=202,
            detail="Video is still being generated. Please try again later.",
        )

    if summary.status == "failed":
        raise HTTPException(
            status_code=500,
            detail="Summary generation failed. Please retry.",
        )

    return VideoResponse(
        summary_id=summary.id,
        trip_id=summary.trip_plan_id,
        video_url=summary.video_url,
        status=summary.status,
    )
