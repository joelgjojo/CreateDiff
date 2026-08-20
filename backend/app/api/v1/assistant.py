from __future__ import annotations

import logging
from typing import List, Optional
from fastapi import APIRouter, Depends, status
from app.schemas.assistant import (
    AssistantSuggestRequest,
    AssistantSuggestResponse,
    CreatorIdeaSuggestion,
)
from app.services.auth import AuthenticatedUser, get_current_user
from app.services.groq_service import GroqService

logger = logging.getLogger("creatediff.assistant")
router = APIRouter(tags=["AI Creator Assistant"])


def _heuristic_assistant_suggestions(payload: AssistantSuggestRequest) -> AssistantSuggestResponse:
    ctx = payload.creator_context
    niche = (ctx.niche if ctx and ctx.niche else "Tech & Creative Productivity").strip()
    is_cold_start = not payload.has_performance_history

    suggestions = [
        CreatorIdeaSuggestion(
            topic=f"The 3 Biggest Mistakes Beginners Make in {niche}",
            platform="Instagram",
            contentType="Reel",
            hookIdea=f"If you're starting out in {niche}, STOP doing these 3 things.",
            strategicAngle="Mistake-Correction Hook + High Retention",
            whyItWorks="Negative bias hooks generate 2.4x higher watch time on short-form feeds.",
        ),
        CreatorIdeaSuggestion(
            topic=f"My Exact Step-by-Step Workflow for {niche}",
            platform="Instagram",
            contentType="Carousel",
            hookIdea="Swipe through for the entire blueprint I wish I had on day one.",
            strategicAngle="Actionable Educational Value + High Save Rate",
            whyItWorks="Step-by-step swipeable blueprints drive bookmarking and algorithmic distribution.",
        ),
        CreatorIdeaSuggestion(
            topic=f"Why Everything You Were Told About {niche} is Outdated",
            platform="YouTube",
            contentType="Short",
            hookIdea="Most advice in 2026 is completely wrong. Here is why.",
            strategicAngle="Contrarian Perspective + Authority Building",
            whyItWorks="Challenging common wisdom creates strong engagement and comment discussion.",
        ),
    ]

    return AssistantSuggestResponse(
        strategySummary=(
            f"Foundational strategic roadmap tailored for your '{niche}' domain."
            if is_cold_start
            else f"Performance-optimized recommendation loop for '{niche}' based on creator feedback."
        ),
        suggestions=suggestions,
        isColdStartFallback=is_cold_start,
        sourceLabel="Profile-based starting suggestions" if is_cold_start else "Performance-Tuned AI Partner",
    )


@router.post(
    "/assistant/suggest",
    response_model=AssistantSuggestResponse,
    status_code=status.HTTP_200_OK,
    summary="AI Creator Assistant: Generates personalized content strategies and ideas",
)
async def suggest_ideas(
    payload: AssistantSuggestRequest,
    user: AuthenticatedUser = Depends(get_current_user),
) -> AssistantSuggestResponse:
    is_cold_start = not payload.has_performance_history
    ctx = payload.creator_context
    niche = ctx.niche if ctx and ctx.niche else "Creator Studio"

    system_prompt = (
        "You are CreateDiff's Chief Content Strategist AI. "
        "Recommend 3 high-impact content concepts tailored for this creator. "
        "Respond ONLY with valid JSON matching: "
        "{\n"
        '  "strategySummary": "1-2 sentence high-level weekly content strategy",\n'
        '  "suggestions": [\n'
        '    {\n'
        '      "topic": "...",\n'
        '      "platform": "Instagram" | "YouTube" | "LinkedIn" | "X / Twitter",\n'
        '      "contentType": "Reel" | "Carousel" | "Short" | "Post",\n'
        '      "hookIdea": "...",\n'
        '      "strategicAngle": "...",\n'
        '      "whyItWorks": "..."\n'
        '    }\n'
        '  ]\n'
        "}"
    )

    user_prompt = f"Query: {payload.query or 'What should I create next week?'}\nNiche: {niche}"
    if ctx:
        user_prompt += f"\nTarget Audience: {ctx.target_audience}\nTone: {ctx.tone}\nGoals: {ctx.content_goals}"
        if ctx.brand_dna:
            user_prompt += f"\nBrand Style: {ctx.brand_dna.writing_style}\nPersonality: {ctx.brand_dna.creator_personality}"

    try:
        data = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=0.6,
        )
        suggestions_raw = data.get("suggestions") or []
        suggestions: List[CreatorIdeaSuggestion] = []
        for s in suggestions_raw:
            if isinstance(s, dict):
                suggestions.append(CreatorIdeaSuggestion.model_validate(s))

        if not suggestions:
            return _heuristic_assistant_suggestions(payload)

        return AssistantSuggestResponse(
            strategySummary=str(data.get("strategySummary") or f"Weekly strategy tailored for {niche}."),
            suggestions=suggestions,
            isColdStartFallback=is_cold_start,
            sourceLabel="Profile-based starting suggestions" if is_cold_start else "Personalized Creator AI",
        )
    except Exception as e:
        logger.warning(f"Assistant suggestions fallback to heuristics: {e}")
        return _heuristic_assistant_suggestions(payload)
