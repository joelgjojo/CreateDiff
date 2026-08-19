import jwt
import pytest
from datetime import datetime, timedelta, timezone
from httpx import ASGITransport, AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.config import settings
from app.db.database import Base, get_db
from app.db.models import Campaign, CreatorProfile, Generation, UsageLog, User
from app.main import app
from app.services.usage_service import enforce_limit
from fastapi import HTTPException


@pytest.fixture
async def db_session():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)

    async def override_get_db():
        async with factory() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db
    try:
        yield factory
    finally:
        app.dependency_overrides.pop(get_db, None)
        await engine.dispose()


def token(subject: str, email: str) -> str:
    return jwt.encode({"sub": subject, "email": email, "aud": "authenticated", "exp": datetime.now(timezone.utc).timestamp() + 3600}, "phase3-test-secret-32-bytes-minimum!!", algorithm="HS256")


@pytest.mark.asyncio
async def test_authentication_and_user_data_isolation(db_session, monkeypatch):
    monkeypatch.setattr(settings, "AUTH_REQUIRED", True)
    monkeypatch.setattr(settings, "SUPABASE_JWT_SECRET", "phase3-test-secret-32-bytes-minimum!!")
    monkeypatch.setattr(settings, "SUPABASE_JWT_AUDIENCE", "authenticated")
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        assert (await client.get("/api/v1/profile")).status_code == 401
        user_a = {"Authorization": f"Bearer {token('user-a', 'a@example.com')}"}
        user_b = {"Authorization": f"Bearer {token('user-b', 'b@example.com')}"}
        response_a = await client.post("/api/v1/profile/sync", headers=user_a, json={"profile": {"creatorName": "A"}, "contentProjects": [{"id": "p1", "platform": "Instagram", "contentType": "Reel", "idea": "A idea"}], "campaigns": [{"id": "c1", "campaignGoal": "A goal", "durationDays": 7}]})
        response_b = await client.post("/api/v1/profile/sync", headers=user_b, json={"profile": {"creatorName": "B"}})
        assert response_a.status_code == response_b.status_code == 200
        assert (await client.get("/api/v1/profile", headers=user_a)).json()["profile"]["creatorName"] == "A"
        assert (await client.get("/api/v1/profile", headers=user_b)).json()["profile"]["creatorName"] == "B"
        assert len((await client.get("/api/v1/profile/generations", headers=user_a)).json()) == 1
        assert (await client.get("/api/v1/profile/generations", headers=user_b)).json() == []
        assert len((await client.get("/api/v1/profile/campaigns", headers=user_a)).json()) == 1
        assert (await client.get("/api/v1/profile/campaigns", headers=user_b)).json() == []


@pytest.mark.asyncio
async def test_database_relationships_and_usage_records(db_session):
    async with db_session() as session:
        user = User(auth_subject="db-user", email="db@example.com")
        session.add(user)
        await session.flush()
        session.add(CreatorProfile(user_id=user.id, data={"creatorName": "DB User"}))
        session.add(Generation(user_id=user.id, platform="Instagram", content_type="Reel", idea="Idea", response={"hooks": []}))
        session.add(Campaign(id="camp-db", user_id=user.id, goal="Goal", duration_days=7, plan={"days": []}))
        session.add(UsageLog(user_id=user.id, event_type="generation", quantity=1, event_metadata={"platform": "Instagram"}))
        await session.commit()
        assert (await session.scalar(select(CreatorProfile).where(CreatorProfile.user_id == user.id))) is not None
        assert len((await session.scalars(select(Generation).where(Generation.user_id == user.id))).all()) == 1
        assert len((await session.scalars(select(Campaign).where(Campaign.user_id == user.id))).all()) == 1
        assert len((await session.scalars(select(UsageLog).where(UsageLog.user_id == user.id))).all()) == 1


@pytest.mark.asyncio
async def test_configurable_usage_limit_and_rolling_reset(db_session, monkeypatch):
    monkeypatch.setattr(settings, "USAGE_GENERATION_LIMIT", 1)
    async with db_session() as session:
        user = User(auth_subject="quota-user")
        session.add(user)
        await session.flush()
        session.add(UsageLog(user_id=user.id, event_type="generation", quantity=1, event_metadata={}))
        await session.commit()
        with pytest.raises(HTTPException) as blocked:
            await enforce_limit(session, user.id, "generation")
        assert blocked.value.status_code == 429
        old = UsageLog(user_id=user.id, event_type="campaign", quantity=1, event_metadata={}, created_at=datetime.now(timezone.utc) - timedelta(days=2))
        session.add(old)
        await session.commit()
        monkeypatch.setattr(settings, "USAGE_CAMPAIGN_LIMIT", 1)
        assert await enforce_limit(session, user.id, "campaign") is None


@pytest.mark.asyncio
async def test_guest_mode_in_production_allows_generation_when_auth_not_required(db_session, monkeypatch):
    monkeypatch.setattr(settings, "ENVIRONMENT", "production")
    monkeypatch.setattr(settings, "AUTH_REQUIRED", False)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        health_resp = await client.get("/api/v1/health")
        assert health_resp.status_code == 200
        # Profile without auth header should succeed with guest session
        profile_resp = await client.get("/api/v1/profile")
        assert profile_resp.status_code == 200
        assert profile_resp.json()["synced"] is False


@pytest.mark.asyncio
async def test_strict_auth_required_blocks_when_auth_required_true(db_session, monkeypatch):
    monkeypatch.setattr(settings, "ENVIRONMENT", "production")
    monkeypatch.setattr(settings, "AUTH_REQUIRED", True)
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        profile_resp = await client.get("/api/v1/profile")
        assert profile_resp.status_code == 401
        assert profile_resp.json()["error"]["code"] == "AUTH_REQUIRED"

