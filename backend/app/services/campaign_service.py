import logging
import time
from typing import Any, Dict, List
from app.schemas.campaign import (
    CampaignPlanRequest,
    CampaignPlanResponse,
    CampaignDayItem,
)
from app.services.prompt_builder import PromptBuilder
from app.services.groq_service import GroqService

logger = logging.getLogger("creatediff.campaign")


class CampaignService:
    """Orchestrates AI campaign planning, structure normalization, and multi-day sequencing."""

    @classmethod
    def _normalize_day_item(cls, raw: Any, index: int, default_platform: str = "Instagram") -> CampaignDayItem:
        if isinstance(raw, dict):
            day_num = int(raw.get("day") or index)
            title = str(raw.get("title") or f"Day {index} Creator Spotlight").strip()
            topic = str(raw.get("topic") or title).strip()
            platform = str(raw.get("platform") or default_platform).strip()
            content_type = str(raw.get("contentType") or raw.get("content_type") or "Reel").strip()
            hook = str(raw.get("hookAngle") or raw.get("hook_angle") or raw.get("hook") or f"Here is the truth about {topic}...").strip()
            outline = str(raw.get("outline") or raw.get("description") or f"• Hook & opening statement\\n• Core value & walkthrough\\n• Actionable CTA").strip()
            intent = str(raw.get("strategicIntent") or raw.get("strategic_intent") or "Audience Growth").strip()

            return CampaignDayItem(
                day=day_num,
                title=title,
                topic=topic,
                platform=platform,
                contentType=content_type,
                hookAngle=hook,
                outline=outline,
                strategicIntent=intent,
            )

        return CampaignDayItem(
            day=index,
            title=f"Day {index} Content Strategy",
            topic="Creator core topic",
            platform=default_platform,
            contentType="Reel",
            hookAngle="Transform your creator workflow today.",
            outline="• Problem statement\\n• Actionable insight\\n• Save/Share CTA",
            strategicIntent="Audience Discovery",
        )

    @classmethod
    async def plan_campaign(cls, request: CampaignPlanRequest) -> CampaignPlanResponse:
        system_prompt = PromptBuilder.build_campaign_system_prompt(request.creator_context)
        user_prompt = PromptBuilder.build_campaign_user_prompt(request)

        raw_json = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=0.7,
        )

        title = str(raw_json.get("campaignTitle") or raw_json.get("campaign_title") or f"{request.duration_days}-Day Creator Acceleration Campaign").strip()
        goal = str(raw_json.get("campaignGoal") or raw_json.get("campaign_goal") or request.goal).strip()
        platform = str(raw_json.get("platform") or request.platform or "All").strip()
        summary = str(raw_json.get("strategySummary") or raw_json.get("strategy_summary") or f"A structured {request.duration_days}-day content sprint driving engagement and creator authority.").strip()

        raw_days = raw_json.get("days") or raw_json.get("schedule") or []
        if not isinstance(raw_days, list):
            raw_days = []

        normalized_days: List[CampaignDayItem] = []
        for i in range(1, request.duration_days + 1):
            matching_raw = None
            if i - 1 < len(raw_days):
                matching_raw = raw_days[i - 1]
            elif raw_days:
                # Find by day key if available
                matching_raw = next((d for d in raw_days if isinstance(d, dict) and (d.get("day") == i or d.get("day") == str(i))), None)

            item = cls._normalize_day_item(
                matching_raw,
                index=i,
                default_platform=platform if platform != "All" else "Instagram",
            )
            normalized_days.append(item)

        campaign_id = f"camp_{int(time.time() * 1000)}"

        return CampaignPlanResponse(
            id=campaign_id,
            campaignTitle=title,
            campaignGoal=goal,
            durationDays=request.duration_days,
            platform=platform,
            strategySummary=summary,
            days=normalized_days,
        )
