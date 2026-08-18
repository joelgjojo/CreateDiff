# CreateDiff Production Architecture Document

---

## 1. System Architecture Overview

CreateDiff uses a layered client-server architecture where the mobile application is decoupled from AI provider secrets:

```text
┌────────────────────────────────────────────────────────┐
│                   CreateDiff Mobile                    │
│                        (Flutter)                       │
│                                                        │
│  - UI & Atmospheric Design System                      │
│  - State Machine & Concurrency Guard (_activeRequestId)│
│  - Local Encrypted Storage & History Archive           │
│  - Creator Memory Local Sync                           │
│  - Non-Destructive Regeneration Handling               │
│  - Cold-Start Indicator (>5s status message)           │
│                                                        │
│  * NO GROQ SECRET IN CLIENT APPLICATION                │
└───────────────────────────┬────────────────────────────┘
                            │
                  HTTPS / REST API (JSON)
                  Headers: X-Request-ID
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│               CreateDiff Backend Service               │
│                        (FastAPI)                       │
│                                                        │
│  ├── Middleware                                        │
│  │   ├── RequestIDMiddleware                           │
│  │   ├── SecurityHeadersMiddleware                     │
│  │   ├── RateLimitMiddleware (In-Memory IP Limiter)    │
│  │   └── LoggingMiddleware (Safe JSON logs)            │
│  │                                                     │
│  ├── API Layer (/api/v1)                               │
│  │   ├── GET  /health                                  │
│  │   ├── GET  /readiness                               │
│  │   └── POST /generate                                │
│  │                                                     │
│  ├── Services & Core Logic                             │
│  │   ├── PromptBuilder (Multi-Language & Brand Memory) │
│  │   ├── GenerationService (Validation & Normalization)│
│  │   └── GroqService (Async HTTPX + Exponential Retry) │
│  │                                                     │
│  └── Configuration & Secrets                           │
│      ├── GROQ_API_KEY (Server-side ONLY)               │
│      └── GROQ_MODEL (openai/gpt-oss-120b)              │
└───────────────────────────┬────────────────────────────┘
                            │
                  HTTPS / Bearer Secret
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                       Groq API                         │
│                 (openai/gpt-oss-120b)                  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Trust Boundaries & Security Model

### Secret Boundaries
- **Mobile Client**: The Flutter application binary, source code, `.dart_tool`, and assets contain zero provider API keys or bearer tokens.
- **Backend API**: The FastAPI backend is the sole custodian of the `GROQ_API_KEY`. It reads this from environment variables injected by the host platform (Render, Docker, or local `.env`).

### Untrusted Inputs
- All client request fields (`idea`, `creatorContext`, `platform`, `contentType`, `overrideTone`, `overrideLanguage`) are treated as **untrusted data**.
- Strict bounds are enforced:
  - `idea`: 3 to 2,000 characters.
  - `creatorContext`: Max 250 chars per field, max 500 chars for brand description.
  - Payloads exceeding `MAX_REQUEST_BODY_BYTES` (64KB) are rejected with HTTP 422.

### Prompt Injection Defense
- System prompt uses rigid, delimiter-enclosed context sections (`=== CREATOR BRAND MEMORY ===`, `=== LANGUAGE & REGIONAL RULES ===`, `=== PROMPT INJECTION DEFENSE ===`, `=== REQUIRED JSON SCHEMA ===`).
- User ideas and notes are treated as passive text topics, never as system instructions.

---

## 3. Rate Limiting Scope

- **Mechanism**: In-memory sliding-window counter keyed by client IP address.
- **Default Limit**: 30 requests per 60-second window.
- **Response**: HTTP 429 Too Many Requests with a `Retry-After` header.
- **Phase 2 Limitation**: In-memory rate limiting is designed for single-instance / Render free tier deployments. Counters reset when the server restarts or wakes from cold sleep. Distributed rate limiting (Redis) is recommended when scaling to multi-instance clusters.

---

## 4. Cold-Start Handling (Render Free Tier)

- Free-tier web services on Render spin down after 15 minutes of inactivity.
- Waking an asleep instance may take 30–60 seconds.
- **Client Handling**: If the generation request exceeds 5 seconds, `AppState` automatically updates the loading message to:
  > *"Waking up the AI engine — this can take up to a minute on first use..."*
- Total client timeout is configured to 65 seconds to accommodate waking instances without throwing false connection failures.
- Always-on instances ($7/month) eliminate cold-start delays.

---

## 5. Error Contract & Lifecycle

All API responses for non-200 scenarios conform to a stable machine-readable schema:

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Idea cannot be empty.",
    "request_id": "cd-mob-1786978943554"
  }
}
```

### Stable Error Codes:
- `INVALID_REQUEST`: Validation failure or malformed payload (HTTP 400 / 422).
- `RATE_LIMITED`: Generation limit exceeded (HTTP 429).
- `AI_AUTH_ERROR`: Server-side provider configuration missing (HTTP 500).
- `AI_TIMEOUT`: Upstream provider or server timed out (HTTP 504).
- `AI_UPSTREAM_ERROR`: Provider temporarily unavailable (HTTP 502/503).
- `AI_INVALID_RESPONSE`: Upstream output was unparseable.
- `INTERNAL_ERROR`: Unhandled server exception (HTTP 500).

---

## 6. Phase 3 Real User Infrastructure

The Phase 3 boundary keeps `SharedPreferences` schema v3 as the offline cache and adds a cloud projection:

```text
Flutter local schema v3 ── offline-first ──> UI / retry queue
        │ authenticated first sync (Bearer Supabase JWT)
        ▼
FastAPI auth dependency ──> PostgreSQL ORM ──> Supabase user identity
        │
        ├── generation / campaign records
        ├── usage logs and configurable rolling limits
        └── abstract analytics + Sentry adapter seam
```

The protected AI routes are `POST /api/v1/generate` and `POST /api/v1/campaign/plan`. `POST /api/v1/profile/sync` is the first cloud migration endpoint. In development, unauthenticated local requests use a deterministic local identity for backward-compatible tests; production requires `AUTH_REQUIRED=true` or the production environment guard. Production database structure is applied through `backend/migrations/001_phase3_initial.sql`; `DB_AUTO_CREATE` is for local development only.

## 7. Future Roadmap

1. **User Authentication & Accounts**: Token-based JWT/OAuth2 authentication layer with server-verified identity.
2. **Cloud Creator Profiles**: Synchronized Brand Memory profiles across user devices.
3. **Database Integration**: PostgreSQL/Supabase persistence for cross-device history archive and analytics.
4. **Distributed Quotas & Tiered Billing**: Redis-backed global rate limiter and Stripe subscription billing.
