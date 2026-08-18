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
async def test_generate_success_mock_with_intelligence_and_platform():
    mock_ai_response = {
        "hooks": ["Hook 1", "Hook 2", "Hook 3", "Hook 4", "Hook 5"],
        "caption": "Full formatted caption...",
        "ctas": ["Save this post", "Share"],
        "hashtagsHighReach": ["#Tech", "#AI"],
        "hashtagsMediumReach": ["#Software"],
        "hashtagsNiche": ["#FlutterDev"],
        "coverText": "AI SECRETS",
        "variations": ["Standard", "High-Engagement"],
        "script": "[0-3s]: Stop scrolling\\n[3-15s]: 3 tools\\n[15-30s]: Follow for more",
        "sceneDirections": ["Scene 1: Close-up", "Scene 2: Screen record"],
        "titleOptions": ["AI Secrets 2026", "Top 5 Tools"],
        "thumbnailText": "AI 2026",
        "visualIntelligence": {
            "visualStyle": "Cyberpunk Minimalist",
            "layoutSuggestion": "Bold 3-word title on top",
            "thumbnailDirection": "Side profile with yellow text",
            "typographySuggestion": "Space Grotesk",
            "colorPalette": ["#080A0F", "#4F43F9", "#00B894", "#FFFFFF"],
            "designMood": "High energy"
        },
        "quality": {
            "hookStrength": 92,
            "platformFit": 95,
            "audienceFit": 90,
            "originality": 88,
            "overallScore": 91,
            "issues": []
        }
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
                    "preferredPlatforms": ["Instagram", "YouTube"],
                    "contentGoals": ["Audience Growth"],
                }
            })
            assert response.status_code == 200
            data = response.json()
            assert len(data["hooks"]) == 5
            assert data["caption"] == "Full formatted caption..."
            assert data["coverText"] == "AI SECRETS"
            assert data["hashtagsHighReach"] == ["#Tech", "#AI"]
            assert data["script"] is not None
            assert len(data["sceneDirections"]) == 2
            assert data["visualIntelligence"]["visualStyle"] == "Cyberpunk Minimalist"
            assert data["visualIntelligence"]["colorPalette"] == ["#080A0F", "#4F43F9", "#00B894", "#FFFFFF"]
            assert data["quality"]["overallScore"] == 91
            assert data["quality"]["retried"] is False


@pytest.mark.asyncio
async def test_generate_quality_retry_trigger():
    low_quality_response = {
        "hooks": ["Weak hook"],
        "caption": "Generic caption",
        "ctas": ["Click"],
        "coverText": "GENERIC",
        "quality": {
            "hookStrength": 45,
            "platformFit": 50,
            "audienceFit": 55,
            "originality": 40,
            "overallScore": 48,
            "issues": ["Hook lacks punch", "Too generic"]
        }
    }

    improved_response = {
        "hooks": ["Irresistible High-Voltage Hook 1", "Hook 2", "Hook 3", "Hook 4", "Hook 5"],
        "caption": "Elevated deep-dive creator caption with clear value.",
        "ctas": ["Save for later", "Share with fellow engineers"],
        "coverText": "GAME CHANGER",
        "quality": {
            "hookStrength": 94,
            "platformFit": 92,
            "audienceFit": 90,
            "originality": 89,
            "overallScore": 91,
            "issues": []
        }
    }

    # First call returns low_quality, second call returns improved_response
    with patch("app.services.groq_service.GroqService.generate_chat_completion", side_effect=[low_quality_response, improved_response]):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/api/v1/generate", json={
                "platform": "Instagram",
                "contentType": "Reel",
                "idea": "Advanced AI techniques for video creators",
            })
            assert response.status_code == 200
            data = response.json()
            assert "Irresistible" in data["hooks"][0]
            assert data["quality"]["overallScore"] == 91
            assert data["quality"]["retried"] is True

