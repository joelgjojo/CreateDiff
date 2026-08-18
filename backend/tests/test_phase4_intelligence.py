import pytest
from app.schemas.generation import (
    GenerationRequest,
    CreatorContext,
    LanguageProfile,
    CreatorMemory,
    GenerationResponse,
)
from app.services.prompt_builder import PromptBuilder
from app.services.generation_service import GenerationService


def test_language_profile_and_creator_memory_schemas():
    lang = LanguageProfile(
        language="Malayalam",
        preferredStyle="Storytelling",
        audienceType="College students in Kerala",
        regionalContext="Kochi startup ecosystem",
        communicationTone="Warm & Relatable",
    )
    assert lang.language == "Malayalam"
    assert lang.preferred_style == "Storytelling"

    memory = CreatorMemory(
        successful_patterns=["Favorited 30s quick tip"],
        preferred_hooks=["Contrarian tech hook"],
        preferred_formats=["Reel", "Carousel"],
        avoid_patterns=["Corporate buzzwords"],
        brand_rules=["Always mention actionable metrics"],
    )
    assert len(memory.brand_rules) == 1
    assert "Reel" in memory.preferred_formats

    ctx = CreatorContext(
        name="Joel G Jojo",
        primary_language="Malayalam",
        language_profile=lang,
        creator_memory=memory,
    )
    assert ctx.language_profile.preferred_style == "Storytelling"


def test_prompt_builder_includes_phase4_intelligence():
    lang = LanguageProfile(
        language="Manglish",
        preferredStyle="Conversational",
        audienceType="Young tech enthusiasts",
        regionalContext="Kerala developer culture",
        communicationTone="Energetic & Witty",
    )
    memory = CreatorMemory(
        preferred_hooks=["Stop doing this manually in 2026"],
        avoid_patterns=["Generic motivational quotes"],
        brand_rules=["Lead with code or studio preview"],
    )
    ctx = CreatorContext(
        name="Joel G Jojo",
        niche="Technology",
        language_profile=lang,
        creator_memory=memory,
    )

    prompt = PromptBuilder.build_system_prompt(ctx)
    assert "Manglish" in prompt
    assert "Conversational" in prompt
    assert "Kerala developer culture" in prompt
    assert "Stop doing this manually in 2026" in prompt
    assert "Generic motivational quotes" in prompt
    assert "creativeDirector" in prompt
    assert "contentReview" in prompt
    assert "repurposedContent" in prompt
    assert "brandConsistencySuggestions" in prompt


def test_generation_service_parses_phase4_objects():
    sample_raw_json = {
        "hooks": ["Hook 1", "Hook 2", "Hook 3", "Hook 4", "Hook 5"],
        "caption": "Test caption",
        "ctas": ["Save for later"],
        "hashtagsHighReach": ["#ai", "#creator", "#tech", "#studio", "#growth"],
        "hashtagsMediumReach": ["#aitools", "#creatoreconomy", "#flutterdev", "#fastapi"],
        "hashtagsNiche": ["#keralacreators", "#creatediff", "#mobileai"],
        "coverText": "AI STUDIO BLUEPRINT",
        "variations": ["Variation 1", "Variation 2"],
        "visualIntelligence": {
            "visualStyle": "Cyber Minimalist",
            "layoutSuggestion": "Centered typography with glow card",
            "thumbnailDirection": "Bold high contrast reaction",
            "typographySuggestion": "Space Grotesk Bold",
            "colorPalette": ["#080A0F", "#4F43F9", "#7066FF", "#00B894"],
            "designMood": "Futuristic & Clean",
            "brandConsistencySuggestions": ["Keep dark background"],
            "visualHierarchy": "Hook -> Proof -> CTA",
            "thumbnailStrategy": "Punchy 3-word hook",
            "imageDirection": "Modern studio shot",
        },
        "quality": {
            "hookStrength": 92,
            "platformFit": 94,
            "audienceFit": 90,
            "originality": 88,
            "overallScore": 91,
            "languageNaturalness": 95,
            "culturalRelevance": 92,
            "regionalAuthenticity": 94,
            "issues": [],
        },
        "creativeDirector": {
            "audienceInsight": "Creators want fast workflows.",
            "contentAngle": "Contrarian comparison.",
            "storyStructure": "Problem -> Solution -> Action.",
            "improvementSuggestion": "Add specific metric.",
            "reasoning": "Data converts higher.",
        },
        "contentReview": {
            "hookAnalysis": "Very high curiosity trigger.",
            "clarityAnalysis": "Direct and punchy.",
            "audienceFit": "Excellent match.",
            "improvementSuggestions": ["Make first word bolder"],
            "disclaimer": "AI analysis only — not real performance prediction.",
        },
        "repurposedContent": {
            "instagramCaption": "IG caption version",
            "linkedinPost": "LinkedIn post version",
            "youtubeDescription": "YouTube description version",
            "xThread": ["1/3 First tweet", "2/3 Second tweet", "3/3 Third tweet"],
            "blogOutline": ["Intro", "Core Points", "Conclusion"],
        },
    }

    parsed = GenerationService._parse_and_normalize(sample_raw_json)
    assert isinstance(parsed, GenerationResponse)
    assert parsed.creative_director is not None
    assert parsed.creative_director.audience_insight == "Creators want fast workflows."
    assert parsed.content_review is not None
    assert parsed.content_review.hook_analysis == "Very high curiosity trigger."
    assert parsed.content_review.disclaimer == "AI analysis only — not real performance prediction."
    assert parsed.repurposed_content is not None
    assert len(parsed.repurposed_content.x_thread) == 3
    assert len(parsed.repurposed_content.blog_outline) == 3
    assert parsed.visual_intelligence.visual_hierarchy == "Hook -> Proof -> CTA"
    assert parsed.quality.language_naturalness == 95
    assert parsed.quality.regional_authenticity == 94
