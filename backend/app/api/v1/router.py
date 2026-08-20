from fastapi import APIRouter
from app.api.v1.health import router as health_router
from app.api.v1.readiness import router as readiness_router
from app.api.v1.generate import router as generate_router
from app.api.v1.campaign import router as campaign_router
from app.api.v1.profile import router as profile_router
from app.api.v1.admin import router as admin_router
from app.api.v1.intent import router as intent_router
from app.api.v1.visual import router as visual_router
from app.api.v1.feedback import router as feedback_router
from app.api.v1.assistant import router as assistant_router

api_v1_router = APIRouter()

api_v1_router.include_router(health_router)
api_v1_router.include_router(readiness_router)
api_v1_router.include_router(generate_router)
api_v1_router.include_router(campaign_router)
api_v1_router.include_router(profile_router)
api_v1_router.include_router(admin_router)
api_v1_router.include_router(intent_router)
api_v1_router.include_router(visual_router)
api_v1_router.include_router(feedback_router)
api_v1_router.include_router(assistant_router)
