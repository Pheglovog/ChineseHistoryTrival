"""Pydantic schemas for location-related API requests and responses."""

from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Dynasty
# ---------------------------------------------------------------------------

class DynastyResponse(BaseModel):
    """Serialised dynasty record."""

    id: int
    name: str
    name_en: Optional[str] = None
    start_year: int
    end_year: int
    sub_period: Optional[str] = None
    description: Optional[str] = None

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Ancient Location
# ---------------------------------------------------------------------------

class AncientLocationResponse(BaseModel):
    """Serialised ancient location record."""

    id: int
    name: str
    alias: Optional[str] = None
    admin_level: str = Field(description="zhou / jun / xian")
    description: Optional[str] = None
    historical_significance: Optional[str] = None
    dynasty_id: int

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Modern Location
# ---------------------------------------------------------------------------

class ModernLocationResponse(BaseModel):
    """Serialised modern location record."""

    id: int
    name: str
    province: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    latitude: float
    longitude: float
    amap_poi_id: Optional[str] = None
    verified: bool = False

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Location Match
# ---------------------------------------------------------------------------

class LocationMatchResponse(BaseModel):
    """Serialised ancient-to-modern location match."""

    id: int
    ancient_location_id: int
    modern_location_id: int
    match_type: str = Field(description="exact / approximate / regional")
    confidence: float = Field(ge=0, le=1)
    source: str = Field(description="manual / ai / geocoding")
    verified: bool = False

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Request schemas
# ---------------------------------------------------------------------------

class GeofenceCheckRequest(BaseModel):
    """Request body for a geofence proximity check."""

    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    radius_meters: float = Field(default=500.0, gt=0)


class GeofenceCheckResponse(BaseModel):
    """Response for a geofence proximity check."""

    locations: list[dict] = Field(default_factory=list)
    count: int = 0
