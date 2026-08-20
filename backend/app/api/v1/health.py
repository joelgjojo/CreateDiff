from fastapi import APIRouter
from app.schemas.health import HealthResponse

router = APIRouter(tags=["Health"])


@router.get("/health", response_model=HealthResponse)
async def get_health() -> HealthResponse:
    """
    Lightweight health probe indicating process liveness.
    Does not expose sensitive internal configuration.
    """
    return HealthResponse(
        status="healthy",
        service="CreateDiff AI Studio",
        version="1.0.0",
    )
