import time
from typing import Dict, List
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response
from app.config import settings
from app.schemas.errors import ErrorResponse, ErrorDetail


class InMemoryRateLimiter:
    """
    In-memory IP rate limiter for single-instance / Render free tier deployments.
    Note: Rate limit counters reset upon service restart / cold-start wake.
    """
    def __init__(self, max_requests: int = 30, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._records: Dict[str, List[float]] = {}
        self._last_cleanup = time.time()

    def is_allowed(self, client_ip: str) -> tuple[bool, int]:
        now = time.time()
        self._maybe_cleanup(now)
        
        timestamps = self._records.get(client_ip, [])
        # Filter timestamps within current sliding window
        window_start = now - self.window_seconds
        valid_timestamps = [t for t in timestamps if t > window_start]
        
        if len(valid_timestamps) >= self.max_requests:
            oldest = valid_timestamps[0]
            retry_after = max(1, int(oldest + self.window_seconds - now))
            self._records[client_ip] = valid_timestamps
            return False, retry_after
            
        valid_timestamps.append(now)
        self._records[client_ip] = valid_timestamps
        return True, 0

    def _maybe_cleanup(self, now: float):
        # Run cleanup at most once every 60 seconds
        if now - self._last_cleanup > 60:
            window_start = now - self.window_seconds
            keys_to_remove = []
            for ip, ts_list in self._records.items():
                active = [t for t in ts_list if t > window_start]
                if not active:
                    keys_to_remove.append(ip)
                else:
                    self._records[ip] = active
            for k in keys_to_remove:
                self._records.pop(k, None)
            self._last_cleanup = now

    def reset(self):
        """Testing utility to clear counters."""
        self._records.clear()


limiter = InMemoryRateLimiter(
    max_requests=settings.RATE_LIMIT_REQUESTS,
    window_seconds=settings.RATE_LIMIT_WINDOW_SECONDS,
)


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Enforces rate limits on generation and mutating routes."""
    
    async def dispatch(self, request: Request, call_next) -> Response:
        # Only rate-limit resource-consuming generation endpoints
        is_generation_endpoint = (
            request.url.path.startswith("/api/v1/generate") or request.url.path.startswith("/api/v1/campaign")
        )
        if is_generation_endpoint and request.method == "POST":
            # Extract real client IP (handle proxies if forwarded)
            forwarded = request.headers.get("x-forwarded-for")
            if forwarded:
                client_ip = forwarded.split(",")[0].strip()
            else:
                client_ip = request.client.host if request.client else "unknown"
                
            allowed, retry_after = limiter.is_allowed(client_ip)
            if not allowed:
                request_id = getattr(request.state, "request_id", None)
                error_payload = ErrorResponse(
                    error=ErrorDetail(
                        code="RATE_LIMITED",
                        message=f"Rate limit exceeded. Please try again in {retry_after} seconds.",
                        request_id=request_id,
                    )
                )
                response = JSONResponse(
                    status_code=429,
                    content=error_payload.model_dump(by_alias=True),
                )
                response.headers["Retry-After"] = str(retry_after)
                if request_id:
                    response.headers["X-Request-ID"] = request_id
                return response
                
        return await call_next(request)
