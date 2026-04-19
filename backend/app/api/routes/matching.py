"""Matching API routes - ancient-to-modern place name matching."""

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

class MatchingRequest(BaseModel):
    """Request body for ancient-to-modern place name matching."""

    ancient_name: str = Field(..., min_length=1, description="Ancient Chinese place name")
    alias: str | None = Field(None, description="Alternative name or alias")
    context: str | None = Field(None, description="Historical context hint, e.g. dynasty name")


class MatchingResponse(BaseModel):
    """Response containing the matched modern location."""

    modern_name: str
    province: str | None = None
    latitude: float
    longitude: float
    confidence: float
    match_type: str | None = None  # exact / approximate / regional
    explanation: str | None = None


class MatchingListResponse(BaseModel):
    """Paginated list of matching results."""

    matches: list[MatchingResponse]
    total: int


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------

@router.post("/ancient-to-modern", response_model=MatchingResponse)
async def match_ancient_to_modern(
    request: MatchingRequest,
    db: AsyncSession = Depends(get_db),
) -> MatchingResponse:
    """Match an ancient Chinese place name to its modern equivalent.

    The matching pipeline combines database lookups with an optional LLM-based
    fallback for names not found in the curated dataset.
    """
    # Step 1: Try exact database match first
    stmt = (
        select(LocationMatch, ModernLocation)
        .join(ModernLocation, LocationMatch.modern_location_id == ModernLocation.id)
        .join(AncientLocation, LocationMatch.ancient_location_id == AncientLocation.id)
        .where(AncientLocation.name == request.ancient_name)
        .order_by(LocationMatch.confidence.desc())
        .limit(1)
    )
    result = await db.execute(stmt)
    row = result.first()

    if row is not None:
        match, modern = row
        return MatchingResponse(
            modern_name=modern.name,
            province=modern.province,
            latitude=modern.latitude,
            longitude=modern.longitude,
            confidence=match.confidence,
            match_type=match.match_type,
            explanation=match.notes,
        )

    # Step 2: Try alias match if alias is provided
    if request.alias:
        stmt = (
            select(LocationMatch, ModernLocation)
            .join(ModernLocation, LocationMatch.modern_location_id == ModernLocation.id)
            .join(AncientLocation, LocationMatch.ancient_location_id == AncientLocation.id)
            .where(AncientLocation.alias == request.alias)
            .order_by(LocationMatch.confidence.desc())
            .limit(1)
        )
        result = await db.execute(stmt)
        row = result.first()

        if row is not None:
            match, modern = row
            return MatchingResponse(
                modern_name=modern.name,
                province=modern.province,
                latitude=modern.latitude,
                longitude=modern.longitude,
                confidence=match.confidence,
                match_type=match.match_type,
                explanation=match.notes,
            )

    # Step 3: Fall back to LLM-based matching (TODO: integrate LLM service)
    # For now return 404 so callers know nothing was found
    raise HTTPException(
        status_code=404,
        detail=(
            f"No match found for ancient name '{request.ancient_name}'. "
            "LLM-based fallback is not yet implemented."
        ),
    )


@router.post("/batch", response_model=MatchingListResponse)
async def batch_match_ancient_to_modern(
    names: list[str],
    db: AsyncSession = Depends(get_db),
) -> MatchingListResponse:
    """Batch-match multiple ancient place names to their modern equivalents."""
    if not names:
        raise HTTPException(status_code=400, detail="names list must not be empty")
    if len(names) > 100:
        raise HTTPException(status_code=400, detail="Maximum 100 names per batch request")

    stmt = (
        select(LocationMatch, ModernLocation, AncientLocation)
        .join(ModernLocation, LocationMatch.modern_location_id == ModernLocation.id)
        .join(AncientLocation, LocationMatch.ancient_location_id == AncientLocation.id)
        .where(AncientLocation.name.in_(names))
        .order_by(LocationMatch.confidence.desc())
    )
    result = await db.execute(stmt)
    rows = result.all()

    # Deduplicate: keep best match per ancient name
    best: dict[str, MatchingResponse] = {}
    for match, modern, ancient in rows:
        if ancient.name not in best or match.confidence > best[ancient.name].confidence:
            best[ancient.name] = MatchingResponse(
                modern_name=modern.name,
                province=modern.province,
                latitude=modern.latitude,
                longitude=modern.longitude,
                confidence=match.confidence,
                match_type=match.match_type,
                explanation=match.notes,
            )

    return MatchingListResponse(matches=list(best.values()), total=len(best))
