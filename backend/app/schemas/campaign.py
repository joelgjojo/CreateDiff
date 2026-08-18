from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.generation import CreatorContext


class CampaignDayItem(BaseModel):
    """Single-day content plan item within a creator campaign."""
    day: int = Field(..., ge=1, le=31, description="Day index in the campaign")
    title: str = Field(..., min_length=2, max_length=200, description="Punchy content title")
    topic: str = Field(..., min_length=2, max_length=500, description="Specific content theme or topic")
    platform: str = Field(default="Instagram", max_length=50, description="Recommended platform")
    content_type: str = Field(default="Reel", max_length=50, alias="contentType", description="Recommended format")
    hook_angle: str = Field(default="", max_length=300, alias="hookAngle", description="Primary viral hook angle or question")
    outline: str = Field(default="", max_length=1000, description="Structured 3-bullet execution outline")
    strategic_intent: str = Field(default="Audience Growth", max_length=100, alias="strategicIntent", description="Strategic purpose (e.g. Discovery, Engagement, Authority, Conversion)")

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)


class CampaignPlanRequest(BaseModel):
    """Creator campaign plan generation payload."""
    goal: str = Field(..., min_length=3, max_length=1000, description="Campaign objective or core theme (e.g., 'Grow AI education page')")
    duration_days: int = Field(default=7, ge=1, le=30, alias="durationDays", description="Campaign duration in days (e.g. 7, 14, 30)")
    platform: Optional[str] = Field(default="All", max_length=50, description="Target platform or 'All'")
    niche: Optional[str] = Field(default=None, max_length=100, description="Optional niche override")
    creator_context: Optional[CreatorContext] = Field(default=None, alias="creatorContext")

    model_config = ConfigDict(populate_by_name=True)


class CampaignPlanResponse(BaseModel):
    """Validated multi-day campaign plan returned to Flutter."""
    id: str = Field(..., description="Unique campaign ID")
    campaign_title: str = Field(..., alias="campaignTitle", description="Engaging campaign series title")
    campaign_goal: str = Field(..., alias="campaignGoal", description="Original creator goal")
    duration_days: int = Field(..., alias="durationDays", description="Total campaign duration in days")
    platform: str = Field(default="All", description="Targeted platform")
    strategy_summary: str = Field(default="", alias="strategySummary", description="High-level narrative strategy summary")
    days: List[CampaignDayItem] = Field(..., min_length=1, description="Day-by-day planned content schedule")

    model_config = ConfigDict(populate_by_name=True, serialize_by_alias=True)
