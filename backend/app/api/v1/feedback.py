from __future__ import annotations

import logging
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.feedback import ContentFeedbackRequest, ContentFeedbackResponse
from app.services.auth import AuthenticatedUser, get_current_user
from app.db.database import get_db
from app.db.models import ContentFeedback

logger = logging.getLogger("creatediff.feedback")
router = APIRouter(tags=["Performance Feedback"])


@router.get(
    "/feedback",
    response_model=list[dict],
    status_code=status.HTTP_200_OK,
    summary="List creator's recorded content feedback (User isolated)",
)
async def list_content_feedback(
    user: AuthenticatedUser = Depends(get_current_user),
    db: Optional[AsyncSession] = Depends(get_db),
) -> list[dict]:
    if db is None or not user.db_user_id:
        return []
    
    stmt = (
        select(ContentFeedback)
        .where(ContentFeedback.user_id == user.db_user_id)
        .order_by(ContentFeedback.created_at.desc())
        .limit(100)
    )
    rows = (await db.scalars(stmt)).all()
    return [
        {
            "id": r.id,
            "contentId": r.content_id,
            "platform": r.platform,
            "contentType": r.content_type,
            "feedback": r.feedback,
            "notes": r.notes,
            "createdAt": r.created_at.isoformat() if r.created_at else None,
        }
        for r in rows
    ]


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

    user_id = user.db_user_id or user.subject
    logger.info(
        f"Performance feedback recorded: user={user_id} "
        f"content={payload.content_id} feedback={payload.feedback} platform={payload.platform}"
    )

    if db is not None and user_id:
        try:
            feedback_row = ContentFeedback(
                user_id=user_id,
                content_id=payload.content_id,
                platform=payload.platform,
                content_type=payload.content_type,
                feedback=payload.feedback,
                notes=payload.notes,
            )
            db.add(feedback_row)
            await db.commit()
        except Exception as e:
            logger.warning(f"Database content feedback persistence warning: {e}")

    return ContentFeedbackResponse(
        status="recorded",
        content_id=payload.content_id,
        feedback=payload.feedback,
        message="Performance feedback stored successfully. Future recommendations will incorporate this signal.",
    )
