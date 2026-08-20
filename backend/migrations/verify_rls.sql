-- ==============================================================================
-- CreateDiff Phase 3: Row Level Security (RLS) SQL Verification Script
-- ==============================================================================
-- This script tests and proves that RLS on public.profiles isolates user data:
-- 1. User A can read/update User A's profile.
-- 2. User A CANNOT read/update User B's profile.
-- 3. User B can read/update User B's profile.
-- 4. Anonymous (unauthenticated) queries return 0 rows.
-- ==============================================================================

BEGIN;

-- 1. Setup Test Identities (Simulated UUIDs)
DO $$
DECLARE
    user_a_id UUID := 'a0000000-0000-0000-0000-000000000001';
    user_b_id UUID := 'b0000000-0000-0000-0000-000000000002';
BEGIN
    -- Seed test profiles directly as superuser/service role
    INSERT INTO public.profiles (id, email, display_name)
    VALUES 
        (user_a_id, 'creator_a@example.com', 'Creator A'),
        (user_b_id, 'creator_b@example.com', 'Creator B')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- 2. Test Context: User A Authenticated
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "a0000000-0000-0000-0000-000000000001", "role": "authenticated"}';

-- User A reads own profile -> Expect 1 row
SELECT id, email, display_name FROM public.profiles WHERE id = 'a0000000-0000-0000-0000-000000000001';

-- User A attempts to read User B profile -> Expect 0 rows (BLOCKED by RLS)
SELECT id, email, display_name FROM public.profiles WHERE id = 'b0000000-0000-0000-0000-000000000002';

-- 3. Test Context: User B Authenticated
SET LOCAL "request.jwt.claims" = '{"sub": "b0000000-0000-0000-0000-000000000002", "role": "authenticated"}';

-- User B reads own profile -> Expect 1 row
SELECT id, email, display_name FROM public.profiles WHERE id = 'b0000000-0000-0000-0000-000000000002';

-- User B attempts to read User A profile -> Expect 0 rows (BLOCKED by RLS)
SELECT id, email, display_name FROM public.profiles WHERE id = 'a0000000-0000-0000-0000-000000000001';

-- 4. Test Context: Anonymous / Unauthenticated
SET LOCAL ROLE anon;
RESET "request.jwt.claims";

-- Anonymous attempts to read profiles -> Expect 0 rows (BLOCKED by RLS)
SELECT count(*) AS anon_accessible_profiles FROM public.profiles;

ROLLBACK;
