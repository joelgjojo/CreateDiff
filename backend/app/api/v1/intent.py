from __future__ import annotations

import json
import logging
import re
from typing import Any, Optional
from fastapi import APIRouter, Depends, status
from app.schemas.intent import IntentExtractRequest, IntentExtractResponse
from app.services.auth import AuthenticatedUser, get_current_user
from app.services.groq_service import GroqService

logger = logging.getLogger("creatediff.intent")
router = APIRouter(tags=["Intent"])


def _heuristic_extract(prompt: str, context: Optional[Any] = None) -> IntentExtractResponse:
    """Fast deterministic heuristic parser when LLM is unavailable or for instant response."""
    lower = prompt.lower()

    # Platform detection
    platform = "Instagram"
    if "youtube" in lower or "yt" in lower:
        platform = "YouTube"
    elif "linkedin" in lower:
        platform = "LinkedIn"
    elif "twitter" in lower or "x.com" in lower or "tweet" in lower or "thread" in lower:
        platform = "X / Twitter"

    # Content Type detection
    content_type = "Reel"
    if "carousel" in lower or "slides" in lower:
        content_type = "Carousel"
    elif "story" in lower or "stories" in lower:
        content_type = "Story"
    elif "short" in lower:
        content_type = "Short"
    elif "post" in lower or "caption" in lower:
        content_type = "Post"
    elif "article" in lower or "newsletter" in lower:
        content_type = "Article"

    # Language detection
    language = "English"
    if "malayalam" in lower or "മലയാളം" in lower:
        language = "Malayalam"
    elif "manglish" in lower:
        language = "Manglish"
    elif "hindi" in lower or "हिंदी" in lower or "hinglish" in lower:
        language = "Hindi"

    # Audience & Tone heuristics
    audience = "Students & Tech Enthusiasts" if "student" in lower or "college" in lower else "Digital Creators & Entrepreneurs"
    tone = "Educational & Actionable" if "explain" in lower or "how to" in lower or "tools" in lower else "Energetic & Inspiring"

    # Clean idea
    clean_idea = re.sub(
        r"(?i)\b(make|create|generate|write|a|an|in|for|reel|carousel|post|story|short|youtube|instagram|linkedin|malayalam|manglish|hindi|english)\b",
        "",
        prompt,
    ).strip()
    if not clean_idea or len(clean_idea) < 3:
        clean_idea = prompt.strip()

    return IntentExtractResponse(
        idea=clean_idea,
        platform=platform,
        content_type=content_type,
        audience=audience,
        tone=tone,
        language=language,
        visual_direction="Modern high-contrast minimalist with bold typography",
        content_goal="Audience Growth & Engagement",
    )


@router.post(
    "/intent/extract",
    response_model=IntentExtractResponse,
    status_code=status.HTTP_200_OK,
    summary="Zero-prompt creator intention understanding engine",
)
async def extract_intent(
    payload: IntentExtractRequest,
    user: AuthenticatedUser = Depends(get_current_user),
) -> IntentExtractResponse:
    """
    Parses natural creator thoughts or voice transcriptions into structured
    generation parameters using single-call LLM intelligence with fallback.
    """
    system_prompt = (
        "You are CreateDiff's Intent Understanding Engine. "
        "Analyze the creator's raw intention/voice input and extract structured parameters. "
        "Respond ONLY with valid JSON: "
        "{\n"
        '  "idea": "concise core topic/idea",\n'
        '  "platform": "Instagram" | "YouTube" | "LinkedIn" | "X / Twitter",\n'
        '  "contentType": "Reel" | "Carousel" | "Post" | "Short" | "Story" | "Article",\n'
        '  "audience": "target audience description",\n'
        '  "tone": "tone of voice",\n'
        '  "language": "English" | "Malayalam" | "Manglish" | "Hindi",\n'
        '  "visualDirection": "1-line visual & aesthetic direction",\n'
        '  "contentGoal": "primary strategic goal"\n'
        "}"
    )

    user_prompt = f"Creator prompt: \"{payload.prompt}\""
    if payload.creator_context:
        ctx = payload.creator_context
        user_prompt += f"\nCreator Niche: {ctx.niche}\nDefault Tone: {ctx.tone}\nDefault Language: {ctx.primary_language}"

    try:
        data = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=0.3,
        )
        return IntentExtractResponse(
            idea=str(data.get("idea") or payload.prompt).strip(),
            platform=str(data.get("platform") or "Instagram").strip(),
            content_type=str(data.get("contentType") or data.get("content_type") or "Reel").strip(),
            audience=str(data.get("audience") or "Creators & Students").strip(),
            tone=str(data.get("tone") or "Educational").strip(),
            language=str(data.get("language") or "English").strip(),
            visual_direction=str(data.get("visualDirection") or data.get("visual_direction") or "High-contrast modern minimal").strip(),
            content_goal=str(data.get("contentGoal") or data.get("content_goal") or "Audience Growth").strip(),
        )
    except Exception as e:
        logger.warning(f"LLM intent extraction fallback to heuristics: {e}")
        return _heuristic_extract(payload.prompt, payload.creator_context)
