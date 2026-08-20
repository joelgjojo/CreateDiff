from __future__ import annotations

from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.generation import CreatorContext


class VisualDirectionRequest(BaseModel):
    format_type: str = Field(..., description="Target creative asset (e.g. reel_cover, youtube_thumbnail, carousel, creative_pack)")
    topic: str = Field(..., min_length=2, max_length=1000, description="Hook or topic to design for")
    hook: Optional[str] = Field(default=None, max_length=500)
    creator_context: Optional[CreatorContext] = Field(default=None)

    model_config = ConfigDict(populate_by_name=True)


class ReelCoverDirection(BaseModel):
    cover_concept: str = Field(..., description="High-level creative concept for cover")
    headline: str = Field(..., description="Punchy, large text on cover (3-5 words max)")
    composition: str = Field(..., description="Layout placement (e.g. Center subject, text in top third)")
    typography: str = Field(..., description="Font style and weight recommendation")
    color_palette: List[str] = Field(default_factory=list, description="Recommended hex colors")
    visual_hierarchy: str = Field(..., description="Focal point and eye-tracking guide")


class YouTubeThumbnailDirection(BaseModel):
    thumbnail_idea: str = Field(..., description="High-click-through visual concept")
    text_placement: str = Field(..., description="Text placement and wording (<= 4 words)")
    emotion_expression: str = Field(..., description="Creator face or imagery emotion")
    composition_guide: str = Field(..., description="Rule of thirds and background composition")
    attention_strategy: str = Field(..., description="Psychological hook / pattern interrupt")


class CarouselSlideDesign(BaseModel):
    slide_number: int = Field(..., description="1-indexed slide number")
    headline: str = Field(..., description="Slide headline")
    body_text: str = Field(..., description="Key bullet or insight")
    visual_direction: str = Field(..., description="Illustration, diagram, or UI concept for this slide")


class CarouselBlueprint(BaseModel):
    title: str = Field(..., description="Carousel master title")
    total_slides: int = Field(..., description="Number of slides")
    color_palette: List[str] = Field(default_factory=list)
    slides: List[CarouselSlideDesign] = Field(default_factory=list)


class VisualDirectionResponse(BaseModel):
    format_type: str
    reel_cover: Optional[ReelCoverDirection] = None
    youtube_thumbnail: Optional[YouTubeThumbnailDirection] = None
    carousel: Optional[CarouselBlueprint] = None
    design_notes: List[str] = Field(default_factory=list)
