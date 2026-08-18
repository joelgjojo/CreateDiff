import logging
import re
import time
from typing import Any, Dict, List, Optional
from app.schemas.generation import (
    GenerationRequest,
    GenerationResponse,
    CarouselSlide,
    VisualIntelligenceResponse,
    QualityMetadataResponse,
)
from app.services.prompt_builder import PromptBuilder
from app.services.groq_service import GroqService, GroqServiceException

logger = logging.getLogger("creatediff.generation")


class GenerationService:
    """Orchestrates content generation, validation, normalization, and single-call quality improvement."""

    @classmethod
    def _sanitize_hashtag(cls, raw: str) -> str:
        tag = raw.strip()
        if not tag:
            return ""
        if not tag.startswith("#"):
            tag = f"#{tag}"
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
    def _normalize_slides(cls, raw_slides: Any) -> List[CarouselSlide]:
        if not isinstance(raw_slides, list):
            return []
        slides: List[CarouselSlide] = []
        for i, item in enumerate(raw_slides, start=1):
            if isinstance(item, dict):
                slide_num = int(item.get("slideNumber") or item.get("slide_number") or i)
                headline = str(item.get("headline") or "").strip()
                body_text = str(item.get("bodyText") or item.get("body_text") or item.get("body") or "").strip()
                visual_cue = str(item.get("visualCue") or item.get("visual_cue") or "").strip()
                slides.append(
                    CarouselSlide(
                        slideNumber=slide_num,
                        headline=headline,
                        bodyText=body_text,
                        visualCue=visual_cue,
                    )
                )
            elif isinstance(item, str) and item.strip():
                slides.append(
                    CarouselSlide(
                        slideNumber=i,
                        headline=f"Slide {i}",
                        bodyText=item.strip(),
                        visualCue="Graphic illustration",
                    )
                )
        return slides

    @classmethod
    def _normalize_visual_intelligence(cls, raw_vi: Any) -> VisualIntelligenceResponse:
        if isinstance(raw_vi, dict):
            style = str(raw_vi.get("visualStyle") or raw_vi.get("visual_style") or "Modern Dark Tech Minimalist").strip()
            layout = str(raw_vi.get("layoutSuggestion") or raw_vi.get("layout_suggestion") or "Bold title top with floating cards").strip()
            thumb = str(raw_vi.get("thumbnailDirection") or raw_vi.get("thumbnail_direction") or "High contrast reaction with bold text").strip()
            typo = str(raw_vi.get("typographySuggestion") or raw_vi.get("typography_suggestion") or "Space Grotesk / Modern Sans").strip()
            palette = raw_vi.get("colorPalette") or raw_vi.get("color_palette") or ["#080A0F", "#4F43F9", "#7066FF", "#00B894"]
            if not isinstance(palette, list) or not palette:
                palette = ["#080A0F", "#4F43F9", "#7066FF", "#00B894"]
            palette_str = [str(c).strip() for c in palette if str(c).strip()]
            mood = str(raw_vi.get("designMood") or raw_vi.get("design_mood") or "High energy, authoritative, educational").strip()
            return VisualIntelligenceResponse(
                visualStyle=style,
                layoutSuggestion=layout,
                thumbnailDirection=thumb,
                typographySuggestion=typo,
                colorPalette=palette_str,
                designMood=mood,
            )
        return VisualIntelligenceResponse()

    @classmethod
    def _normalize_quality(cls, raw_q: Any, retried: bool = False) -> QualityMetadataResponse:
        if isinstance(raw_q, dict):
            try:
                hook = int(raw_q.get("hookStrength") or raw_q.get("hook_strength") or 85)
                plat = int(raw_q.get("platformFit") or raw_q.get("platform_fit") or 88)
                aud = int(raw_q.get("audienceFit") or raw_q.get("audience_fit") or 86)
                orig = int(raw_q.get("originality") or 84)
                overall = int(raw_q.get("overallScore") or raw_q.get("overall_score") or int((hook + plat + aud + orig) / 4))
                issues = raw_q.get("issues") or []
                if not isinstance(issues, list):
                    issues = [str(issues)] if issues else []
                issues_str = [str(issue).strip() for issue in issues if str(issue).strip()]
                return QualityMetadataResponse(
                    hookStrength=max(0, min(100, hook)),
                    platformFit=max(0, min(100, plat)),
                    audienceFit=max(0, min(100, aud)),
                    originality=max(0, min(100, orig)),
                    overallScore=max(0, min(100, overall)),
                    issues=issues_str,
                    retried=retried,
                )
            except Exception:
                pass
        return QualityMetadataResponse(retried=retried)

    @classmethod
    def _parse_and_normalize(cls, raw_json: Dict[str, Any], retried: bool = False) -> GenerationResponse:
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

        # Platform-specific fields
        script = raw_json.get("script")
        script_str = str(script).strip() if script else None

        scene_dirs = raw_json.get("sceneDirections") or raw_json.get("scene_directions") or []
        if not isinstance(scene_dirs, list):
            scene_dirs = []
        scene_dirs_str = [str(s).strip() for s in scene_dirs if str(s).strip()]

        slides = cls._normalize_slides(raw_json.get("slides"))

        title_opts = raw_json.get("titleOptions") or raw_json.get("title_options") or []
        if not isinstance(title_opts, list):
            title_opts = []
        title_opts_str = [str(t).strip() for t in title_opts if str(t).strip()]

        thumb_text = raw_json.get("thumbnailText") or raw_json.get("thumbnail_text")
        thumb_text_str = str(thumb_text).strip() if thumb_text else None

        story_prompts = raw_json.get("storyPrompts") or raw_json.get("story_prompts") or []
        if not isinstance(story_prompts, list):
            story_prompts = []
        story_prompts_str = [str(sp).strip() for sp in story_prompts if str(sp).strip()]

        # Intelligence layers
        visual_intel = cls._normalize_visual_intelligence(
            raw_json.get("visualIntelligence") or raw_json.get("visual_intelligence")
        )
        quality = cls._normalize_quality(
            raw_json.get("quality"),
            retried=retried,
        )

        return GenerationResponse(
            hooks=hooks_str,
            caption=caption,
            ctas=ctas_str,
            hashtagsHighReach=high_reach,
            hashtagsMediumReach=medium_reach,
            hashtagsNiche=niche,
            coverText=cover_text,
            variations=variations_str,
            script=script_str,
            sceneDirections=scene_dirs_str,
            slides=slides,
            titleOptions=title_opts_str,
            thumbnailText=thumb_text_str,
            storyPrompts=story_prompts_str,
            visualIntelligence=visual_intel,
            quality=quality,
        )

    @classmethod
    async def generate(cls, request: GenerationRequest) -> GenerationResponse:
        system_prompt = PromptBuilder.build_system_prompt(request.creator_context)
        user_prompt = PromptBuilder.build_user_prompt(request)

        start_time = time.time()
        raw_json = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
        )
        duration_ms = int((time.time() - start_time) * 1000)

        initial_response = cls._parse_and_normalize(raw_json, retried=False)
        quality = initial_response.quality

        # Single-call quality threshold evaluation:
        # If overall score < 70, or hook_strength < 65, or platform_fit < 65, trigger MAXIMUM ONE improvement retry.
        needs_retry = False
        failed_categories: List[str] = []
        if quality:
            if quality.overall_score < 70:
                needs_retry = True
                failed_categories.append(f"overallScore={quality.overall_score}")
            if quality.hook_strength < 65:
                needs_retry = True
                failed_categories.append(f"hookStrength={quality.hook_strength}")
            if quality.platform_fit < 65:
                needs_retry = True
                failed_categories.append(f"platformFit={quality.platform_fit}")
            if quality.originality < 65:
                needs_retry = True
                failed_categories.append(f"originality={quality.originality}")

        if needs_retry:
            logger.info(
                f"[Quality Retry] Triggering 1x server refinement. Failed criteria: {failed_categories}. Initial latency: {duration_ms}ms"
            )
            try:
                retry_user_prompt = PromptBuilder.build_quality_retry_prompt(
                    original_output=raw_json,
                    issues=quality.issues if quality else failed_categories,
                )
                retry_start = time.time()
                retried_json = await GroqService.generate_chat_completion(
                    system_prompt=system_prompt,
                    user_prompt=retry_user_prompt,
                    temperature=0.6,
                )
                retry_duration_ms = int((time.time() - retry_start) * 1000)
                logger.info(f"[Quality Retry] Completed refinement in {retry_duration_ms}ms")
                return cls._parse_and_normalize(retried_json, retried=True)
            except Exception as e:
                logger.warning(f"[Quality Retry] Refinement failed ({e}), returning initial parsed result safely.")
                return initial_response

        return initial_response

