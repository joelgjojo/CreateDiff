import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Assigns or propagates X-Request-ID for every incoming HTTP request."""
    
    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("X-Request-ID")
        if not request_id or len(request_id.strip()) < 4 or len(request_id) > 64:
            request_id = str(uuid.uuid4())
        else:
            request_id = request_id.strip()
            
        request.state.request_id = request_id
        response: Response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response
