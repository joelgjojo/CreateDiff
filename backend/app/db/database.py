from collections.abc import AsyncGenerator
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings


class Base(DeclarativeBase):
    pass


_engine = None
_session_factory: Optional[async_sessionmaker[AsyncSession]] = None


def get_engine():
    global _engine
    if _engine is None and settings.DATABASE_URL:
        _engine = create_async_engine(settings.async_database_url, pool_pre_ping=True)
    return _engine


def get_session_factory():
    global _session_factory
    if _session_factory is None and get_engine() is not None:
        _session_factory = async_sessionmaker(get_engine(), expire_on_commit=False)
    return _session_factory


async def get_db() -> AsyncGenerator[Optional[AsyncSession], None]:
    factory = get_session_factory()
    if factory is None:
        yield None
        return
    async with factory() as session:
        yield session


async def init_db() -> None:
    """Development convenience only; production uses Alembic migrations."""
    engine = get_engine()
    if engine is None or not settings.DB_AUTO_CREATE:
        return
    from app.db import models  # noqa: F401
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
