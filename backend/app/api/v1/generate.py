from fastapi import APIRouter, Request, status
from app.schemas.generation import GenerationRequest, GenerationResponse
from app.services.generation_service import GenerationService

router = APIRouter(tags=["Generation"])


@router.post(
    "/generate",
    response_model=GenerationResponse,
    status_code=status.HTTP_200_OK,
    summary="Generate complete structured AI content pack",
)
async def generate_content(
    request: Request,
    payload: GenerationRequest,
) -> GenerationResponse:
    """
    Accepts creator ideas and context, validates inputs, and orchestrates
    Groq AI generation safely on the server side.
    """
    return await GenerationService.generate(payload)
