import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.api.v1.visual import _heuristic_visual_direction
from app.schemas.visual import VisualDirectionRequest


def test_heuristic_reel_cover():
    req = VisualDirectionRequest(format_type="reel_cover", topic="AI Tools for Designers", hook="STOP DOING THIS")
    res = _heuristic_visual_direction(req)
    assert res.format_type == "reel_cover"
    assert res.reel_cover is not None
    assert "STOP DOING THIS" in res.reel_cover.headline


def test_heuristic_youtube_thumbnail():
    req = VisualDirectionRequest(format_type="youtube_thumbnail", topic="How I Made 100k", hook="THE SECRET")
    res = _heuristic_visual_direction(req)
    assert res.format_type == "youtube_thumbnail"
    assert res.youtube_thumbnail is not None
    assert res.youtube_thumbnail.attention_strategy is not None


def test_heuristic_carousel():
    req = VisualDirectionRequest(format_type="carousel", topic="5 Coding Habits", hook="LEVEL UP")
    res = _heuristic_visual_direction(req)
    assert res.format_type == "carousel"
    assert res.carousel is not None
    assert len(res.carousel.slides) >= 3


@pytest.mark.asyncio
async def test_visual_direction_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "format_type": "reel_cover",
            "topic": "5 AI Tools",
            "hook": "THESE 5 TOOLS CHANGE EVERYTHING"
        }
        response = await client.post("/api/v1/visual/direction", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "format_type" in data
        assert "reel_cover" in data or "design_notes" in data
