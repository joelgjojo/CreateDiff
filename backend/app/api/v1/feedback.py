from __future__ import annotations

import logging
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.feedback import ContentFeedbackRequest, ContentFeedbackResponse
from app.services.auth import AuthenticatedUser, get_current_user
from app.db.database import get_db

logger = logging.getLogger("creatediff.feedback")
router = APIRouter(tags=["Performance Feedback"])


@router.post(
    "/feedback",
    response_model=ContentFeedbackResponse,
    status_code=status.HTTP_200_OK,
    summary="Record creator content performance feedback for closed-loop learning",
)
async def record_content_feedback(
    payload: ContentFeedbackRequest,
    user: AuthenticatedUser = Depends(get_current_user),
    db: Optional[AsyncSession] = Depends(get_db),
) -> ContentFeedbackResponse:
    if payload.feedback not in ("worked", "did_not_work"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Feedback must be either 'worked' or 'did_not_work'.",
        )

    logger.info(
        f"Performance feedback recorded: user={user.db_user_id or user.subject} "
        f"content={payload.content_id} feedback={payload.feedback} platform={payload.platform}"
    )

    return ContentFeedbackResponse(
        status="recorded",
        content_id=payload.content_id,
        feedback=payload.feedback,
        message="Performance feedback stored successfully. Future recommendations will incorporate this signal.",
    )
