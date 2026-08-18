from typing import Any
from pydantic import BaseModel, Field


class ProfileSyncRequest(BaseModel):
    profile: dict[str, Any] = Field(default_factory=dict)
    content_projects: list[dict[str, Any]] = Field(default_factory=list, alias="contentProjects")
    campaigns: list[dict[str, Any]] = Field(default_factory=list)

    model_config = {"populate_by_name": True}


class ProfileSyncResponse(BaseModel):
    synced: bool
    profile: dict[str, Any]
    content_count: int = Field(default=0, alias="contentCount")
    campaign_count: int = Field(default=0, alias="campaignCount")

    model_config = {"populate_by_name": True}
