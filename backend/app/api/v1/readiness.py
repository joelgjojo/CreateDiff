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
    return ReadinessResponse(
        status="ready" if has_key else "degraded",
        service="creatediff-api",
        version="1.0.0",
        ai_configured=has_key,
    )
