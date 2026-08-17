import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_security_headers_and_no_secrets_in_errors():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Trigger an invalid route / error
        response = await client.post("/api/v1/generate", json={
            "platform": "Instagram",
            "contentType": "Post",
            "idea": "ab",
        })
        
        # Verify security headers
        assert response.headers["X-Content-Type-Options"] == "nosniff"
        assert response.headers["X-Frame-Options"] == "DENY"
        assert response.headers["Referrer-Policy"] == "no-referrer"
        assert response.headers["Cache-Control"] == "no-store, no-cache, must-revalidate"
        assert "X-Request-ID" in response.headers
        
        # Verify no secrets or tracebacks are exposed in the JSON response
        text = response.text
        assert "gsk_" not in text
        assert "Traceback" not in text
        assert "api.groq.com" not in text
        assert "GROQ_API_KEY" not in text
