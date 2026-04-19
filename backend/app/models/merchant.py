from sqlalchemy import (
    Column, Integer, String, Float, Boolean, Text,
    ForeignKey, Date, Enum as SAEnum, Numeric, Index,
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSON
from geoalchemy2 import Geometry

from .base import Base, TimestampMixin


class Merchant(Base, TimestampMixin):
    __tablename__ = "merchants"

    id = Column(Integer, primary_key=True)
    name = Column(String(200), nullable=False)
    category = Column(
        String(20), nullable=False
    )  # hanfu_rental / ancient_photo / both
    description = Column(Text)
    address = Column(String(500))
    latitude = Column(Float)
    longitude = Column(Float)
    geom = Column(Geometry("POINT", srid=4326))  # PostGIS geometry
    phone = Column(String(50))
    rating = Column(Float)
    price_range = Column(String(50))
    dynasty_tags = Column(JSON)   # e.g. ["tang", "song"]
    images = Column(JSON)         # list of image URLs
    is_active = Column(Boolean, default=True, nullable=False)

    bookings = relationship("Booking", back_populates="merchant")

    __table_args__ = (
        Index("idx_merchant_category", "category"),
        Index("idx_merchant_active", "is_active"),
    )


class Booking(Base, TimestampMixin):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    merchant_id = Column(
        Integer, ForeignKey("merchants.id"), nullable=False
    )
    booking_date = Column(Date, nullable=False)
    time_slot = Column(String(50), nullable=False)  # e.g. "10:00-12:00"
    status = Column(
        String(20), nullable=False, default="pending"
    )  # pending / confirmed / cancelled
    total_price = Column(Numeric(10, 2))
    notes = Column(Text)

    merchant = relationship("Merchant", back_populates="bookings")

    __table_args__ = (
        Index("idx_booking_user", "user_id"),
        Index("idx_booking_merchant_date", "merchant_id", "booking_date"),
    )
