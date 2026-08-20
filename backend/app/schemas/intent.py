from __future__ import annotations

from typing import Optional
from pydantic import BaseModel, Field
from app.schemas.generation import CreatorContext


class IntentExtractRequest(BaseModel):
    prompt: str = Field(..., min_length=2, max_length=1000, description="Raw creator intention or voice prompt")
    creator_context: Optional[CreatorContext] = Field(default=None, description="Creator profile and brand memory context")


class IntentExtractResponse(BaseModel):
    idea: str = Field(..., description="Refined core idea/topic")
    platform: str = Field(default="Instagram", description="Target platform (Instagram, YouTube, LinkedIn, X)")
    content_type: str = Field(default="Reel", description="Content format (Reel, Carousel, Post, Short, Story, Article)")
    audience: str = Field(default="Students & Creators", description="Target audience demographic")
    tone: str = Field(default="Educational", description="Tone and creative voice")
    language: str = Field(default="English", description="Target language/dialect (English, Malayalam, Manglish, Hindi)")
    visual_direction: str = Field(default="Modern high-contrast minimalist", description="Recommended visual concept")
    content_goal: str = Field(default="Audience Growth", description="Strategic objective")
