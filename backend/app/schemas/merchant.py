from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum


class MerchantCategory(str, Enum):
    hanfu_rental = "hanfu_rental"
    ancient_photo = "ancient_photo"
    both = "both"


class MerchantBase(BaseModel):
    name: str
    category: MerchantCategory
    description: Optional[str] = None
    address: Optional[str] = None
    latitude: float
    longitude: float
    phone: Optional[str] = None
    price_range: Optional[str] = None


class MerchantResponse(MerchantBase):
    id: int
    rating: Optional[float] = None
    dynasty_tags: Optional[list[str]] = None
    images: Optional[list[str]] = None

    class Config:
        from_attributes = True


class BookingCreate(BaseModel):
    merchant_id: int
    booking_date: str
    time_slot: str
    total_price: Optional[float] = None
    notes: Optional[str] = None


class BookingResponse(BaseModel):
    id: int
    merchant_id: int
    booking_date: str
    time_slot: str
    status: str
    total_price: Optional[float] = None
    notes: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
