import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import patch
from app.main import app
from app.middleware.rate_limit import limiter


@pytest.mark.asyncio
async def test_campaign_input_validation_empty():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.post("/api/v1/campaign/plan", json={
            "goal": "  ",
            "durationDays": 7,
        })
        assert response.status_code == 422
        data = response.json()
        assert "error" in data
        assert data["error"]["code"] == "INVALID_REQUEST"


@pytest.mark.asyncio
async def test_campaign_success_7_day():
    mock_campaign_response = {
        "campaignTitle": "7-Day AI Growth Blueprint",
        "campaignGoal": "Scale creator authority in AI education",
        "durationDays": 7,
        "platform": "All",
        "strategySummary": "Progressive sprint from AI workflow breakdown to tools and community.",
        "days": [
            {
                "day": 1,
                "title": "5 Free AI Tools Every Student Needs",
                "topic": "Academic AI research tools",
                "platform": "Instagram",
                "contentType": "Reel",
                "hookAngle": "Stop spending 6 hours writing notes.",
                "outline": "• Hook: Show manual note-taking burden\\n• Demo: 3 top AI summarizers\\n• CTA: Save for finals week",
                "strategicIntent": "Viral Discovery",
            },
            {
                "day": 2,
                "title": "My Complete Morning AI Workflow",
                "topic": "Daily productivity system",
                "platform": "Instagram",
                "contentType": "Carousel",
                "hookAngle": "How I get 8 hours of work done before noon.",
                "outline": "• Slide 1: System overview\\n• Slide 2-4: The 3 tools\\n• Slide 5: Daily schedule blueprint",
                "strategicIntent": "Audience Retention",
            }
        ]
    }

    with patch("app.services.groq_service.GroqService.generate_chat_completion", return_value=mock_campaign_response):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/api/v1/campaign/plan", json={
                "goal": "Scale creator authority in AI education",
                "durationDays": 7,
                "platform": "Instagram",
                "creatorContext": {
                    "name": "Joel",
                    "niche": "AI Technology",
                    "contentGoals": ["Audience Growth", "Authority"],
                }
            })
            assert response.status_code == 200
            data = response.json()
            assert data["campaignTitle"] == "7-Day AI Growth Blueprint"
            assert data["durationDays"] == 7
            assert len(data["days"]) == 7
            # Check first day contains all 4 essential fields
            day1 = data["days"][0]
            assert day1["day"] == 1
            assert day1["contentType"] == "Reel"
            assert day1["title"] == "5 Free AI Tools Every Student Needs"
            assert day1["hookAngle"] == "Stop spending 6 hours writing notes."
            assert len(day1["outline"]) > 0
            assert day1["strategicIntent"] == "Viral Discovery"


@pytest.mark.asyncio
async def test_campaign_success_30_day():
    # Build 30 structured mock days
    mock_30_days = [
        {
            "day": i,
            "title": f"Day {i} AI Masterclass Tip",
            "topic": f"Deep dive on AI topic {i}",
            "platform": "Instagram" if i % 2 == 1 else "LinkedIn",
            "contentType": "Reel" if i % 2 == 1 else "Post",
            "hookAngle": f"Here is the single biggest AI mistake creators make on day {i}.",
            "outline": f"• Point 1: The problem with conventional workflows\\n• Point 2: The AI solution\\n• Point 3: Action step",
            "strategicIntent": "Authority Building" if i % 3 == 0 else "Audience Discovery",
        }
        for i in range(1, 31)
    ]

    mock_response = {
        "campaignTitle": "30-Day Omnichannel Creator Masterplan",
        "campaignGoal": "Grow to 10k followers",
        "durationDays": 30,
        "platform": "All",
        "strategySummary": "A 4-phase monthly content blueprint.",
        "days": mock_30_days,
    }

    with patch("app.services.groq_service.GroqService.generate_chat_completion", return_value=mock_response):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            response = await client.post("/api/v1/campaign/plan", json={
                "goal": "Grow to 10k followers",
                "durationDays": 30,
                "platform": "All",
            })
            assert response.status_code == 200
            data = response.json()
            assert len(data["days"]) == 30
            for item in data["days"]:
                assert item["title"] != ""
                assert item["contentType"] != ""
                assert item["hookAngle"] != ""
                assert item["outline"] != ""
                assert item["strategicIntent"] != ""


@pytest.mark.asyncio
async def test_campaign_rate_limiting_enforcement():
    limiter.reset()
    limiter.max_requests = 2
    limiter.window_seconds = 60

    mock_campaign_response = {
        "campaignTitle": "Burst Campaign Test",
        "campaignGoal": "Testing rate limit",
        "durationDays": 7,
        "days": [
            {
                "day": 1,
                "title": "Day 1",
                "topic": "Topic",
                "contentType": "Reel",
                "hookAngle": "Hook",
                "outline": "Outline",
                "strategicIntent": "Discovery",
            }
        ]
    }

    with patch("app.services.groq_service.GroqService.generate_chat_completion", return_value=mock_campaign_response):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
            payload = {
                "goal": "Testing campaign rate limit",
                "durationDays": 7,
            }
            # Request 1 -> 200
            res1 = await client.post("/api/v1/campaign/plan", json=payload)
            assert res1.status_code == 200

            # Request 2 -> 200
            res2 = await client.post("/api/v1/campaign/plan", json=payload)
            assert res2.status_code == 200

            # Request 3 -> 429 Rate Limited
            res3 = await client.post("/api/v1/campaign/plan", json=payload)
            assert res3.status_code == 429
            data = res3.json()
            assert data["error"]["code"] == "RATE_LIMITED"
            assert "Retry-After" in res3.headers

    # Reset limiter after test
    limiter.reset()
    limiter.max_requests = 30
