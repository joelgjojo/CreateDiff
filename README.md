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

## 🚀 Running the App

### Launching the Application
Flutter configuration is compile-time JSON consumed by `--dart-define-from-file`. The root `.env` contains the local public Supabase URL/key and backend URL; it is ignored by git. Never put a Supabase service-role key in this file.

```bash
# Development: backend and Supabase cloud auth
flutter run --dart-define-from-file=.env

# Release APK: use the same configuration source
flutter build apk --release --dart-define-from-file=.env
```

VS Code's debug and release launch profiles use the same `--dart-define-from-file=.env` argument. Run configuration tests with the same defines:

```bash
flutter test --dart-define-from-file=.env
```

If either Supabase value is missing or contains a placeholder, initialization fails with a developer configuration error. Only a genuinely absent configuration activates offline guest mode.

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
ApiConfig (compile-time non-secret backend URL)
         ↓
Groq / xAI Responses API (/chat/completions)
```

---

## 🔒 Security & Backend Proxy Roadmap

> [!IMPORTANT]
> **API Key Architecture Notice**:
> - Provider API keys and Supabase JWT secrets are backend-only.
> - Flutter receives only a non-secret backend URL through `--dart-define` and sends authenticated bearer tokens.

---

## 📄 License
Private & Proprietary — Developed for CreateDiff.
