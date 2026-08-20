import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_readiness_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/readiness")
        assert response.status_code == 200
        data = response.json()
        assert data["service"] == "creatediff-api"
        assert "ai_configured" in data
        assert isinstance(data["ai_configured"], bool)
        assert "auth_configured" in data
        assert isinstance(data["auth_configured"], bool)
        assert "database_configured" in data
        assert isinstance(data["database_configured"], bool)
        assert data["status"] in ("ready", "degraded")
