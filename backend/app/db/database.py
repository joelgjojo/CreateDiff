import logging
from collections.abc import AsyncGenerator
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings

logger = logging.getLogger("creatediff.db")


class Base(DeclarativeBase):
    pass


_engine = None
_session_factory: Optional[async_sessionmaker[AsyncSession]] = None


def get_engine():
    global _engine
    if _engine is None and settings.DATABASE_URL:
        try:
            _engine = create_async_engine(settings.async_database_url, pool_pre_ping=True)
        except Exception as e:
            logger.warning(f"Failed to create async database engine: {e}")
            _engine = None
    return _engine


def get_session_factory():
    global _session_factory
    if _session_factory is None and get_engine() is not None:
        try:
            _session_factory = async_sessionmaker(get_engine(), expire_on_commit=False)
        except Exception as e:
            logger.warning(f"Failed to create session factory: {e}")
            _session_factory = None
    return _session_factory


async def get_db() -> AsyncGenerator[Optional[AsyncSession], None]:
    factory = get_session_factory()
    if factory is None:
        yield None
        return
    try:
        async with factory() as session:
            yield session
    except Exception as e:
        logger.warning(f"Database session error: {e}")
        yield None


async def init_db() -> None:
    """Initialize database tables safely if DATABASE_URL is configured."""
    engine = get_engine()
    if engine is None:
        return
    try:
        from app.db import models  # noqa: F401
        async with engine.begin() as connection:
            await connection.run_sync(Base.metadata.create_all)
        logger.info("Database schema initialized successfully.")
    except Exception as e:
        logger.warning(f"Database initialization warning (schema may be managed by migrations): {e}")
