from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict


class CreatorContext(BaseModel):
    """Untrusted creator memory context sent by client."""
    name: Optional[str] = Field(default="", max_length=100)
    username: Optional[str] = Field(default="", max_length=100)
    niche: Optional[str] = Field(default="Technology", max_length=100)
    category: Optional[str] = Field(default="Content Creator", max_length=100)
    target_audience: Optional[str] = Field(default="", max_length=250)
    preferred_platforms: List[str] = Field(default_factory=list, alias="preferredPlatforms")
    primary_language: Optional[str] = Field(default="English", max_length=50)
    secondary_language: Optional[str] = Field(default="", max_length=50)
    tone: Optional[str] = Field(default="Educational", max_length=100)
    content_goals: List[str] = Field(default_factory=list, alias="contentGoals")
    content_style: Optional[str] = Field(default="", max_length=250)
    brand_description: Optional[str] = Field(default="", max_length=500)
    preferred_cta_style: Optional[str] = Field(default="Direct", max_length=100)
    emoji_usage: Optional[str] = Field(default="moderate", max_length=50)

    model_config = ConfigDict(populate_by_name=True)


class GenerationRequest(BaseModel):
    """Client generation payload for CreateDiff AI Content Studio."""
    platform: str = Field(..., min_length=2, max_length=50, description="Platform (e.g. Instagram, YouTube, LinkedIn)")
    content_type: str = Field(..., min_length=2, max_length=50, alias="contentType", description="Format (e.g. Reel, Carousel, Post)")
    idea: str = Field(..., min_length=3, max_length=2000, description="Creator core concept or topic")
    override_tone: Optional[str] = Field(default=None, max_length=100, alias="overrideTone")
    override_language: Optional[str] = Field(default=None, max_length=50, alias="overrideLanguage")
    override_length: Optional[str] = Field(default=None, max_length=50, alias="overrideLength")
    creator_context: Optional[CreatorContext] = Field(default=None, alias="creatorContext")

    model_config = ConfigDict(populate_by_name=True)


class CarouselSlide(BaseModel):
    """Individual slide blueprint for carousel formats."""
    slide_number: int = Field(default=1, alias="slideNumber")
    headline: str = Field(default="")
    body_text: str = Field(default="", alias="bodyText")
    visual_cue: str = Field(default="", alias="visualCue")

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)


class VisualIntelligenceResponse(BaseModel):
    """Creative direction and visual styling recommendations."""
    visual_style: str = Field(default="Modern Creator Minimalist", alias="visualStyle")
    layout_suggestion: str = Field(default="Bold top headline with focal graphic", alias="layoutSuggestion")
    thumbnail_direction: str = Field(default="High-contrast typography with creator reaction", alias="thumbnailDirection")
    typography_suggestion: str = Field(default="Geometric sans-serif with tracked caps", alias="typographySuggestion")
    color_palette: List[str] = Field(default_factory=list, alias="colorPalette")
    design_mood: str = Field(default="High energy, educational, authentic", alias="designMood")

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)


class QualityMetadataResponse(BaseModel):
    """Single-call AI quality evaluation scores and retry telemetry."""
    hook_strength: int = Field(default=85, ge=0, le=100, alias="hookStrength")
    platform_fit: int = Field(default=88, ge=0, le=100, alias="platformFit")
    audience_fit: int = Field(default=86, ge=0, le=100, alias="audienceFit")
    originality: int = Field(default=84, ge=0, le=100, alias="originality")
    overall_score: int = Field(default=86, ge=0, le=100, alias="overallScore")
    issues: List[str] = Field(default_factory=list)
    retried: bool = Field(default=False)

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)


class GenerationResponse(BaseModel):
    """Validated structured content pack delivered to the Flutter client."""
    hooks: List[str] = Field(..., min_length=1, max_length=10, description="High-converting hook variations")
    caption: str = Field(..., min_length=1, description="Full formatted caption with line breaks")
    ctas: List[str] = Field(default_factory=list, description="Actionable calls to action")
    hashtags_high_reach: List[str] = Field(default_factory=list, alias="hashtagsHighReach", description="5 broad discovery tags")
    hashtags_medium_reach: List[str] = Field(default_factory=list, alias="hashtagsMediumReach", description="4 category tags")
    hashtags_niche: List[str] = Field(default_factory=list, alias="hashtagsNiche", description="3 community niche tags")
    cover_text: str = Field(default="", alias="coverText", description="High-contrast title text for graphic slides")
    variations: List[str] = Field(default_factory=list, description="Format variation blueprints")
    # Platform-specific fields
    script: Optional[str] = Field(default=None, description="Reel / YouTube Short script with timestamps")
    scene_directions: List[str] = Field(default_factory=list, alias="sceneDirections", description="Scene visual & camera directions")
    slides: List[CarouselSlide] = Field(default_factory=list, description="Carousel slide structures")
    title_options: List[str] = Field(default_factory=list, alias="titleOptions", description="Platform title variations")
    thumbnail_text: Optional[str] = Field(default=None, alias="thumbnailText", description="Suggested short text for thumbnail")
    story_prompts: List[str] = Field(default_factory=list, alias="storyPrompts", description="Interactive poll / question sticker ideas")
    # Intelligence layers
    visual_intelligence: Optional[VisualIntelligenceResponse] = Field(default=None, alias="visualIntelligence")
    quality: Optional[QualityMetadataResponse] = Field(default=None)

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)
