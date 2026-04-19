"""
SQLAlchemy models package.

All models are imported here so that Alembic's ``autogenerate`` can detect
every table when ``target_metadata = models.Base.metadata`` is used in the
migration environment.
"""

from .base import Base, TimestampMixin  # noqa: F401
from .location import (  # noqa: F401
    Dynasty,
    AncientLocation,
    ModernLocation,
    LocationMatch,
)
from .merchant import (  # noqa: F401
    Merchant,
    Booking,
)
from .trip import (  # noqa: F401
    TripPlan,
    TripStop,
    TripSummary,
    GeneratedImage,
)

__all__ = [
    "Base",
    "TimestampMixin",
    "Dynasty",
    "AncientLocation",
    "ModernLocation",
    "LocationMatch",
    "Merchant",
    "Booking",
    "TripPlan",
    "TripStop",
    "TripSummary",
    "GeneratedImage",
]
