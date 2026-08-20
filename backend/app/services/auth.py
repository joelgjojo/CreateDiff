from __future__ import annotations

import logging
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

logger = logging.getLogger("creatediff.auth")
bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class AuthenticatedUser:
    subject: str
    email: str | None = None
    display_name: str | None = None
    role: str = "user"
    db_user_id: str | None = None


def _claims(token: str) -> dict[str, Any]:
    if not settings.SUPABASE_JWT_SECRET:
        raise HTTPException(
            status_code=503,
            detail={"code": "AUTH_NOT_CONFIGURED", "message": "Authentication is not configured."},
        )
    options = {
        "verify_aud": bool(settings.SUPABASE_JWT_AUDIENCE),
        "verify_iss": bool(settings.SUPABASE_JWT_ISSUER),
    }
    try:
        return jwt.decode(
            token,
            settings.SUPABASE_JWT_SECRET,
            algorithms=settings.SUPABASE_JWT_ALGORITHMS,
            audience=settings.SUPABASE_JWT_AUDIENCE or None,
            issuer=settings.SUPABASE_JWT_ISSUER or None,
            options=options,
        )
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_TOKEN", "message": "Authentication token is invalid or expired."},
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer),
    db: Optional[AsyncSession] = Depends(get_db),
) -> AuthenticatedUser:
    """
    Authenticates requests via Supabase JWT Bearer tokens.
    
    Behavior:
    - If a Bearer token is supplied: Validates JWT signature & audience, extracts subject,
      and provisions/finds user in the database with role.
    - If no Bearer token is supplied and AUTH_REQUIRED=true: Rejects with HTTP 401.
    - If no Bearer token is supplied and AUTH_REQUIRED=false: Provisions a guest creator
      session allowing frictionless testing in pre-launch / guest mode.
    """
    # 1. Bearer Token Provided -> Validate & Authenticate
    if credentials is not None and credentials.scheme.lower() == "bearer" and credentials.credentials:
        decoded = _claims(credentials.credentials)
        subject = str(decoded.get("sub", "")).strip()
        if not subject:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"code": "INVALID_TOKEN", "message": "Token subject is missing."},
                headers={"WWW-Authenticate": "Bearer"},
            )
        raw_meta = decoded.get("user_metadata") if isinstance(decoded.get("user_metadata"), dict) else {}
        app_meta = decoded.get("app_metadata") if isinstance(decoded.get("app_metadata"), dict) else {}
        display_name = raw_meta.get("display_name") or raw_meta.get("name")
        role = app_meta.get("role") or raw_meta.get("role") or "user"
        db_user_id = None

        if db is not None:
            try:
                user = await db.scalar(select(User).where(User.auth_subject == subject))
                if user is None:
                    user = User(
                        auth_subject=subject,
                        email=decoded.get("email"),
                        display_name=display_name,
                        role=role,
                    )
                    db.add(user)
                    await db.flush()
                else:
                    role = user.role or role
                db_user_id = user.id
            except Exception as e:
                logger.warning(f"Database user provisioning warning: {e}")
                db_user_id = None

        return AuthenticatedUser(
            subject=subject,
            email=decoded.get("email"),
            display_name=display_name,
            role=role,
            db_user_id=db_user_id,
        )

    # 2. Strict Authentication Mode Check
    if settings.AUTH_REQUIRED:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "AUTH_REQUIRED", "message": "Please sign in to continue."},
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 3. Guest / Anonymous Creator Mode (when AUTH_REQUIRED=false)
    subject = "guest-creator"
    db_user_id = None
    if db is not None:
        try:
            user = await db.scalar(select(User).where(User.auth_subject == subject))
            if user is None:
                user = User(auth_subject=subject, display_name="Guest Creator", role="user")
                db.add(user)
                await db.flush()
            db_user_id = user.id
        except Exception as e:
            logger.warning(f"Guest user DB provisioning warning: {e}")
            db_user_id = None

    return AuthenticatedUser(
        subject=subject,
        email=None,
        display_name="Guest Creator",
        role="user",
        db_user_id=db_user_id,
    )


async def require_admin(
    user: AuthenticatedUser = Depends(get_current_user),
) -> AuthenticatedUser:
    """Dependency that enforces server-side administrator role authorization."""
    if user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "FORBIDDEN", "message": "Administrator privileges required."},
        )
    return user
