from fastapi import APIRouter
from app.config import settings
from app.schemas.health import ReadinessResponse

router = APIRouter(tags=["Readiness"])


@router.get("/readiness", response_model=ReadinessResponse)
async def get_readiness() -> ReadinessResponse:
    """
    Readiness check verifying service readiness to handle AI generation.
    Checks that critical configuration is loaded without invoking paid upstream tokens.
    """
    has_key = bool(settings.GROQ_API_KEY and len(settings.GROQ_API_KEY.strip()) >= 10)
    auth_configured = not settings.is_production or (
        settings.AUTH_REQUIRED and bool(settings.SUPABASE_JWT_SECRET.strip())
    )
    database_configured = bool(settings.DATABASE_URL.strip())
    return ReadinessResponse(
        status="ready" if has_key and auth_configured and database_configured else "degraded",
        service="CreateDiff AI Studio",
        version="1.0.0",
        ai_configured=has_key,
        auth_configured=auth_configured,
        database_configured=database_configured,
    )
