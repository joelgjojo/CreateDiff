# CreateDiff AI Engine Backend (FastAPI)

Production-ready, secure server-side AI proxy and orchestration backend for the **CreateDiff** mobile application.

---

## 1. Architecture & Security Model

CreateDiff moves AI generation from the mobile client to this server boundary:

```text
Flutter Mobile App ──(HTTPS / JSON / X-Request-ID)──> CreateDiff FastAPI ──(Server Secret)──> Groq AI API
```

- **Groq API Key Secret Isolation**: The Groq API key is stored exclusively on this server (never embedded in mobile client binaries or assets).
- **Request Validation & Limits**: Client payloads and creator contexts are strictly bounded and validated using Pydantic.
- **In-Memory IP Rate Limiting**: Abuse prevention with sliding-window counters (30 requests / 60 seconds by default).
- **Structured Error Normalization**: No Python tracebacks, credentials, or internal server paths are ever exposed.

---

## 2. Quickstart & Local Development

### Prerequisites
- Python 3.9+
- Groq API Key from [console.groq.com](https://console.groq.com)

### Installation
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Environment Configuration
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` and set your credentials:
```ini
ENVIRONMENT=development
HOST=0.0.0.0
PORT=8000

# Server-Side Only Groq Credentials
GROQ_API_KEY=[REDACTED]
GROQ_MODEL=openai/gpt-oss-120b
GROQ_BASE_URL=https://api.groq.com/openai/v1

# In-Memory Rate Limiting
RATE_LIMIT_REQUESTS=30
RATE_LIMIT_WINDOW_SECONDS=60
```

### Start the Server
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 3. API Endpoints

### 1. Process Health
- **Route**: `GET /api/v1/health`
- **Response**:
```json
{
  "status": "healthy",
  "service": "creatediff-api",
  "version": "1.0.0"
}
```

### 2. Service Readiness
- **Route**: `GET /api/v1/readiness`
- **Response**:
```json
{
  "status": "ready",
  "service": "creatediff-api",
  "version": "1.0.0",
  "ai_configured": true
}
```

### 3. Generate Content Pack
- **Route**: `POST /api/v1/generate`
- **Headers**:
  - `Content-Type: application/json`
  - `X-Request-ID: <optional-uuid>`
- **Request Body**:
```json
{
  "platform": "Instagram",
  "contentType": "Reel",
  "idea": "5 AI Tools Every Creator Needs in 2026",
  "overrideLanguage": "English",
  "overrideTone": "Actionable & Punchy",
  "creatorContext": {
    "name": "Joel",
    "niche": "Technology",
    "primaryLanguage": "English"
  }
}
```
- **Response**:
```json
{
  "hooks": [
    "What’s the ONE AI tool that’s blowing up creators in 2026?",
    "Forget ChatGPT—these 5 AI tools will actually skyrocket your content.",
    "Step‑by‑step: How to integrate each AI tool into your daily workflow.",
    "I tried all the hype—here’s the AI arsenal that transformed my output.",
    "Ready to upgrade your creator stack, or are you still stuck in 2023?"
  ],
  "caption": "🚀 LEVEL UP your creator game in 2026!...",
  "ctas": [
    "Tap the link in bio to get the full AI toolkit guide.",
    "Save this Reel for your next content sprint.",
    "Comment your favorite AI tool below."
  ],
  "hashtagsHighReach": ["#AI", "#Tech", "#Creators", "#Innovation", "#Video"],
  "hashtagsMediumReach": ["#AItools", "#CreatorTools", "#ContentCreation", "#2026Trends"],
  "hashtagsNiche": ["#AIForCreators", "#CreatorTech2026", "#AIWorkflow"],
  "coverText": "TOP 5 AI TOOLS",
  "variations": [
    "Standard Reel – Quick tool flashes with voice‑over",
    "High‑Engagement Reel – Text overlay + countdown timer",
    "Story Framework Reel – Hook, demo, swipe‑up CTA"
  ]
}
```

---

## 4. Connecting the Flutter Client

In development:
- **iOS Simulator / Desktop / Web**: `http://127.0.0.1:8000`
- **Android Emulator**: `http://10.0.2.2:8000` (mapped automatically by `ApiConfig.defaultPlatformBackendUrl`)
- **Physical Device**: Set `CREATE_DIFF_DEV_API_BASE_URL=http://<YOUR_MAC_LAN_IP>:8000` in the Flutter root `.env`.

In production:
- Set `CREATE_DIFF_PRODUCTION_API_BASE_URL=https://your-creatediff-api.onrender.com` in Flutter release build config.

---

## 5. Render Free Tier Deployment

The repository includes a ready-to-deploy [`render.yaml`](render.yaml) blueprint.

### Deploy Steps:
1. Push this repository to GitHub/GitLab.
2. Log into [Render Dashboard](https://dashboard.render.com).
3. Create a **New +** -> **Blueprint Instance** and select the repository.
4. Set the `GROQ_API_KEY` secret variable in the Render Environment Settings.
5. Deploy.

### Cold-Start Behavior (Free Tier)
- Render's free tier spins instances down after ~15 minutes of inactivity.
- The first request following spin-down may take 30–60 seconds to boot.
- The CreateDiff Flutter mobile application detects delays > 5 seconds and displays:
  > *"Waking up the AI engine — this can take up to a minute on first use..."*
- Upgrading to a paid always-on tier (~$7/month) removes this delay for production traffic.

---

## 6. Rate Limiting Scope

- Rate limiting is enforced in-memory per client IP address.
- Counters reset upon instance restart / cold-start wake.
- When scaling to multiple backend instances, replace `InMemoryRateLimiter` with Redis-backed distributed rate limiting.

---

## 7. Running Backend Tests

```bash
cd backend
.venv/bin/pytest -v
```
All test suites cover health, readiness, input validation, rate limiting, and security header verification.
