from __future__ import annotations

from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class ContentFeedbackRequest(BaseModel):
    content_id: str = Field(..., alias="contentId", description="Unique content or generation ID")
    platform: str = Field(..., max_length=50)
    content_type: str = Field(..., max_length=50, alias="contentType")
    feedback: str = Field(..., description="'worked' or 'did_not_work'")
    notes: Optional[str] = Field(default=None, max_length=500)

    model_config = ConfigDict(populate_by_name=True)


class ContentFeedbackResponse(BaseModel):
    status: str = "recorded"
    content_id: str = Field(..., alias="contentId")
    feedback: str
    message: str = "Performance feedback stored successfully"

    model_config = ConfigDict(populate_by_name=True)
