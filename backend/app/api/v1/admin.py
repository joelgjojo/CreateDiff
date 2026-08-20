from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.models import Campaign, Generation, User
from app.services.auth import AuthenticatedUser, require_admin

logger = logging.getLogger("creatediff.admin")
router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/users")
async def list_users(
    admin: AuthenticatedUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Admin endpoint to inspect user accounts. Requires admin role."""
    if db is None:
        return {"users": [], "count": 0}

    stmt = select(User).order_by(User.created_at.desc()).limit(100)
    users = (await db.scalars(stmt)).all()
    return {
        "count": len(users),
        "users": [
            {
                "id": u.id,
                "auth_subject": u.auth_subject,
                "email": u.email,
                "display_name": u.display_name,
                "role": u.role,
                "plan": u.plan,
                "created_at": u.created_at.isoformat() if u.created_at else None,
            }
            for u in users
        ],
    }


@router.get("/stats")
async def get_system_stats(
    admin: AuthenticatedUser = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Admin endpoint to view aggregate system metrics. Requires admin role."""
    if db is None:
        return {"total_users": 0, "total_generations": 0, "total_campaigns": 0}

    user_count = await db.scalar(select(func.count(User.id))) or 0
    gen_count = await db.scalar(select(func.count(Generation.id))) or 0
    camp_count = await db.scalar(select(func.count(Campaign.id))) or 0

    return {
        "total_users": user_count,
        "total_generations": gen_count,
        "total_campaigns": camp_count,
        "failed_generations": 0,
        "app_version": "3.5.0",
        "backend_status": "operational",
    }
