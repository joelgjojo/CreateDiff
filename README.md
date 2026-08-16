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

## 🚀 Running with Grok AI

### Prerequisites
- Flutter SDK `^3.13.0` / Flutter 3.29+
- Dart SDK `^3.13.0`
- xAI Grok API Key (from [console.x.ai](https://console.x.ai))

### Launching the Application
To run the app with your xAI Grok API key securely supplied at compile-time:

```bash
# Run locally with your Grok API key
flutter run --dart-define=GROK_API_KEY=your_xai_api_key

# Run with custom model override (optional, defaults to grok-4.5)
flutter run --dart-define=GROK_API_KEY=your_xai_api_key --dart-define=GROK_MODEL=grok-4.5

# Build release/debug APK with API key
flutter build apk --debug --dart-define=GROK_API_KEY=your_xai_api_key
```

> [!TIP]
> You can also test and configure connection keys at runtime inside the **Developer Debug Panel** (accessible via the bug icon in the Top App Bar).

---

## 🧪 Testing & Verification

```bash
# Run static analysis (0 warnings / 0 errors)
flutter analyze

# Run full automated test suite (including end-to-end Grok observability & screen rendering tests)
flutter test

# Build debug APK
flutter build apk --debug
```

---

## 📁 Architecture Overview

```
Flutter Mobile App (UI / State)
         ↓
AppState (Reactive State Manager) + UsageGuard (Rate Limiting & Cost Protection)
         ↓
AIService (Exponential Backoff Retry & Sanitize Layer)
         ↓
AIConfig / ApiConfig (Compile-time --dart-define & .env resolution)
         ↓
Groq / xAI Responses API (/chat/completions)
```

---

## 🔒 Security & Backend Proxy Roadmap

> [!IMPORTANT]
> **API Key Architecture Notice**:
> - **Phase 1 (Pre-Launch & Testing)**: The API key lives client-side via `--dart-define` / `.env` / local `ApiConfig`. This is acceptable for rapid pre-launch testing with free-tier developer keys.
> - **Phase 2 (Production Launch)**: In production mobile deployments, client-side `.env` files can be reverse-engineered from APK binaries. Before public release with real user volume, Grok/Groq API calls must move behind a server-side backend API Gateway proxy (e.g. Supabase Edge Functions / Cloudflare Workers / Node.js API) that keeps third-party provider keys 100% off user devices, attaches authenticated user tokens, and handles server-side quota enforcement.

---

## 📄 License
Private & Proprietary — Developed for CreateDiff.

