"""Historical route planning API routes."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.database import get_db
from app.models.trip import TripPlan, TripStop

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class RouteStop(BaseModel):
    """A single stop on a historical route."""

    ancient_name: str
    modern_name: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    day_number: int
    order: int
    description: str | None = None
    stop_type: str = "sightseeing"  # sightseeing / dining / lodging


class RouteGenerateRequest(BaseModel):
    """Request body for generating a new historical route."""

    dynasty_id: int = Field(..., description="Target dynasty ID")
    figure_name: str | None = Field(None, description="Historical figure to theme the route around")
    start_location: str = Field(..., min_length=1, description="Starting city or location name")
    duration_days: int = Field(..., ge=1, le=30, description="Trip duration in days")
    preferences: dict | None = Field(None, description="User preferences such as pace, interests")


class RouteGenerateResponse(BaseModel):
    """Response containing the generated route plan."""

    route_id: int
    title: str
    dynasty_id: int
    duration_days: int
    stops: list[RouteStop]


class RouteDetailResponse(BaseModel):
    """Full detail of a saved route."""

    route_id: int
    title: str
    dynasty_id: int | None = None
    start_date: str | None = None
    end_date: str | None = None
    status: str
    stops: list[RouteStop]


class ShareImageResponse(BaseModel):
    """Response after generating a shareable image for a route."""

    image_url: str
    share_link: str | None = None


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/generate", response_model=RouteGenerateResponse)
async def generate_route(
    request: RouteGenerateRequest,
    db: AsyncSession = Depends(get_db),
) -> RouteGenerateResponse:
    """Generate a historical tourism route plan.

    Uses the route-planning agent (LLM-backed) to create an itinerary based
    on dynasty, optional historical figure, and user preferences.
    """
    # TODO: Implement route generation via agent pipeline
    raise HTTPException(status_code=501, detail="Route generation not yet implemented")


@router.get("/{route_id}", response_model=RouteDetailResponse)
async def get_route(
    route_id: int,
    db: AsyncSession = Depends(get_db),
) -> RouteDetailResponse:
    """Retrieve a saved route plan by its ID."""
    stmt = select(TripPlan).where(TripPlan.id == route_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Route {route_id} not found")

    # Fetch stops
    stops_stmt = (
        select(TripStop)
        .where(TripStop.trip_plan_id == route_id)
        .order_by(TripStop.day_number, TripStop.order)
    )
    stops_result = await db.execute(stops_stmt)
    stops = stops_result.scalars().all()

    return RouteDetailResponse(
        route_id=plan.id,
        title=plan.title,
        dynasty_id=plan.dynasty_id,
        start_date=str(plan.start_date) if plan.start_date else None,
        end_date=str(plan.end_date) if plan.end_date else None,
        status=plan.status,
        stops=[
            RouteStop(
                ancient_name=stop.ancient_location_id or "",
                modern_name=str(stop.modern_location_id) if stop.modern_location_id else None,
                day_number=stop.day_number,
                order=stop.order,
                description=stop.notes,
                stop_type=stop.stop_type,
            )
            for stop in stops
        ],
    )


@router.post("/{route_id}/share", response_model=ShareImageResponse)
async def share_route(
    route_id: int,
    db: AsyncSession = Depends(get_db),
) -> ShareImageResponse:
    """Generate a shareable image for the given route.

    Creates a visually styled image summarising the route itinerary that can
    be shared on social media.
    """
    # Verify the route exists
    stmt = select(TripPlan).where(TripPlan.id == route_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Route {route_id} not found")

    # TODO: Implement image generation for route sharing
    raise HTTPException(status_code=501, detail="Route sharing image not yet implemented")
