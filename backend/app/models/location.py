from sqlalchemy import (
    Column, Integer, String, Float, Boolean, Text,
    ForeignKey, UniqueConstraint, Index,
)
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry

from .base import Base, TimestampMixin


class Dynasty(Base, TimestampMixin):
    __tablename__ = "dynasties"

    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    name_en = Column(String(100))
    start_year = Column(Integer, nullable=False)
    end_year = Column(Integer, nullable=False)
    sub_period = Column(String(50))
    description = Column(Text)

    ancient_locations = relationship(
        "AncientLocation", back_populates="dynasty"
    )


class AncientLocation(Base, TimestampMixin):
    __tablename__ = "ancient_locations"

    id = Column(Integer, primary_key=True)
    dynasty_id = Column(
        Integer, ForeignKey("dynasties.id"), nullable=False
    )
    name = Column(String(100), nullable=False)
    alias = Column(String(100))
    admin_level = Column(String(20), nullable=False)  # zhou/jun/xian
    parent_location_id = Column(
        Integer, ForeignKey("ancient_locations.id")
    )
    description = Column(Text)
    year_established = Column(Integer)
    year_abolished = Column(Integer)
    historical_significance = Column(Text)

    dynasty = relationship("Dynasty", back_populates="ancient_locations")
    parent = relationship(
        "AncientLocation", remote_side=[id], backref="children"
    )
    matches = relationship(
        "LocationMatch", back_populates="ancient_location"
    )

    __table_args__ = (
        Index("idx_ancient_dynasty_level", "dynasty_id", "admin_level"),
    )


class ModernLocation(Base, TimestampMixin):
    __tablename__ = "modern_locations"

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    province = Column(String(50))
    city = Column(String(50))
    district = Column(String(50))
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    geom = Column(Geometry("POINT", srid=4326))  # PostGIS geometry
    amap_poi_id = Column(String(100))
    source = Column(String(20), nullable=False, default="manual")
    confidence = Column(Float)
    verified = Column(Boolean, default=False)

    matches = relationship(
        "LocationMatch", back_populates="modern_location"
    )

    __table_args__ = (
        Index("idx_modern_coords", "latitude", "longitude"),
    )


class LocationMatch(Base, TimestampMixin):
    __tablename__ = "location_matches"

    id = Column(Integer, primary_key=True)
    ancient_location_id = Column(
        Integer, ForeignKey("ancient_locations.id"), nullable=False
    )
    modern_location_id = Column(
        Integer, ForeignKey("modern_locations.id"), nullable=False
    )
    match_type = Column(String(20), nullable=False)  # exact/approximate/regional
    confidence = Column(Float, nullable=False)
    source = Column(String(20), nullable=False)  # manual/ai/geocoding
    notes = Column(Text)
    verified = Column(Boolean, default=False)

    ancient_location = relationship(
        "AncientLocation", back_populates="matches"
    )
    modern_location = relationship(
        "ModernLocation", back_populates="matches"
    )

    __table_args__ = (
        UniqueConstraint(
            "ancient_location_id",
            "modern_location_id",
            name="uq_location_match",
        ),
    )
