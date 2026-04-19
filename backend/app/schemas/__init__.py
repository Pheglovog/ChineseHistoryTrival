from pydantic import BaseModel
from typing import Optional


class LocationBase(BaseModel):
    name: str
    province: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    latitude: float
    longitude: float


class AncientLocationResponse(BaseModel):
    id: int
    name: str
    alias: Optional[str] = None
    admin_level: str
    description: Optional[str] = None
    historical_significance: Optional[str] = None
    modern_match: Optional[LocationBase] = None

    class Config:
        from_attributes = True


class DynastyResponse(BaseModel):
    id: int
    name: str
    name_en: Optional[str] = None
    start_year: int
    end_year: int
    sub_period: Optional[str] = None
    description: Optional[str] = None

    class Config:
        from_attributes = True


class MatchingRequest(BaseModel):
    ancient_name: str
    alias: Optional[str] = None
    context: Optional[str] = None


class MatchingResponse(BaseModel):
    modern_name: str
    province: Optional[str] = None
    latitude: float
    longitude: float
    confidence: float
    explanation: Optional[str] = None
