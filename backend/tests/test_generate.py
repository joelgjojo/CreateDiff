import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import patch
from app.main import app


@pytest.mark.asyncio
async def test_generate_input_validation_empty():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/v1/generate", json={
            "platform": "Instagram",
            "contentType": "Reel",
            "idea": "  ",
        })
        assert response.status_code == 422
        data = response.json()
        assert "error" in data
        assert data["error"]["code"] == "INVALID_REQUEST"


@pytest.mark.asyncio
async def test_generate_input_validation_short():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/v1/generate", json={
            "platform": "Instagram",
            "contentType": "Reel",
            "idea": "ab",
        })
        assert response.status_code == 422
        data = response.json()
        assert data["error"]["code"] == "INVALID_REQUEST"


@pytest.mark.asyncio
async def test_generate_success_mock():
    mock_ai_response = {
        "hooks": ["Hook 1", "Hook 2", "Hook 3", "Hook 4", "Hook 5"],
        "caption": "Full formatted caption...",
        "ctas": ["Save this post", "Share"],
        "hashtagsHighReach": ["#Tech", "#AI"],
        "hashtagsMediumReach": ["#Software"],
        "hashtagsNiche": ["#FlutterDev"],
        "coverText": "AI SECRETS",
        "variations": ["Standard", "High-Engagement"],
    }

    with patch("app.services.groq_service.GroqService.generate_chat_completion", return_value=mock_ai_response):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/api/v1/generate", json={
                "platform": "Instagram",
                "contentType": "Reel",
                "idea": "Top 5 software engineering tips for creators",
                "overrideLanguage": "English",
                "creatorContext": {
                    "name": "Dev",
                    "niche": "Technology",
                }
            })
            assert response.status_code == 200
            data = response.json()
            assert len(data["hooks"]) == 5
            assert data["caption"] == "Full formatted caption..."
            assert data["coverText"] == "AI SECRETS"
            assert data["hashtagsHighReach"] == ["#Tech", "#AI"]
