"""Geofence API routes - geographic boundary detection and notifications."""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.database import get_db
from app.models.location import AncientLocation, ModernLocation, LocationMatch

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class LocationReportRequest(BaseModel):
    """User location report for geofence checking."""

    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    user_id: int = Field(..., gt=0)
    accuracy: float | None = Field(None, ge=0, description="Location accuracy in metres")


class GeofenceNotification(BaseModel):
    """A triggered geofence notification."""

    geofence_id: int
    ancient_name: str
    modern_name: str | None = None
    notification_title: str
    notification_body: str
    distance_meters: float | None = None
    dynasty: str | None = None


class LocationReportResponse(BaseModel):
    """Response after reporting user location."""

    triggered: list[GeofenceNotification]
    checked_count: int


class NotificationHistoryItem(BaseModel):
    """A single notification history entry."""

    id: int
    geofence_id: int
    ancient_name: str
    modern_name: str | None = None
    notification_title: str
    notification_body: str
    triggered_at: datetime


class NotificationHistoryResponse(BaseModel):
    """Paginated notification history."""

    items: list[NotificationHistoryItem]
    total: int


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/report", response_model=LocationReportResponse)
async def report_location(
    request: LocationReportRequest,
    db: AsyncSession = Depends(get_db),
) -> LocationReportResponse:
    """Report a user's current location and check for triggered geofences.

    Accepts the user coordinates, queries nearby geofenced historical areas,
    and returns any triggered notifications for areas within the configured
    radius.
    """
    # Default search radius in degrees (~500 metres at the equator)
    radius_deg = 0.005
    if request.accuracy and request.accuracy > 100:
        radius_deg = 0.01

    lat_min = request.latitude - radius_deg
    lat_max = request.latitude + radius_deg
    lng_min = request.longitude - radius_deg
    lng_max = request.longitude + radius_deg

    stmt = (
        select(ModernLocation, AncientLocation)
        .join(
            LocationMatch,
            LocationMatch.modern_location_id == ModernLocation.id,
        )
        .join(
            AncientLocation,
            LocationMatch.ancient_location_id == AncientLocation.id,
        )
        .where(
            ModernLocation.latitude.between(lat_min, lat_max),
            ModernLocation.longitude.between(lng_min, lng_max),
        )
        .limit(20)
    )
    result = await db.execute(stmt)
    rows = result.all()

    notifications: list[GeofenceNotification] = []
    for modern, ancient in rows:
        # Calculate approximate distance using Haversine-like approach
        import math

        dlat = modern.latitude - request.latitude
        dlng = modern.longitude - request.longitude
        dist_m = math.sqrt(dlat**2 + dlng**2) * 111_320  # rough metres per degree

        notifications.append(
            GeofenceNotification(
                geofence_id=modern.id,
                ancient_name=ancient.name,
                modern_name=modern.name,
                notification_title=f"You are near {ancient.name}!",
                notification_body=(
                    f"{ancient.name} corresponds to modern {modern.name}. "
                    f"{ancient.historical_significance or ''}"
                ).strip(),
                distance_meters=round(dist_m, 1),
                dynasty=ancient.dynasty.name if ancient.dynasty else None,
            )
        )

    return LocationReportResponse(
        triggered=notifications,
        checked_count=len(rows),
    )


@router.get("/history/{user_id}", response_model=NotificationHistoryResponse)
async def get_notification_history(
    user_id: int,
    limit: int = 20,
    offset: int = 0,
    db: AsyncSession = Depends(get_db),
) -> NotificationHistoryResponse:
    """Retrieve the notification history for a given user.

    Returns a paginated list of previously triggered geofence notifications.
    """
    # TODO: Once a NotificationHistory table exists, query it here.
    # For now return an empty list.
    return NotificationHistoryResponse(items=[], total=0)
