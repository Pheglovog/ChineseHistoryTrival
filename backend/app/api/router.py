"""Main API router that aggregates all sub-routers."""

from fastapi import APIRouter

from app.api.routes.geofence import router as geofence_router
from app.api.routes.image import router as image_router
from app.api.routes.matching import router as matching_router
from app.api.routes.merchants import router as merchants_router
from app.api.routes.routes import router as routes_router
from app.api.routes.summary import router as summary_router
from app.api.routes.trips import router as trips_router

api_router = APIRouter()

api_router.include_router(matching_router, prefix="/matching", tags=["matching"])
api_router.include_router(routes_router, prefix="/routes", tags=["routes"])
api_router.include_router(geofence_router, prefix="/geofence", tags=["geofence"])
api_router.include_router(merchants_router, prefix="/merchants", tags=["merchants"])
api_router.include_router(image_router, prefix="/image", tags=["image"])
api_router.include_router(trips_router, prefix="/trips", tags=["trips"])
api_router.include_router(summary_router, prefix="/summary", tags=["summary"])
