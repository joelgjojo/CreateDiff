import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import patch
from app.main import app
from app.middleware.rate_limit import limiter


@pytest.mark.asyncio
async def test_rate_limiting_enforcement():
    limiter.reset()
    # Temporarily set max_requests to 2 for test
    limiter.max_requests = 2
    limiter.window_seconds = 60

    mock_ai_response = {
        "hooks": ["Hook 1"],
        "caption": "Caption",
        "ctas": ["CTA"],
        "hashtagsHighReach": ["#Tag"],
        "coverText": "COVER",
        "variations": ["Var 1"],
    }

    with patch("app.services.groq_service.GroqService.generate_chat_completion", return_value=mock_ai_response):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            payload = {
                "platform": "Instagram",
                "contentType": "Post",
                "idea": "Testing rate limit",
            }
            # Request 1 -> 200
            res1 = await client.post("/api/v1/generate", json=payload)
            assert res1.status_code == 200

            # Request 2 -> 200
            res2 = await client.post("/api/v1/generate", json=payload)
            assert res2.status_code == 200

            # Request 3 -> 429 Rate Limited
            res3 = await client.post("/api/v1/generate", json=payload)
            assert res3.status_code == 429
            data = res3.json()
            assert data["error"]["code"] == "RATE_LIMITED"
            assert "Retry-After" in res3.headers

    # Reset limiter after test
    limiter.reset()
    limiter.max_requests = 30
