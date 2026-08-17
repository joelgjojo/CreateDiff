import re
from typing import Any, Dict, List
from app.schemas.generation import GenerationRequest, GenerationResponse
from app.services.prompt_builder import PromptBuilder
from app.services.groq_service import GroqService, GroqServiceException


class GenerationService:
    """Orchestrates content generation, validation, and normalization."""

    @classmethod
    def _sanitize_hashtag(cls, raw: str) -> str:
        tag = raw.strip()
        if not tag:
            return ""
        if not tag.startswith("#"):
            tag = f"#{tag}"
        # Remove internal spaces or illegal chars
        tag = re.sub(r"\s+", "", tag)
        return tag

    @classmethod
    def _normalize_hashtags(cls, raw_list: Any) -> List[str]:
        if not isinstance(raw_list, list):
            return []
        cleaned: List[str] = []
        seen = set()
        for item in raw_list:
            tag = cls._sanitize_hashtag(str(item))
            if tag and tag not in seen:
                seen.add(tag)
                cleaned.append(tag)
        return cleaned

    @classmethod
    async def generate(cls, request: GenerationRequest) -> GenerationResponse:
        system_prompt = PromptBuilder.build_system_prompt(request.creator_context)
        user_prompt = PromptBuilder.build_user_prompt(request)
        
        raw_json = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
        )
        
        # Normalize hooks
        hooks = raw_json.get("hooks") or raw_json.get("hooks_options") or []
        if not isinstance(hooks, list) or not hooks:
            hooks = ["Discover the future of content creation with CreateDiff."]
        hooks_str = [str(h).strip() for h in hooks if str(h).strip()]
        
        # Normalize caption
        caption = str(raw_json.get("caption", "")).strip()
        if not caption:
            caption = "Create something incredible today with CreateDiff."
            
        # Normalize CTAs
        ctas = raw_json.get("ctas")
        if not isinstance(ctas, list):
            cta = raw_json.get("cta")
            ctas = [str(cta).strip()] if cta else ["Save this post for later"]
        ctas_str = [str(c).strip() for c in ctas if str(c).strip()]
        
        # Normalize hashtags
        high_reach = cls._normalize_hashtags(
            raw_json.get("hashtagsHighReach") or raw_json.get("hashtags_high_reach")
        )
        medium_reach = cls._normalize_hashtags(
            raw_json.get("hashtagsMediumReach") or raw_json.get("hashtags_medium_reach")
        )
        niche = cls._normalize_hashtags(
            raw_json.get("hashtagsNiche") or raw_json.get("hashtags_niche")
        )
        
        # Normalize cover text & variations
        cover_text = str(raw_json.get("coverText") or raw_json.get("cover_text") or "CREATOR ESSENTIALS").strip()
        variations = raw_json.get("variations") or []
        if not isinstance(variations, list):
            variations = ["Standard Format", "High-Engagement Variation"]
        variations_str = [str(v).strip() for v in variations if str(v).strip()]
        
        return GenerationResponse(
            hooks=hooks_str,
            caption=caption,
            ctas=ctas_str,
            hashtagsHighReach=high_reach,
            hashtagsMediumReach=medium_reach,
            hashtagsNiche=niche,
            coverText=cover_text,
            variations=variations_str,
        )
