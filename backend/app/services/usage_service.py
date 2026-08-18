from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.db.models import UsageLog


async def enforce_limit(db: Optional[AsyncSession], user_id: str, event_type: str) -> None:
    if db is None:
        return
    limit = settings.usage_limits.get(event_type)
    if limit is None:
        return
    since = datetime.now(timezone.utc) - timedelta(days=1)
    total = await db.scalar(select(func.coalesce(func.sum(UsageLog.quantity), 0)).where(
        UsageLog.user_id == user_id, UsageLog.event_type == event_type, UsageLog.created_at >= since
    ))
    if int(total or 0) >= limit:
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail={"code": "USAGE_LIMIT_REACHED", "message": "Usage limit reached. Please try again later."})


async def record(db: Optional[AsyncSession], user_id: str, event_type: str, *, quantity: int = 1, metadata: dict | None = None) -> None:
    if db is None:
        return
    db.add(UsageLog(user_id=user_id, event_type=event_type, quantity=quantity, event_metadata=metadata or {}))
