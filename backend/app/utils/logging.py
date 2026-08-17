import json
import logging
import time
from typing import Optional
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

# Configure root logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("creatediff.api")


class LoggingMiddleware(BaseHTTPMiddleware):
    """Logs incoming requests and outgoing responses safely without exposing secrets or private payloads."""
    
    async def dispatch(self, request: Request, call_next) -> Response:
        start_time = time.time()
        request_id = getattr(request.state, "request_id", "-")
        
        response: Response = await call_next(request)
        latency_ms = int((time.time() - start_time) * 1000)
        
        log_data = {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "latency_ms": latency_ms,
        }
        
        # Don't log spam for health checks unless it's an error
        if request.url.path in ("/api/v1/health", "/api/v1/readiness") and response.status_code < 400:
            return response
            
        logger.info(json.dumps(log_data))
        return response
