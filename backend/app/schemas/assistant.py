from __future__ import annotations

from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.generation import CreatorContext


class AssistantSuggestRequest(BaseModel):
    query: Optional[str] = Field(default="What should I create next week?", max_length=500)
    creator_context: Optional[CreatorContext] = Field(default=None)
    has_performance_history: bool = Field(default=False, alias="hasPerformanceHistory")

    model_config = ConfigDict(populate_by_name=True)


class CreatorIdeaSuggestion(BaseModel):
    topic: str
    platform: str
    content_type: str = Field(..., alias="contentType")
    hook_idea: str = Field(..., alias="hookIdea")
    strategic_angle: str = Field(..., alias="strategicAngle")
    why_it_works: str = Field(..., alias="whyItWorks")

    model_config = ConfigDict(populate_by_name=True)


class AssistantSuggestResponse(BaseModel):
    strategy_summary: str = Field(..., alias="strategySummary")
    suggestions: List[CreatorIdeaSuggestion]
    is_cold_start_fallback: bool = Field(default=False, alias="isColdStartFallback")
    source_label: str = Field(default="Personalized Creator AI", alias="sourceLabel")

    model_config = ConfigDict(populate_by_name=True)
