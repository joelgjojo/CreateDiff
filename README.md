# CreateDiff — AI Content & Design Studio for Creators

> **Idea → AI Content Pack → Designed Visual → Edit → Export**
> 
> A mobile-first creator studio that eliminates prompting. Tell CreateDiff what you're posting in natural words, and receive a complete, platform-optimized, personalized content pack with custom visual layouts ready to publish.

---

## 🌟 Core Product Features

1. **Zero-Prompt Engine**:
   - No blank prompt boxes or AI chatbot interactions.
   - Invisible translation of simple creator thoughts into structured, platform-optimized output.

2. **Brand Memory System**:
   - Persists creator niche, tone of voice, target audience, emoji preferences, preferred CTA style, and brand accent colors.
   - Outputs reflect the creator's identity across all platforms and languages.

3. **Multilingual Content Generation**:
   - Full support for **English**, **Malayalam**, **Manglish**, and **Hindi**.
   - Contextual regional hashtags and dialect-specific hooks.

4. **Complete Content Packs**:
   - 5 high-converting hook variations with one-tap copy & bookmarking.
   - Formatted platform-specific captions with word counter and in-place editing.
   - Segmented hashtags (High Reach, Medium/Regional, Niche).
   - Strategic Calls-to-Action (Direct, Question, Urgency, Subtle).
   - Graphic cover text ready for visuals.

5. **Integrated Visual Studio**:
   - 6 dynamic template directions (*Clean Type*, *Bold Statement*, *Editorial*, *Gradient Type*, *Impact Dark*, *Luxe Minimal*).
   - Dynamically styled with creator brand colors, handles, and cover text.

6. **Export & Share Hub**:
   - One-tap "Copy All Content" formatted for instant paste.
   - Native share integration (`share_plus`) for sending to Instagram, WhatsApp, Notes.
   - History archiving and re-opening.

---

## 🎨 Design Philosophy

- **Apple-Inspired Selective Glass**: Subtle blur, thin borders, and elevation without decorative noise.
- **Strictly Anti-AI Slop**: No purple gradient blobs, glowing neon borders, robot avatars, or generic dashboard templates.
- **Design Hierarchy**: `Typography → Layout → Spacing → Material → Color → Motion`.
- **Full Material 3 & Dark Mode**: Handcrafted deep graphite dark mode alongside warm white light mode.

---

## 📁 Repository Structure

```
CreateDiff/
├── docs/                        # Complete FlutterFlow Specification Blueprints
│   ├── 00_design_principles.md  # Binding design guardrails & AI-slop prevention rules
│   ├── 01_project_setup.md      # Theme tokens, colors, typography, data types, app state
│   ├── 02_components.md         # 19 reusable FlutterFlow component blueprints
│   ├── 03_screens_part1.md      # Splash, Onboarding, Profile Setup, Home, Create specs
│   ├── 04_screens_part2.md      # Content Result, Design Selection, History, Profile specs
│   ├── 05_custom_code_and_ai.md # Zero-prompt engine, mock AI service, multilingual packs
│   └── 06_flow_integration.md   # End-to-end integration, action chains, export sheet spec
│
├── lib/                         # Native Flutter Production Application
│   ├── components/              # 20 tactile reusable studio widgets
│   │   ├── cd_glass_card.dart
│   │   ├── cd_primary_button.dart
│   │   ├── cd_secondary_button.dart
│   │   ├── cd_bottom_nav_bar.dart
│   │   ├── cd_content_type_card.dart
│   │   ├── cd_platform_selector.dart
│   │   ├── cd_hook_card.dart
│   │   ├── cd_caption_card.dart
│   │   ├── cd_hashtag_group.dart
│   │   ├── cd_design_template_card.dart
│   │   ├── cd_recent_content_card.dart
│   │   ├── cd_brand_memory_card.dart
│   │   ├── cd_loading_state.dart
│   │   ├── cd_error_state.dart
│   │   ├── cd_empty_state.dart
│   │   ├── cd_section_header.dart
│   │   ├── cd_text_input.dart
│   │   ├── cd_onboarding_slide.dart
│   │   ├── cd_quick_action_card.dart
│   │   └── cd_export_share_sheet.dart
│   │
│   ├── models/                  # Data types & models
│   │   ├── creator_profile.dart
│   │   ├── content_project.dart
│   │   ├── generated_content.dart
│   │   └── design_template.dart
│   │
│   ├── screens/                 # Mobile screen flows
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── creator_profile_screen.dart
│   │   ├── home_screen.dart
│   │   ├── create_screen.dart
│   │   ├── content_result_screen.dart
│   │   ├── design_selection_screen.dart
│   │   ├── history_screen.dart
│   │   ├── profile_screen.dart
│   │   └── main_shell.dart
│   │
│   ├── services/                # State & AI engine
│   │   ├── ai_service.dart      # Zero-prompt engine & brand memory mock AI
│   │   ├── storage_service.dart # SharedPreferences persistent state
│   │   └── app_state.dart       # Reactive ChangeNotifier state provider
│   │
│   ├── theme/
│   │   └── app_theme.dart       # Theme tokens, Inter font scale, spacing, radius
│   └── main.dart                # App entrypoint
│
└── test/                        # Automated test suites
    ├── widget_test.dart         # Smoke test
    └── e2e_flow_test.dart       # End-to-end workflow & brand memory validation
```

---

## 🚀 Running & Testing

### Prerequisites
- Flutter SDK `^3.13.0` / Flutter 3.47+
- Dart SDK `^3.13.0`

### Commands
```bash
# Get dependencies
flutter pub get

# Run test suite
flutter test

# Run app on simulator / device
flutter run
```

---

## 📄 License
Private & Proprietary — Developed for CreateDiff.
