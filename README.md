# CreateDiff — AI Content & Design Studio for Creators

> **Idea → AI Content Pack → Designed Visual → Edit → Export**
> 
> A mobile-first creator studio that eliminates prompting. Tell CreateDiff what you're posting in natural words, and receive a complete, platform-optimized, personalized content pack powered by **xAI Grok** with custom visual layouts ready to publish.

---

## 🌟 Core Product Features

1. **Zero-Prompt Engine**:
   - No blank prompt boxes or AI chatbot interactions.
   - Invisible translation of simple creator thoughts into structured, platform-optimized output.

2. **Brand Memory System**:
   - Persists creator niche, tone of voice, target audience, emoji preferences, preferred CTA style, and brand accent colors.
   - Outputs reflect the creator's identity across all platforms and languages.

3. **Real xAI Grok AI Engine**:
   - Production integration with xAI Grok (`grok-4.5`).
   - Strict status observability: `Generating`, `Success`, `Missing API Key`, `Invalid API Key`, `Rate Limited`, `Network Error`, `Server Error`, `Invalid Response`.
   - Zero silent fake/mock fallback.

4. **Developer Debug Panel**:
   - Live endpoint connectivity testing.
   - Real-time telemetry (HTTP status, latency in ms, prompt & response character length, error traces).

5. **Multilingual Content Generation**:
   - Full support for **English**, **Malayalam**, **Manglish**, and **Hindi**.
   - Contextual regional hashtags and dialect-specific hooks.

6. **Complete Content Packs**:
   - 5 high-converting hook variations with one-tap copy & bookmarking.
   - Formatted platform-specific captions with in-place editing.
   - Segmented hashtags (High Reach, Medium/Regional, Niche).
   - Strategic Calls-to-Action (Direct, Question, Urgency, Subtle).
   - Graphic cover text ready for visuals.

7. **Integrated Visual Studio**:
   - 8 dynamic template directions (*Clean Editorial*, *Bold Typography*, *Swiss Grid*, *Creator Minimal*, *Dark Impact*, *Luxury Editorial*, *Soft Modern*, *High Contrast*).
   - Dynamically styled with creator brand colors, handles, and cover text.

8. **Export & Share Hub**:
   - One-tap "Copy All Content" formatted for instant paste.
   - Native share integration (`share_plus`) for sending to Instagram, WhatsApp, Notes.
   - Watermark branding toggle.
   - History archiving and duplication.

---

## 🚀 Running & Building the Application

### 1. Environment Setup
Create a `.env` file at the root (JSON format for Flutter):
```json
{
  "API_BASE_URL": "https://creatediff-api.onrender.com",
  "SUPABASE_URL": "https://YOUR_PROJECT_REF.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY"
}
```

### 2. Backend Startup (FastAPI)
```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 3. Flutter Mobile App
```bash
# Development: run against backend and Supabase
flutter run --dart-define-from-file=.env

# Static analysis (0 warnings / 0 errors)
flutter analyze

# Run full automated test suite (183 tests)
flutter test

# Build debug APK
flutter build apk --debug --dart-define-from-file=.env

# Build production release APK
flutter build apk --release --dart-define-from-file=.env
```

---

## 📁 Architecture Overview

```
Flutter Mobile Client (UI / State / Local-First Store)
         ↓ (Bearer Token)
FastAPI Backend (/api/v1 - Auth Middleware, Rate Limiting, RLS)
         ↓
Groq AI Engine (openai/gpt-oss-120b) + Supabase PostgreSQL (Profiles, Feedback, Usage)
```

---

## 🔒 Security & Secrets Architecture

- **Mobile App**: Zero secret keys, JWT secrets, or Groq API keys are stored in the Flutter binary. Only public Supabase anon key and API Base URL are provided at build time.
- **Backend API**: All upstream AI keys, database credentials, and service role keys are managed strictly server-side.
- **Database**: Strict Row Level Security (RLS) policies enforce user isolation across all tables.

---

## 📄 License
Private & Proprietary — Developed for CreateDiff.
