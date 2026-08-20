# CreateDiff Phase 3 Readiness

## Audit summary

Flutter remains offline-first: `SharedPreferences` schema v3 owns the local profile, drafts, favorites, content history, campaigns, and usage guard. The backend is a FastAPI REST boundary; AI provider credentials stay server-side. PostgreSQL persistence is accessed through SQLAlchemy, and Supabase access tokens are verified before protected operations.

The main production risks are distributed quota races, token refresh ownership, and migration conflict resolution. These are explicit seams rather than hidden fallbacks.

## Runtime configuration

Development can use the deterministic local identity when `ENVIRONMENT=development` and `AUTH_REQUIRED=false`. This is for local development and existing deterministic tests only. Production is fail-closed: the production environment requires a bearer token regardless of the `AUTH_REQUIRED` default.

Required backend variables:

```env
ENVIRONMENT=production
DATABASE_URL=postgresql+asyncpg://...
SUPABASE_JWT_SECRET=...
SUPABASE_JWT_ISSUER=https://<project>.supabase.co/auth/v1
SUPABASE_JWT_AUDIENCE=authenticated
AUTH_REQUIRED=true
GROQ_API_KEY=...
```

Optional quota variables:

```env
USAGE_GENERATION_LIMIT=100
USAGE_CAMPAIGN_LIMIT=20
USAGE_AI_REQUEST_LIMIT=150
```

Flutter production builds receive only the backend URL through `--dart-define=CREATE_DIFF_PRODUCTION_API_BASE_URL=...`. `.env` is not a Flutter asset.

## Data migration

Local profile, content projects, drafts, favorites, and campaigns remain available offline. After a valid Supabase session stores an access token, `CloudSyncService.syncLocalData` sends the local projection to `/api/v1/profile/sync`. Sync is idempotent per authenticated user and local source ID; the server scopes every read and write by the verified user identity.

Apply `backend/migrations/001_phase3_initial.sql` and `backend/migrations/002_supabase_profiles_rls.sql` before production startup. `DB_AUTO_CREATE` is development-only.

## Security controls

- JWT verification validates signature, expiry, audience, and optionally issuer.
- AI routes return `401` without a token in production.
- PostgreSQL records use foreign keys and user-scoped queries.
- Error responses do not expose provider keys, tracebacks, or database URLs.
- CORS remains explicit in production.
- Analytics and Sentry are vendor-neutral adapters.

## Scaling path

Current quota checks use indexed PostgreSQL usage logs over a rolling 24-hour window. For multiple API instances or high write volume, move quota reservation to transactional Redis/distributed counters and retain PostgreSQL as the durable audit log.
