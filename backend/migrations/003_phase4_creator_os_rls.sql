-- =============================================================================
-- CreateDiff Phase 4 Migration: AI Creator Operating System Schema & RLS
-- =============================================================================

-- 1. Visual Projects (Structured design directions)
CREATE TABLE IF NOT EXISTS public.visual_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    format_type TEXT NOT NULL,
    topic TEXT NOT NULL,
    hook TEXT,
    direction JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Voice Requests (Voice creation telemetry & intent logs)
CREATE TABLE IF NOT EXISTS public.voice_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transcription TEXT NOT NULL,
    extracted_intent JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'completed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Content Feedback (Performance learning loop)
CREATE TABLE IF NOT EXISTS public.content_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_id TEXT NOT NULL,
    platform TEXT NOT NULL,
    content_type TEXT NOT NULL,
    feedback TEXT NOT NULL CHECK (feedback IN ('worked', 'did_not_work')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Creator Insights (AI assistant suggestions and recommendations)
CREATE TABLE IF NOT EXISTS public.creator_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL DEFAULT 'strategy',
    title TEXT NOT NULL,
    insight_body TEXT NOT NULL,
    actionable_prompt TEXT,
    is_bookmarked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Brand Profiles (Brand DNA & visual identities)
CREATE TABLE IF NOT EXISTS public.brand_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    brand_name TEXT NOT NULL,
    writing_style TEXT NOT NULL,
    visual_identity TEXT NOT NULL,
    creator_personality TEXT NOT NULL,
    audience_profile TEXT NOT NULL,
    preferred_colors TEXT[] NOT NULL DEFAULT ARRAY['#4F43F9', '#7066FF'],
    successful_content_patterns TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    cultural_context TEXT NOT NULL DEFAULT 'Pan-India & Regional Creator Ecosystem',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES — STRICT USER ISOLATION
-- =============================================================================

-- Enable RLS on all 5 new tables
ALTER TABLE public.visual_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voice_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brand_profiles ENABLE ROW LEVEL SECURITY;

-- 1. visual_projects RLS
CREATE POLICY "Users can manage their own visual projects"
ON public.visual_projects
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 2. voice_requests RLS
CREATE POLICY "Users can manage their own voice requests"
ON public.voice_requests
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 3. content_feedback RLS
CREATE POLICY "Users can manage their own content feedback"
ON public.content_feedback
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. creator_insights RLS
CREATE POLICY "Users can manage their own creator insights"
ON public.creator_insights
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. brand_profiles RLS
CREATE POLICY "Users can manage their own brand profiles"
ON public.brand_profiles
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
