from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.db.database import get_db
from app.db.models import User

bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class AuthenticatedUser:
    subject: str
    email: str | None = None
    display_name: str | None = None
    db_user_id: str | None = None


def _claims(token: str) -> dict[str, Any]:
    if not settings.SUPABASE_JWT_SECRET:
        raise HTTPException(status_code=503, detail={"code": "AUTH_NOT_CONFIGURED", "message": "Authentication is not configured."})
    options = {"verify_aud": bool(settings.SUPABASE_JWT_AUDIENCE), "verify_iss": bool(settings.SUPABASE_JWT_ISSUER)}
    try:
        return jwt.decode(token, settings.SUPABASE_JWT_SECRET, algorithms=settings.SUPABASE_JWT_ALGORITHMS, audience=settings.SUPABASE_JWT_AUDIENCE or None, issuer=settings.SUPABASE_JWT_ISSUER or None, options=options)
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail={"code": "INVALID_TOKEN", "message": "Authentication token is invalid or expired."})


async def get_current_user(credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer), db: Optional[AsyncSession] = Depends(get_db)) -> AuthenticatedUser:
    if not settings.AUTH_REQUIRED and not settings.is_production and credentials is None:
        subject = "local-development-user"
        if db is not None:
            user = await db.scalar(select(User).where(User.auth_subject == subject))
            if user is None:
                user = User(auth_subject=subject, display_name="Local Creator")
                db.add(user)
                await db.flush()
            return AuthenticatedUser(subject=subject, display_name="Local Creator", db_user_id=user.id)
        return AuthenticatedUser(subject=subject, email=None, display_name="Local Creator")
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(status_code=401, detail={"code": "AUTH_REQUIRED", "message": "A valid bearer token is required."}, headers={"WWW-Authenticate": "Bearer"})
    decoded = _claims(credentials.credentials)
    subject = str(decoded.get("sub", "")).strip()
    if not subject:
        raise HTTPException(status_code=401, detail={"code": "INVALID_TOKEN", "message": "Token subject is missing."})
    db_user_id = None
    if db is not None:
        user = await db.scalar(select(User).where(User.auth_subject == subject))
        if user is None:
            user = User(auth_subject=subject, email=decoded.get("email"), display_name=decoded.get("user_metadata", {}).get("name") if isinstance(decoded.get("user_metadata"), dict) else None)
            db.add(user)
            await db.flush()
        db_user_id = user.id
    return AuthenticatedUser(subject=subject, email=decoded.get("email"), display_name=None, db_user_id=db_user_id)
