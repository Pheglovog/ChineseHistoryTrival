from sqlalchemy import (
    Column, Integer, String, Float, Text,
    ForeignKey, Date, Time, Index,
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSON

from .base import Base, TimestampMixin


class TripPlan(Base, TimestampMixin):
    __tablename__ = "trip_plans"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    title = Column(String(200), nullable=False)
    dynasty_id = Column(Integer, ForeignKey("dynasties.id"))
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    budget = Column(Float)
    preferences = Column(JSON)  # user preferences for the trip
    status = Column(
        String(20), nullable=False, default="draft"
    )  # draft / confirmed / completed / cancelled

    dynasty = relationship("Dynasty")
    stops = relationship(
        "TripStop", back_populates="trip_plan", cascade="all, delete-orphan"
    )
    summary = relationship(
        "TripSummary", back_populates="trip_plan", uselist=False
    )

    __table_args__ = (
        Index("idx_trip_user", "user_id"),
        Index("idx_trip_status", "status"),
    )


class TripStop(Base, TimestampMixin):
    __tablename__ = "trip_stops"

    id = Column(Integer, primary_key=True)
    trip_plan_id = Column(
        Integer, ForeignKey("trip_plans.id"), nullable=False
    )
    day_number = Column(Integer, nullable=False)
    order = Column(Integer, nullable=False)
    ancient_location_id = Column(
        Integer, ForeignKey("ancient_locations.id")
    )
    modern_location_id = Column(
        Integer, ForeignKey("modern_locations.id")
    )
    start_time = Column(Time)
    end_time = Column(Time)
    notes = Column(Text)
    stop_type = Column(
        String(20), nullable=False
    )  # sightseeing / dining / lodging

    trip_plan = relationship("TripPlan", back_populates="stops")
    ancient_location = relationship("AncientLocation")
    modern_location = relationship("ModernLocation")

    __table_args__ = (
        Index(
            "idx_trip_stop_plan_day",
            "trip_plan_id",
            "day_number",
            "order",
        ),
    )


class TripSummary(Base, TimestampMixin):
    __tablename__ = "trip_summaries"

    id = Column(Integer, primary_key=True)
    trip_plan_id = Column(
        Integer,
        ForeignKey("trip_plans.id"),
        nullable=False,
        unique=True,
    )
    content = Column(Text)
    images = Column(JSON)  # list of generated image URLs
    video_url = Column(String(500))
    style = Column(String(20))  # ink_wash / gongbi
    status = Column(
        String(20), nullable=False, default="generating"
    )  # generating / completed / failed

    trip_plan = relationship("TripPlan", back_populates="summary")

    __table_args__ = (
        Index("idx_summary_status", "status"),
    )


class GeneratedImage(Base, TimestampMixin):
    __tablename__ = "generated_images"

    id = Column(Integer, primary_key=True)
    original_image_url = Column(String(500))
    generated_image_url = Column(String(500))
    role_type = Column(String(50))  # e.g. "traveler", "guide", "character"
    prompt = Column(Text)
    status = Column(
        String(20), nullable=False, default="pending"
    )  # pending / processing / completed / failed
    task_id = Column(String(100))  # async task identifier

    __table_args__ = (
        Index("idx_generated_image_task", "task_id"),
        Index("idx_generated_image_status", "status"),
    )
