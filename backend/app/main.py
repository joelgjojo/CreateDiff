import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.exceptions import HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.config import settings
from app.api.v1.router import api_v1_router
from app.middleware.request_id import RequestIDMiddleware
from app.middleware.security import SecurityHeadersMiddleware
from app.middleware.rate_limit import RateLimitMiddleware
from app.utils.logging import LoggingMiddleware, logger
from app.schemas.errors import ErrorResponse, ErrorDetail
from app.services.groq_service import GroqServiceException
from app.services.analytics import SentryReporter
from app.db.database import init_db

@asynccontextmanager
async def lifespan(application: FastAPI):
    await init_db()
    logger.info("Registered API routes:")
    for route in sorted(application.routes, key=lambda item: (item.path, sorted(item.methods or []))):
        methods = ",".join(sorted(route.methods or []))
        logger.info("%s %s", methods, route.path)
    yield


app = FastAPI(
    title="CreateDiff API",
    description="Secure Production AI Engine Backend for CreateDiff Studio",
    version="1.0.0",
    docs_url="/docs" if not settings.is_production else None,
    redoc_url=None,
    lifespan=lifespan,
)


@app.get("/")
def root():
    return {
        "name": "CreateDiff API",
        "status": "running",
    }


# 1. Security & Request ID Middleware
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(LoggingMiddleware)
app.add_middleware(RateLimitMiddleware)
app.add_middleware(RequestIDMiddleware)

# 2. CORS Configuration (Explicit origins, never wildcard * in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins if settings.cors_origins else (["*"] if not settings.is_production else []),
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Request-ID", "Retry-After"],
)

# 3. Include API v1 Router
app.include_router(api_v1_router, prefix="/api/v1")
error_reporter = SentryReporter()


# 4. Global Exception Handlers (Always structured JSON, never raw stack traces)
@app.exception_handler(GroqServiceException)
async def groq_service_exception_handler(request: Request, exc: GroqServiceException):
    request_id = getattr(request.state, "request_id", None)
    status_code = exc.status_code if exc.status_code and 400 <= exc.status_code < 600 else 500
    
    # Map domain errors to stable status codes
    if exc.code == "INVALID_REQUEST":
        status_code = 400
    elif exc.code == "AI_AUTH_ERROR":
        status_code = 500  # Mask upstream auth as server config issue
    elif exc.code == "RATE_LIMITED":
        status_code = 429
    elif exc.code == "AI_TIMEOUT":
        status_code = 504
        
    error_payload = ErrorResponse(
        error=ErrorDetail(
            code=exc.code,
            message=exc.message,
            request_id=request_id,
        )
    )
    response = JSONResponse(
        status_code=status_code,
        content=error_payload.model_dump(by_alias=True),
    )
    if request_id:
        response.headers["X-Request-ID"] = request_id
    return response


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    request_id = getattr(request.state, "request_id", None)
    detail = exc.detail if isinstance(exc.detail, dict) else {"code": "HTTP_ERROR", "message": str(exc.detail)}
    payload = ErrorResponse(error=ErrorDetail(code=detail.get("code", "HTTP_ERROR"), message=detail.get("message", "Request failed"), request_id=request_id))
    return JSONResponse(status_code=exc.status_code, content=payload.model_dump(by_alias=True), headers={"X-Request-ID": request_id} if request_id else None)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    request_id = getattr(request.state, "request_id", None)
    # Extract clean human-friendly validation error message
    err_msgs = []
    for err in exc.errors():
        field = " -> ".join(str(loc) for loc in err.get("loc", []))
        msg = err.get("msg", "Invalid value")
        err_msgs.append(f"{field}: {msg}")
    clean_msg = "; ".join(err_msgs) if err_msgs else "Invalid request payload."
    
    error_payload = ErrorResponse(
        error=ErrorDetail(
            code="INVALID_REQUEST",
            message=clean_msg,
            request_id=request_id,
        )
    )
    return JSONResponse(
        status_code=422,
        content=error_payload.model_dump(by_alias=True),
        headers={"X-Request-ID": request_id} if request_id else None,
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    request_id = getattr(request.state, "request_id", None)
    logger.exception("Unhandled server error [request_id=%s, type=%s]", request_id, type(exc).__name__)
    error_reporter.capture_exception(exc, request_id=request_id, path=str(request.url.path))
    
    error_payload = ErrorResponse(
        error=ErrorDetail(
            code="INTERNAL_ERROR",
            message="An unexpected server error occurred. Please retry shortly.",
            request_id=request_id,
        )
    )
    response = JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=error_payload.model_dump(by_alias=True),
    )
    if request_id:
        response.headers["X-Request-ID"] = request_id
    return response
