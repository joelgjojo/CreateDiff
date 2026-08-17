from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = Field(default="healthy", description="Service health indicator")
    service: str = Field(default="creatediff-api", description="Service identifier")
    version: str = Field(default="1.0.0", description="API version")


class ReadinessResponse(BaseModel):
    status: str = Field(default="ready", description="Service readiness indicator")
    service: str = Field(default="creatediff-api", description="Service identifier")
    version: str = Field(default="1.0.0", description="API version")
    ai_configured: bool = Field(..., description="Whether server-side AI provider is configured")
