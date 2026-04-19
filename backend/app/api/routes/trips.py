"""Trip planning API routes - AI-assisted trip generation and management."""

from __future__ import annotations

from datetime import datetime

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

class TripStopItem(BaseModel):
    """A single stop within a trip plan."""

    id: int | None = None
    day_number: int
    order: int
    ancient_name: str | None = None
    modern_name: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    description: str | None = None
    stop_type: str = "sightseeing"
    start_time: str | None = None
    end_time: str | None = None


class TripPlanRequest(BaseModel):
    """Request body for generating a new trip plan."""

    user_id: int = Field(..., gt=0)
    dynasty_id: int = Field(..., description="Target dynasty")
    title: str | None = Field(None, description="Optional trip title")
    start_date: str = Field(..., description="Trip start date (YYYY-MM-DD)")
    end_date: str = Field(..., description="Trip end date (YYYY-MM-DD)")
    budget: float | None = Field(None, ge=0, description="Total budget in CNY")
    preferences: dict | None = Field(
        None,
        description="Preferences: pace, interests, transport, etc.",
    )


class TripPlanResponse(BaseModel):
    """Response containing the generated trip plan."""

    trip_id: int
    title: str
    dynasty_id: int
    status: str
    stops: list[TripStopItem]
    created_at: datetime | None = None


class TripDetailResponse(BaseModel):
    """Full trip plan details."""

    trip_id: int
    user_id: int
    title: str
    dynasty_id: int | None = None
    start_date: str | None = None
    end_date: str | None = None
    budget: float | None = None
    preferences: dict | None = None
    status: str
    stops: list[TripStopItem]
    created_at: datetime | None = None
    updated_at: datetime | None = None


class TripAdjustRequest(BaseModel):
    """Request body for adjusting an existing trip plan."""

    preferences: dict | None = None
    add_stops: list[TripStopItem] | None = None
    remove_stop_ids: list[int] | None = None
    budget: float | None = None


class TripChatRequest(BaseModel):
    """Natural language modification request."""

    message: str = Field(..., min_length=1, description="User's natural language instruction")
    user_id: int = Field(..., gt=0)


class TripChatResponse(BaseModel):
    """Response after processing a natural language trip modification."""

    trip_id: int
    reply: str
    stops_updated: bool = False
    stops: list[TripStopItem] | None = None


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/plan", response_model=TripPlanResponse, status_code=201)
async def create_trip_plan(
    request: TripPlanRequest,
    db: AsyncSession = Depends(get_db),
) -> TripPlanResponse:
    """Generate a new trip plan using the AI planning agent.

    Accepts user constraints (dynasty, dates, budget, preferences) and
    produces a day-by-day itinerary of historical stops.
    """
    # TODO: Integrate with AI trip-planning agent
    raise HTTPException(status_code=501, detail="Trip planning not yet implemented")


@router.get("/{trip_id}", response_model=TripDetailResponse)
async def get_trip(
    trip_id: int,
    db: AsyncSession = Depends(get_db),
) -> TripDetailResponse:
    """Retrieve the full details of a saved trip plan."""
    stmt = select(TripPlan).where(TripPlan.id == trip_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Trip {trip_id} not found")

    stops_stmt = (
        select(TripStop)
        .where(TripStop.trip_plan_id == trip_id)
        .order_by(TripStop.day_number, TripStop.order)
    )
    stops_result = await db.execute(stops_stmt)
    stops = stops_result.scalars().all()

    return TripDetailResponse(
        trip_id=plan.id,
        user_id=plan.user_id,
        title=plan.title,
        dynasty_id=plan.dynasty_id,
        start_date=str(plan.start_date) if plan.start_date else None,
        end_date=str(plan.end_date) if plan.end_date else None,
        budget=plan.budget,
        preferences=plan.preferences,
        status=plan.status,
        stops=[
            TripStopItem(
                id=s.id,
                day_number=s.day_number,
                order=s.order,
                stop_type=s.stop_type,
                description=s.notes,
                start_time=str(s.start_time) if s.start_time else None,
                end_time=str(s.end_time) if s.end_time else None,
            )
            for s in stops
        ],
        created_at=plan.created_at,
        updated_at=plan.updated_at,
    )


@router.put("/{trip_id}/adjust", response_model=TripPlanResponse)
async def adjust_trip(
    trip_id: int,
    request: TripAdjustRequest,
    db: AsyncSession = Depends(get_db),
) -> TripPlanResponse:
    """Adjust an existing trip plan.

    Supports adding/removing stops, updating preferences, and modifying the
    budget. The AI agent re-optimises the itinerary after changes.
    """
    stmt = select(TripPlan).where(TripPlan.id == trip_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Trip {trip_id} not found")

    # Apply simple field updates
    if request.budget is not None:
        plan.budget = request.budget
    if request.preferences is not None:
        plan.preferences = request.preferences

    # Remove stops if requested
    if request.remove_stop_ids:
        for stop_id in request.remove_stop_ids:
            stop_stmt = select(TripStop).where(
                TripStop.id == stop_id,
                TripStop.trip_plan_id == trip_id,
            )
            stop = (await db.execute(stop_stmt)).scalar_one_or_none()
            if stop:
                await db.delete(stop)

    await db.flush()

    # TODO: Trigger AI re-optimisation after modifications

    # Fetch updated stops
    stops_stmt = (
        select(TripStop)
        .where(TripStop.trip_plan_id == trip_id)
        .order_by(TripStop.day_number, TripStop.order)
    )
    stops = (await db.execute(stops_stmt)).scalars().all()

    return TripPlanResponse(
        trip_id=plan.id,
        title=plan.title,
        dynasty_id=plan.dynasty_id,
        status=plan.status,
        stops=[
            TripStopItem(
                id=s.id,
                day_number=s.day_number,
                order=s.order,
                stop_type=s.stop_type,
                description=s.notes,
            )
            for s in stops
        ],
        created_at=plan.created_at,
    )


@router.post("/{trip_id}/chat", response_model=TripChatResponse)
async def chat_modify_trip(
    trip_id: int,
    request: TripChatRequest,
    db: AsyncSession = Depends(get_db),
) -> TripChatResponse:
    """Modify a trip plan using natural language instructions.

    The user's free-text message is interpreted by the AI agent which
    translates it into concrete itinerary changes.
    """
    stmt = select(TripPlan).where(TripPlan.id == trip_id)
    result = await db.execute(stmt)
    plan = result.scalar_one_or_none()

    if plan is None:
        raise HTTPException(status_code=404, detail=f"Trip {trip_id} not found")

    # TODO: Integrate with AI chat agent for natural language modifications
    raise HTTPException(
        status_code=501,
        detail="Natural language trip modification not yet implemented",
    )
