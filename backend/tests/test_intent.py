import pytest
from httpx import AsyncClient
from app.api.v1.intent import _heuristic_extract


def test_heuristic_intent_extraction_reel():
    res = _heuristic_extract("Make an Instagram reel about top AI tools for college students")
    assert res.platform == "Instagram"
    assert res.content_type == "Reel"
    assert "students" in res.audience.lower()
    assert res.language == "English"


def test_heuristic_intent_extraction_malayalam():
    res = _heuristic_extract("Create a Malayalam YouTube short explaining crypto")
    assert res.platform == "YouTube"
    assert res.content_type == "Short"
    assert res.language == "Malayalam"


def test_heuristic_intent_extraction_carousel_linkedin():
    res = _heuristic_extract("Write a LinkedIn carousel on 5 productivity habits")
    assert res.platform == "LinkedIn"
    assert res.content_type == "Carousel"


from app.main import app
from httpx import ASGITransport


@pytest.mark.asyncio
async def test_intent_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "prompt": "Make an Instagram reel about top AI tools for students",
            "creator_context": {
                "niche": "Tech",
                "tone": "Educational",
                "primaryLanguage": "English"
            }
        }
        response = await client.post("/api/v1/intent/extract", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "idea" in data
        assert "platform" in data
        assert "contentType" in data or "content_type" in data
