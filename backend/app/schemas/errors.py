from typing import Optional
from pydantic import BaseModel, Field


class ErrorDetail(BaseModel):
    code: str = Field(..., description="Stable machine-readable error code")
    message: str = Field(..., description="Human-readable safe error message")
    request_id: Optional[str] = Field(default=None, description="Unique request tracking ID")


class ErrorResponse(BaseModel):
    error: ErrorDetail
