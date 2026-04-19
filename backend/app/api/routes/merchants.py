"""Merchant API routes - nearby merchants, details, and booking management."""

from __future__ import annotations

from datetime import date, datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.database import get_db
from app.models.merchant import Merchant, Booking

router = APIRouter()


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------

class MerchantItem(BaseModel):
    """Summary of a merchant listing."""

    id: int
    name: str
    category: str
    description: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    phone: str | None = None
    rating: float | None = None
    price_range: str | None = None
    dynasty_tags: list[str] | None = None
    images: list[str] | None = None


class MerchantDetail(MerchantItem):
    """Full detail of a single merchant."""

    is_active: bool = True


class NearbyMerchantsResponse(BaseModel):
    """Paginated list of nearby merchants."""

    items: list[MerchantItem]
    total: int


class BookingCreateRequest(BaseModel):
    """Request body for creating a new booking."""

    user_id: int = Field(..., gt=0)
    merchant_id: int = Field(..., gt=0)
    booking_date: date
    time_slot: str = Field(..., min_length=1, description="e.g. '10:00-12:00'")
    total_price: float | None = None
    notes: str | None = None


class BookingItem(BaseModel):
    """Representation of a booking."""

    id: int
    user_id: int
    merchant_id: int
    merchant_name: str | None = None
    booking_date: date
    time_slot: str
    status: str
    total_price: float | None = None
    notes: str | None = None
    created_at: datetime | None = None


class BookingStatusResponse(BaseModel):
    """Response after confirming or cancelling a booking."""

    id: int
    status: str
    message: str


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_RADIUS_KM_DEFAULT = 10.0  # default search radius in kilometres


def _haversine_deg_radius(km: float) -> float:
    """Return an approximate degree offset for *km* kilometres at the equator."""
    return km / 111.32


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.get("/nearby", response_model=NearbyMerchantsResponse)
async def list_nearby_merchants(
    lat: float = Query(..., ge=-90, le=90, description="User latitude"),
    lng: float = Query(..., ge=-180, le=180, description="User longitude"),
    category: str | None = Query(None, description="Filter: hanfu_rental / ancient_photo / both"),
    radius: float = Query(_RADIUS_KM_DEFAULT, ge=0.1, le=100, description="Search radius in km"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
) -> NearbyMerchantsResponse:
    """List active merchants near the given coordinates.

    Results are sorted by approximate distance (closest first) and can be
    filtered by category.
    """
    r = _haversine_deg_radius(radius)
    lat_min, lat_max = lat - r, lat + r
    lng_min, lng_max = lng - r, lng + r

    base = (
        select(Merchant)
        .where(
            Merchant.is_active.is_(True),
            Merchant.latitude.between(lat_min, lat_max),
            Merchant.longitude.between(lng_min, lng_max),
        )
    )
    if category:
        base = base.where(Merchant.category == category)

    # Count total matches
    count_stmt = select(func.count()).select_from(base.subquery())
    total = (await db.execute(count_stmt)).scalar() or 0

    # Fetch page
    rows_stmt = base.order_by(
        func.abs(Merchant.latitude - lat) + func.abs(Merchant.longitude - lng)
    ).offset(offset).limit(limit)
    rows = (await db.execute(rows_stmt)).scalars().all()

    items = [
        MerchantItem(
            id=m.id,
            name=m.name,
            category=m.category,
            description=m.description,
            address=m.address,
            latitude=m.latitude,
            longitude=m.longitude,
            phone=m.phone,
            rating=m.rating,
            price_range=m.price_range,
            dynasty_tags=m.dynasty_tags,
            images=m.images,
        )
        for m in rows
    ]

    return NearbyMerchantsResponse(items=items, total=total)


@router.get("/{merchant_id}", response_model=MerchantDetail)
async def get_merchant(
    merchant_id: int,
    db: AsyncSession = Depends(get_db),
) -> MerchantDetail:
    """Retrieve detailed information about a specific merchant."""
    stmt = select(Merchant).where(Merchant.id == merchant_id)
    result = await db.execute(stmt)
    merchant = result.scalar_one_or_none()

    if merchant is None:
        raise HTTPException(status_code=404, detail=f"Merchant {merchant_id} not found")

    return MerchantDetail(
        id=merchant.id,
        name=merchant.name,
        category=merchant.category,
        description=merchant.description,
        address=merchant.address,
        latitude=merchant.latitude,
        longitude=merchant.longitude,
        phone=merchant.phone,
        rating=merchant.rating,
        price_range=merchant.price_range,
        dynasty_tags=merchant.dynasty_tags,
        images=merchant.images,
        is_active=merchant.is_active,
    )


@router.post("/bookings", response_model=BookingItem, status_code=201)
async def create_booking(
    request: BookingCreateRequest,
    db: AsyncSession = Depends(get_db),
) -> BookingItem:
    """Create a new booking at a merchant.

    Validates that the merchant exists and is active before creating the
    booking record.
    """
    # Validate merchant
    stmt = select(Merchant).where(
        Merchant.id == request.merchant_id,
        Merchant.is_active.is_(True),
    )
    merchant = (await db.execute(stmt)).scalar_one_or_none()
    if merchant is None:
        raise HTTPException(
            status_code=404,
            detail=f"Merchant {request.merchant_id} not found or inactive",
        )

    booking = Booking(
        user_id=request.user_id,
        merchant_id=request.merchant_id,
        booking_date=request.booking_date,
        time_slot=request.time_slot,
        total_price=request.total_price,
        notes=request.notes,
        status="pending",
    )
    db.add(booking)
    await db.flush()

    return BookingItem(
        id=booking.id,
        user_id=booking.user_id,
        merchant_id=booking.merchant_id,
        merchant_name=merchant.name,
        booking_date=booking.booking_date,
        time_slot=booking.time_slot,
        status=booking.status,
        total_price=float(booking.total_price) if booking.total_price else None,
        notes=booking.notes,
        created_at=booking.created_at,
    )


@router.put("/bookings/{booking_id}/confirm", response_model=BookingStatusResponse)
async def confirm_booking(
    booking_id: int,
    db: AsyncSession = Depends(get_db),
) -> BookingStatusResponse:
    """Confirm a pending booking."""
    stmt = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(stmt)
    booking = result.scalar_one_or_none()

    if booking is None:
        raise HTTPException(status_code=404, detail=f"Booking {booking_id} not found")

    if booking.status != "pending":
        raise HTTPException(
            status_code=409,
            detail=f"Booking is already '{booking.status}', cannot confirm",
        )

    booking.status = "confirmed"
    await db.flush()

    return BookingStatusResponse(
        id=booking.id,
        status=booking.status,
        message="Booking confirmed successfully",
    )


@router.put("/bookings/{booking_id}/cancel", response_model=BookingStatusResponse)
async def cancel_booking(
    booking_id: int,
    db: AsyncSession = Depends(get_db),
) -> BookingStatusResponse:
    """Cancel a pending or confirmed booking."""
    stmt = select(Booking).where(Booking.id == booking_id)
    result = await db.execute(stmt)
    booking = result.scalar_one_or_none()

    if booking is None:
        raise HTTPException(status_code=404, detail=f"Booking {booking_id} not found")

    if booking.status == "cancelled":
        raise HTTPException(status_code=409, detail="Booking is already cancelled")

    booking.status = "cancelled"
    await db.flush()

    return BookingStatusResponse(
        id=booking.id,
        status=booking.status,
        message="Booking cancelled successfully",
    )
