from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Optional
from uuid import uuid5, NAMESPACE_URL

from app.db.database import get_db
from app.db.models import Campaign, CreatorProfile, Generation
from app.schemas.profile import ProfileSyncRequest, ProfileSyncResponse
from app.services.auth import AuthenticatedUser, get_current_user

router = APIRouter(prefix="/profile", tags=["Profile"])


@router.get("", response_model=ProfileSyncResponse)
async def get_profile(user: AuthenticatedUser = Depends(get_current_user), db: Optional[AsyncSession] = Depends(get_db)):
    if db is None or not user.db_user_id:
        return ProfileSyncResponse(synced=False, profile={})
    profile = await db.scalar(select(CreatorProfile).where(CreatorProfile.user_id == user.db_user_id))
    return ProfileSyncResponse(synced=profile is not None, profile=profile.data if profile else {})


@router.get("/generations")
async def list_generations(user: AuthenticatedUser = Depends(get_current_user), db: Optional[AsyncSession] = Depends(get_db)):
    if db is None or not user.db_user_id:
        return []
    rows = (await db.scalars(select(Generation).where(Generation.user_id == user.db_user_id).order_by(Generation.created_at.desc()))).all()
    return [{"id": row.id, "platform": row.platform, "contentType": row.content_type, "idea": row.idea, "response": row.response, "createdAt": row.created_at.isoformat()} for row in rows]


@router.get("/campaigns")
async def list_campaigns(user: AuthenticatedUser = Depends(get_current_user), db: Optional[AsyncSession] = Depends(get_db)):
    if db is None or not user.db_user_id:
        return []
    rows = (await db.scalars(select(Campaign).where(Campaign.user_id == user.db_user_id).order_by(Campaign.created_at.desc()))).all()
    return [{"id": row.id, "goal": row.goal, "platform": row.platform, "durationDays": row.duration_days, "plan": row.plan, "createdAt": row.created_at.isoformat()} for row in rows]


@router.post("/sync", response_model=ProfileSyncResponse)
async def sync_profile(payload: ProfileSyncRequest, user: AuthenticatedUser = Depends(get_current_user), db: Optional[AsyncSession] = Depends(get_db)):
    if db is None or not user.db_user_id:
        return ProfileSyncResponse(synced=False, profile=payload.profile, content_count=0, campaign_count=0)
    profile = await db.scalar(select(CreatorProfile).where(CreatorProfile.user_id == user.db_user_id))
    if profile is None:
        profile = CreatorProfile(user_id=user.db_user_id, data=payload.profile)
        db.add(profile)
    else:
        profile.data = payload.profile
    content_count = 0
    for item in payload.content_projects:
        source_id = str(item.get("id", ""))
        if not source_id:
            continue
        cloud_id = str(uuid5(NAMESPACE_URL, f"creatediff:{user.db_user_id}:content:{source_id}"))
        generation = await db.scalar(select(Generation).where(Generation.id == cloud_id, Generation.user_id == user.db_user_id))
        if generation is None:
            generation = Generation(id=cloud_id, user_id=user.db_user_id, platform=str(item.get("platform", "Unknown")), content_type=str(item.get("contentType", "Unknown")), idea=str(item.get("idea", "")), response=item)
            db.add(generation)
        else:
            generation.platform = str(item.get("platform", generation.platform))
            generation.content_type = str(item.get("contentType", generation.content_type))
            generation.idea = str(item.get("idea", generation.idea))
            generation.response = item
        content_count += 1
    campaign_count = 0
    for item in payload.campaigns:
        source_id = str(item.get("id", ""))
        if not source_id:
            continue
        cloud_id = str(uuid5(NAMESPACE_URL, f"creatediff:{user.db_user_id}:campaign:{source_id}"))
        campaign = await db.scalar(select(Campaign).where(Campaign.id == cloud_id, Campaign.user_id == user.db_user_id))
        if campaign is None:
            campaign = Campaign(id=cloud_id, user_id=user.db_user_id, goal=str(item.get("campaignGoal", item.get("campaign_goal", ""))), platform=str(item.get("platform", "All")), duration_days=int(item.get("durationDays", item.get("duration_days", 0)) or 0), plan=item)
            db.add(campaign)
        else:
            campaign.goal = str(item.get("campaignGoal", item.get("campaign_goal", campaign.goal)))
            campaign.platform = str(item.get("platform", campaign.platform))
            campaign.plan = item
        campaign_count += 1
    await db.commit()
    return ProfileSyncResponse(synced=True, profile=profile.data, content_count=content_count, campaign_count=campaign_count)
