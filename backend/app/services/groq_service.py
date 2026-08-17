import asyncio
import json
import logging
import re
from typing import Any, Dict, Optional
import httpx
from app.config import settings

logger = logging.getLogger("creatediff.groq")


class GroqServiceException(Exception):
    """Domain exception for Groq upstream errors."""
    def __init__(self, code: str, message: str, status_code: Optional[int] = None, raw_response: Optional[str] = None):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.raw_response = raw_response
        super().__init__(message)


class GroqService:
    """Production Groq AI Client with Exponential Backoff & Retry Engine."""
    
    @staticmethod
    def _extract_json_block(text: str) -> Optional[str]:
        """Extracts JSON object from text, stripping any markdown code block fences or preamble."""
        clean = text.strip()
        if clean.startswith("```"):
            clean = re.sub(r"^```(?:json)?\s*", "", clean, flags=re.IGNORECASE)
            clean = re.sub(r"\s*```$", "", clean)
            clean = clean.strip()
            
        first_brace = clean.find("{")
        last_brace = clean.rfind("}")
        if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
            return clean[first_brace:last_brace + 1]
        return clean if clean.startswith("{") else None

    @classmethod
    async def generate_chat_completion(
        cls,
        system_prompt: str,
        user_prompt: str,
        temperature: float = 0.7,
    ) -> Dict[str, Any]:
        api_key = settings.GROQ_API_KEY.strip()
        if not api_key:
            raise GroqServiceException(
                code="AI_AUTH_ERROR",
                message="Server-side AI configuration missing.",
                status_code=500,
            )
            
        base_url = settings.GROQ_BASE_URL.rstrip("/")
        endpoint = f"{base_url}/chat/completions" if not base_url.endswith("/chat/completions") else base_url
        model = settings.GROQ_MODEL
        
        payload = {
            "model": model,
            "temperature": temperature,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            "response_format": {"type": "json_object"},
        }
        
        headers = {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": f"Bearer {api_key}",
        }
        
        timeout = httpx.Timeout(
            connect=settings.GROQ_CONNECT_TIMEOUT,
            read=settings.GROQ_READ_TIMEOUT,
            write=10.0,
            pool=settings.GROQ_TOTAL_TIMEOUT,
        )
        
        max_attempts = 3
        last_exception: Optional[Exception] = None
        
        for attempt in range(1, max_attempts + 1):
            if attempt > 1:
                # Exponential backoff: 600ms, 1200ms
                backoff_s = (0.6 * (1 << (attempt - 2)))
                logger.info(f"Groq retry attempt {attempt}/{max_attempts} after {backoff_s:.2f}s backoff")
                await asyncio.sleep(backoff_s)
                
            try:
                async with httpx.AsyncClient(timeout=timeout) as client:
                    response = await client.post(endpoint, json=payload, headers=headers)
                    status_code = response.status_code
                    response_text = response.text
                    
                    if status_code == 200:
                        try:
                            data = response.json()
                            choices = data.get("choices", [])
                            if choices and isinstance(choices, list):
                                message = choices[0].get("message", {})
                                content = message.get("content", "")
                                if content:
                                    json_str = cls._extract_json_block(content)
                                    if json_str:
                                        parsed = json.loads(json_str)
                                        return parsed
                        except Exception as parse_err:
                            logger.error(f"Failed to parse Groq response JSON: {parse_err}")
                            raise GroqServiceException(
                                code="AI_INVALID_RESPONSE",
                                message="The AI model returned an unexpected output format. Please retry.",
                                status_code=200,
                                raw_response=response_text[:500],
                            )
                            
                        raise GroqServiceException(
                            code="AI_INVALID_RESPONSE",
                            message="Empty content received from AI provider.",
                            status_code=200,
                            raw_response=response_text[:500],
                        )
                        
                    # Handle Non-200 Responses
                    if status_code in (401, 403):
                        logger.error(f"Groq authentication error: HTTP {status_code}")
                        raise GroqServiceException(
                            code="AI_AUTH_ERROR",
                            message="Invalid AI provider credentials.",
                            status_code=status_code,
                            raw_response=response_text[:300],
                        )
                        
                    if status_code == 400:
                        logger.warning(f"Groq 400 Bad Request: {response_text[:300]}")
                        raise GroqServiceException(
                            code="INVALID_REQUEST",
                            message="Invalid generation request parameters.",
                            status_code=400,
                            raw_response=response_text[:300],
                        )
                        
                    if status_code == 429:
                        retry_after = response.headers.get("retry-after", "5")
                        logger.warning(f"Groq rate limit exceeded (HTTP 429). Retry-after: {retry_after}")
                        # Retryable with backoff if attempts remain
                        last_exception = GroqServiceException(
                            code="RATE_LIMITED",
                            message=f"AI service temporarily busy. Please retry shortly.",
                            status_code=429,
                            raw_response=response_text[:300],
                        )
                        continue
                        
                    # Transient server error (500, 502, 503, 504) -> retry eligible
                    logger.warning(f"Groq transient upstream error HTTP {status_code}")
                    last_exception = GroqServiceException(
                        code="AI_UPSTREAM_ERROR",
                        message="AI provider temporarily unavailable. Please retry shortly.",
                        status_code=status_code,
                        raw_response=response_text[:300],
                    )
                    
            except httpx.TimeoutException as e:
                logger.warning(f"Groq request timeout on attempt {attempt}: {e}")
                last_exception = GroqServiceException(
                    code="AI_TIMEOUT",
                    message="AI generation timed out. Please retry.",
                )
            except httpx.RequestError as e:
                logger.warning(f"Groq network error on attempt {attempt}: {e}")
                last_exception = GroqServiceException(
                    code="AI_UPSTREAM_ERROR",
                    message="Network error connecting to AI provider.",
                )
            except GroqServiceException as e:
                if e.code in ("AI_AUTH_ERROR", "INVALID_REQUEST", "AI_INVALID_RESPONSE"):
                    raise  # Non-retryable
                last_exception = e
                
        if last_exception:
            raise last_exception
            
        raise GroqServiceException(
            code="INTERNAL_ERROR",
            message="Unable to complete generation after retries.",
        )
