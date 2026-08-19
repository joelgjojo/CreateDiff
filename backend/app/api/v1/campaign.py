from __future__ import annotations

import logging
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas.campaign import CampaignPlanRequest, CampaignPlanResponse
from app.services.campaign_service import CampaignService
from app.services.auth import AuthenticatedUser, get_current_user
from app.db.database import get_db
from app.db.models import Campaign
from app.services.usage_service import enforce_limit, record
from app.services.analytics import track

logger = logging.getLogger("creatediff.campaign")
router = APIRouter(prefix="/campaign", tags=["Campaign"])


@router.post(
    "/plan",
    response_model=CampaignPlanResponse,
    status_code=status.HTTP_200_OK,
    summary="Plan cohesive multi-day creator content campaign",
)
async def plan_campaign(
    request: Request,
    payload: CampaignPlanRequest,
    user: AuthenticatedUser = Depends(get_current_user),
    db: Optional[AsyncSession] = Depends(get_db),
) -> CampaignPlanResponse:
    """
    Accepts campaign objectives and creator context to generate a strategic
    multi-day content roadmap.
    """
    # 1. Enforce usage limits & record AI request attempt
    if db is not None:
        try:
            await enforce_limit(db, user.db_user_id or user.subject, "campaign")
            await enforce_limit(db, user.db_user_id or user.subject, "ai_request")
            if user.db_user_id:
                await record(db, user.db_user_id, "ai_request", metadata={"endpoint": "campaign/plan", "platform": payload.platform or "All"})
                await db.commit()
        except HTTPException:
            raise
        except Exception as e:
            logger.warning(f"Campaign usage check warning (proceeding safely): {e}")

    # 2. Core AI Campaign Planning Pipeline
    try:
        result = await CampaignService.plan_campaign(payload)
    except Exception:
        await track(
            "campaign_failed",
            user_id=user.db_user_id or user.subject,
            properties={"platform": payload.platform or "All"},
        )
        raise

    # 3. Save campaign plan to database if available
    if db is not None and user.db_user_id:
        try:
            db.add(
                Campaign(
                    id=result.id,
                    user_id=user.db_user_id,
                    goal=payload.goal,
                    platform=result.platform,
                    duration_days=result.duration_days,
                    plan=result.model_dump(by_alias=True),
                )
            )
            await record(db, user.db_user_id, "campaign", metadata={"platform": result.platform, "duration_days": result.duration_days})
            await db.commit()
        except Exception as e:
            logger.warning(f"Database campaign persistence warning: {e}")

    await track(
        "campaign_completed",
        user_id=user.db_user_id or user.subject,
        properties={"platform": result.platform, "duration_days": result.duration_days},
    )
    return result
