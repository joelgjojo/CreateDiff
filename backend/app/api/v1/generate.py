from __future__ import annotations

import logging
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.generation import GenerationRequest, GenerationResponse
from app.services.generation_service import GenerationService
from app.services.auth import AuthenticatedUser, get_current_user
from app.db.database import get_db
from app.db.models import Generation
from app.services.usage_service import enforce_limit, record
from app.services.analytics import track

logger = logging.getLogger("creatediff.generate")
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
    user: AuthenticatedUser = Depends(get_current_user),
    db: Optional[AsyncSession] = Depends(get_db),
) -> GenerationResponse:
    """
    Accepts creator ideas and context, validates inputs, and orchestrates
    Groq AI generation safely on the server side.
    """
    # 1. Enforce usage limits & record AI request attempt
    if db is not None:
        try:
            await enforce_limit(db, user.db_user_id or user.subject, "generation")
            await enforce_limit(db, user.db_user_id or user.subject, "ai_request")
            if user.db_user_id:
                await record(db, user.db_user_id, "ai_request", metadata={"endpoint": "generate", "platform": payload.platform})
                await db.commit()
        except HTTPException:
            raise
        except Exception as e:
            logger.warning(f"Usage limit enforcement warning (proceeding safely): {e}")

    # 2. Core AI Content Generation Pipeline
    try:
        result = await GenerationService.generate(payload)
    except Exception:
        await track(
            "generation_failed",
            user_id=user.db_user_id or user.subject,
            properties={"platform": payload.platform, "content_type": payload.content_type},
        )
        raise

    # 3. Save generation record to database if available
    if db is not None and user.db_user_id:
        try:
            db.add(
                Generation(
                    user_id=user.db_user_id,
                    platform=payload.platform,
                    content_type=payload.content_type,
                    idea=payload.idea,
                    response=result.model_dump(by_alias=True),
                    retry_count=1 if result.quality and result.quality.retried else 0,
                )
            )
            await record(db, user.db_user_id, "generation", metadata={"platform": payload.platform, "content_type": payload.content_type})
            await db.commit()
        except Exception as e:
            logger.warning(f"Database generation persistence warning: {e}")

    await track(
        "generation_completed",
        user_id=user.db_user_id or user.subject,
        properties={"platform": payload.platform, "content_type": payload.content_type},
    )
    if result.quality and result.quality.retried:
        await track(
            "generation_quality_retry",
            user_id=user.db_user_id or user.subject,
            properties={"platform": payload.platform},
        )
    return result
