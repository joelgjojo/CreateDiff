import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.v1.assistant import _heuristic_assistant_suggestions
from app.schemas.assistant import AssistantSuggestRequest


def test_heuristic_assistant_cold_start():
    req = AssistantSuggestRequest(hasPerformanceHistory=False)
    res = _heuristic_assistant_suggestions(req)
    assert res.is_cold_start_fallback is True
    assert res.source_label == "Profile-based starting suggestions"
    assert len(res.suggestions) == 3


def test_heuristic_assistant_with_history():
    req = AssistantSuggestRequest(hasPerformanceHistory=True)
    res = _heuristic_assistant_suggestions(req)
    assert res.is_cold_start_fallback is False
    assert len(res.suggestions) == 3


@pytest.mark.asyncio
async def test_assistant_suggest_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "query": "What should I create next week?",
            "hasPerformanceHistory": False,
            "creator_context": {
                "niche": "AI Tools",
                "tone": "Educational"
            }
        }
        response = await client.post("/api/v1/assistant/suggest", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "strategySummary" in data or "strategy_summary" in data
        assert "suggestions" in data
        assert len(data["suggestions"]) >= 1


@pytest.mark.asyncio
async def test_feedback_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "contentId": "cnt_12345",
            "platform": "Instagram",
            "contentType": "Reel",
            "feedback": "worked",
            "notes": "Generated 15k views"
        }
        response = await client.post("/api/v1/feedback", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "recorded"
        assert data["contentId"] == "cnt_12345"


@pytest.mark.asyncio
async def test_feedback_invalid_rejection():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "contentId": "cnt_invalid",
            "platform": "Instagram",
            "contentType": "Reel",
            "feedback": "invalid_value",
        }
        response = await client.post("/api/v1/feedback", json=payload)
        assert response.status_code == 400


@pytest.mark.asyncio
async def test_get_feedback_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/feedback")
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
