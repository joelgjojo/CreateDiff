-- ==============================================================================
-- CreateDiff RLS & Role Isolation Verification Suite
-- ==============================================================================

BEGIN;

-- Create test auth users
INSERT INTO auth.users (id, email)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'user_a@creatediff.com'),
    ('22222222-2222-2222-2222-222222222222', 'user_b@creatediff.com'),
    ('33333333-3333-3333-3333-333333333333', 'admin@creatediff.com')
ON CONFLICT (id) DO NOTHING;

-- Trigger creates profiles automatically with role = 'user'
-- Make User 3 an admin
UPDATE public.profiles SET role = 'admin' WHERE id = '33333333-3333-3333-3333-333333333333';

-- 1. Test User A Context
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "11111111-1111-1111-1111-111111111111", "role": "authenticated"}';

-- User A can see own profile
SELECT count(*) = 1 AS user_a_sees_own_profile FROM public.profiles WHERE id = '11111111-1111-1111-1111-111111111111';

-- User A CANNOT see User B profile
SELECT count(*) = 0 AS user_a_cannot_see_user_b FROM public.profiles WHERE id = '22222222-2222-2222-2222-222222222222';

-- 2. Test Admin Context
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub": "33333333-3333-3333-3333-333333333333", "role": "authenticated"}';

-- Admin CAN see all profiles
SELECT count(*) = 3 AS admin_sees_all_profiles FROM public.profiles;

-- 3. Test Anonymous Context
SET LOCAL ROLE anon;
SET LOCAL "request.jwt.claims" = '';

-- Anonymous CANNOT see any profile
SELECT count(*) = 0 AS anon_sees_zero_profiles FROM public.profiles;

ROLLBACK;
