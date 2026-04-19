from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum


class TripStatus(str, Enum):
    draft = "draft"
    confirmed = "confirmed"
    in_progress = "in_progress"
    completed = "completed"
    cancelled = "cancelled"


class TripStopType(str, Enum):
    sightseeing = "sightseeing"
    dining = "dining"
    lodging = "lodging"


class TripPlanCreate(BaseModel):
    title: Optional[str] = None
    dynasty_id: int = 1
    start_date: str
    end_date: str
    budget: Optional[float] = None
    preferences: Optional[dict] = None
    figure_name: Optional[str] = None
    start_location: Optional[str] = None


class TripStopResponse(BaseModel):
    id: int
    day_number: int
    order: int
    ancient_location_name: Optional[str] = None
    modern_location_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None
    notes: Optional[str] = None
    stop_type: Optional[str] = None

    class Config:
        from_attributes = True


class TripPlanResponse(BaseModel):
    id: int
    title: Optional[str] = None
    dynasty_id: int
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    budget: Optional[float] = None
    status: str
    stops: list[TripStopResponse] = []
    created_at: datetime

    class Config:
        from_attributes = True


class TripAdjustRequest(BaseModel):
    add_stops: Optional[list[dict]] = None
    remove_stop_ids: Optional[list[int]] = None
    new_budget: Optional[float] = None
    message: Optional[str] = None


class SummaryResponse(BaseModel):
    id: int
    trip_plan_id: int
    content: Optional[str] = None
    images: Optional[list[str]] = None
    video_url: Optional[str] = None
    style: Optional[str] = None
    status: str

    class Config:
        from_attributes = True
