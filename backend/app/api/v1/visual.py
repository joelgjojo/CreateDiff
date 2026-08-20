from __future__ import annotations

import logging
from typing import Optional
from fastapi import APIRouter, Depends, status
from app.schemas.visual import (
    VisualDirectionRequest,
    VisualDirectionResponse,
    ReelCoverDirection,
    YouTubeThumbnailDirection,
    CarouselBlueprint,
    CarouselSlideDesign,
)
from app.services.auth import AuthenticatedUser, get_current_user
from app.services.groq_service import GroqService

logger = logging.getLogger("creatediff.visual")
router = APIRouter(tags=["Visual Creation"])


def _heuristic_visual_direction(payload: VisualDirectionRequest) -> VisualDirectionResponse:
    fmt = payload.format_type.lower()
    topic = payload.topic
    hook = payload.hook or topic

    colors = ["#080A0F", "#4F43F9", "#7066FF", "#00B894"]
    if payload.creator_context and payload.creator_context.brand_dna:
        colors = payload.creator_context.brand_dna.preferred_colors or colors

    if "cover" in fmt or "reel" in fmt:
        return VisualDirectionResponse(
            format_type="reel_cover",
            reel_cover=ReelCoverDirection(
                cover_concept=f"High-energy creator framing highlighting {topic[:40]}",
                headline=hook[:30].upper(),
                composition="Subject centered in lower 60%, bold typography anchored in top 30% safety zone",
                typography="Ultra-bold geometric sans-serif (Space Grotesk / Inter ExtraBold)",
                color_palette=colors,
                visual_hierarchy="1. Headline Text -> 2. Creator Expression -> 3. Luminous Accent Border",
            ),
            design_notes=[
                "Keep key text within 9:16 safe zones (avoid bottom 20% reels UI)",
                "Use high contrast background glow behind dark text",
            ],
        )
    elif "thumb" in fmt or "youtube" in fmt:
        return VisualDirectionResponse(
            format_type="youtube_thumbnail",
            youtube_thumbnail=YouTubeThumbnailDirection(
                thumbnail_idea=f"Curiosity gap visual illustrating the transformation in {topic[:40]}",
                text_placement="Top-left 3 words max: " + hook[:20].upper(),
                emotion_expression="Intense curiosity / revelation expression with eyes locked on camera",
                composition_guide="Subject on right third, 3D illustrative element on left third, high-contrast glow separator",
                attention_strategy="Pattern interrupt via glowing border and saturated foreground accent",
            ),
            design_notes=[
                "Export at 1280x720 (16:9)",
                "Ensure legibility at 10% mobile thumbnail size",
            ],
        )
    else:
        # Carousel blueprint
        slides = [
            CarouselSlideDesign(
                slide_number=1,
                headline=hook[:35].upper(),
                body_text=f"The complete step-by-step breakdown on {topic[:35]}.",
                visual_direction="Hook cover: Minimalist dark canvas with electric blue highlight badge",
            ),
            CarouselSlideDesign(
                slide_number=2,
                headline="The Core Bottleneck",
                body_text="Most creators fail here because they overlook fundamental principles.",
                visual_direction="Contrast diagram showing common mistake vs high-leverage method",
            ),
            CarouselSlideDesign(
                slide_number=3,
                headline="The 3-Step Execution Framework",
                body_text="1. Structure intention\n2. Iterate rapidly\n3. Optimize with analytics",
                visual_direction="Numbered cards with rounded borders and icons",
            ),
            CarouselSlideDesign(
                slide_number=4,
                headline="Save & Apply This Strategy",
                body_text="Double tap to bookmark for your next creation cycle.",
                visual_direction="Clean CTA card with bookmark icon and creator handle lockup",
            ),
        ]
        return VisualDirectionResponse(
            format_type="carousel",
            carousel=CarouselBlueprint(
                title=topic[:50],
                total_slides=len(slides),
                color_palette=colors,
                slides=slides,
            ),
            design_notes=[
                "Use consistent 1:1 or 4:5 aspect ratio",
                "Maintain uniform font sizes across slide body text",
            ],
        )


@router.post(
    "/visual/direction",
    response_model=VisualDirectionResponse,
    status_code=status.HTTP_200_OK,
    summary="Creative Production Engine: Generates structured text design directions",
)
async def generate_visual_direction(
    payload: VisualDirectionRequest,
    user: AuthenticatedUser = Depends(get_current_user),
) -> VisualDirectionResponse:
    """
    Produces complete creative text directions for Reel Covers, Thumbnails, and Carousels.
    (Cost boundary: outputs structured text design blueprints without calling image generation APIs).
    """
    system_prompt = (
        "You are CreateDiff's Creative Art Director. "
        "Generate a structured text design blueprint for social media visual assets. "
        "Do NOT generate images; output comprehensive structural guidance in JSON format: "
        "{\n"
        '  "format_type": "reel_cover" | "youtube_thumbnail" | "carousel",\n'
        '  "reel_cover": {\n'
        '    "cover_concept": "...",\n'
        '    "headline": "...",\n'
        '    "composition": "...",\n'
        '    "typography": "...",\n'
        '    "color_palette": ["#...", "#..."],\n'
        '    "visual_hierarchy": "..."\n'
        "  },\n"
        '  "youtube_thumbnail": {\n'
        '    "thumbnail_idea": "...",\n'
        '    "text_placement": "...",\n'
        '    "emotion_expression": "...",\n'
        '    "composition_guide": "...",\n'
        '    "attention_strategy": "..."\n'
        "  },\n"
        '  "carousel": {\n'
        '    "title": "...",\n'
        '    "total_slides": 4,\n'
        '    "color_palette": ["#...", "#..."],\n'
        '    "slides": [\n'
        '      {"slide_number": 1, "headline": "...", "body_text": "...", "visual_direction": "..."}\n'
        "    ]\n"
        "  },\n"
        '  "design_notes": ["..."]\n'
        "}"
    )

    user_prompt = f"Format: {payload.format_type}\nTopic: {payload.topic}\nHook: {payload.hook or 'N/A'}"
    if payload.creator_context and payload.creator_context.brand_dna:
        dna = payload.creator_context.brand_dna
        user_prompt += f"\nBrand Visual Identity: {dna.visual_identity}\nPreferred Colors: {dna.preferred_colors}"

    try:
        data = await GroqService.generate_chat_completion(
            system_prompt=system_prompt,
            user_prompt=user_prompt,
            temperature=0.5,
        )
        return VisualDirectionResponse.model_validate(data)
    except Exception as e:
        logger.warning(f"Visual direction generation fallback to heuristics: {e}")
        return _heuristic_visual_direction(payload)
