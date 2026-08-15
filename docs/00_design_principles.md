# CreateDiff — Design Principles & Build Guardrails

> **This document is binding.** Every screen, component, animation, and interaction decision must pass the tests below. Read this before starting any FlutterFlow build work.

---

## 1. Product Identity

CreateDiff is a **premium creator/design product** — not a generic AI dashboard, not a chatbot wrapper, not a SaaS template.

The UI must feel like it belongs alongside Canva, VSCO, or Notion — tools that creators pay for because the interface itself communicates quality.

**Test:** Would an Instagram creator or small business owner in Kerala look at this and think "this feels premium enough to pay for"? If not, redesign.

---

## 2. Glass Material System — Selective, Not Decorative

The Apple-inspired glass system exists to create **depth and visual grouping**, not decoration.

### Use Glass For:
- Bottom navigation bar (floating, translucent)
- Elevated floating controls
- Content pack section cards (subtle, for scanning)
- Modal overlays

### Do NOT Use Glass For:
- Every card on screen
- Form inputs
- List items
- Buttons
- Text containers
- Anything where transparency reduces readability

**Rule:** If removing the glass treatment doesn't hurt usability or visual hierarchy, remove it.

---

## 3. AI-Slop Prevention (Strictly Enforced)

These patterns are **absolutely forbidden** unless the user explicitly requests them:

| Forbidden Pattern | Why |
|---|---|
| Purple/blue gradient backgrounds | Looks like every AI demo from 2023 |
| Floating gradient blobs | Decorative noise with no function |
| Glowing UI borders | Cheap futuristic aesthetic |
| Excessive glassmorphism | Makes everything look the same |
| AI sparkle icons (✨ as UI chrome) | Screams "AI wrapper" |
| Robot/AI illustrations | We're selling content creation, not AI |
| Gradient text fills | Reduces readability for decoration |
| Giant pill-shaped controls | Overused, feels generic |
| Grid/particle mesh backgrounds | No functional purpose |
| Random 3D floating objects | Decoration without meaning |
| Excessive shadows on everything | Flattens hierarchy by making everything "elevated" |
| Decorative effects without purpose | If it doesn't serve the workflow, remove it |

**Test:** Print the screen in grayscale. Is the hierarchy still clear? Is the primary action still obvious? If yes, the design is strong.

---

## 4. Design Hierarchy (This Order Is Not Negotiable)

```
Typography → Layout → Spacing → Material → Color → Motion
```

Do NOT reverse this. The app must look beautiful even if all gradients, shadows, blur effects, and color accents are stripped away. The underlying **typographic hierarchy, spatial rhythm, and layout composition** must carry the design on their own.

### What This Means in Practice:
- Use **Inter** with precise weight differentiation (400/500/600/700)
- Every heading level must be visually distinct through **size + weight + spacing**, not color
- Whitespace is a design tool — use it generously between sections (24–32px minimum)
- Alignment must be pixel-perfect — no drifting margins
- Cards earn their border/shadow only if they group related interactive content

---

## 5. Core Workflow Priority

The **Create → Content Pack → Design → Export** flow is the product. Everything else exists to support it.

### Build and polish in this order:
1. **Create workflow** (platform → idea → generate)
2. **Content Pack result** (hooks, caption, CTAs, hashtags, cover text)
3. **Design selection** (templates, brand application)
4. **Home screen** (quick access to creation)
5. **Brand Memory** (personalization engine)
6. **History** (content management)
7. **Profile/Settings** (configuration)

Do NOT spend time polishing the Profile screen while the Content Pack result feels rough.

---

## 6. Zero-Prompt Experience

Users must **never** see a prompt box, a system message, or any indication they are "talking to an AI."

### What the user sees:
- "What's your content about?"
- A simple text field with a friendly hint
- Optional controls for language/tone/length

### What happens behind the scenes:
- `buildPrompt()` constructs a structured prompt incorporating platform, content type, idea, niche, audience, tone, language, brand voice, CTA preferences
- The prompt is **completely hidden** from the user
- The user only interacts with the simple, guided UI

**Test:** Could your grandmother use this without understanding what "prompt engineering" means? If not, simplify.

---

## 7. Platform-Specific Output

Generated content must be **formatted for the target platform**, not generic text.

| Platform | Output Must Include |
|---|---|
| Instagram Reel | Hooks (short, punchy), caption with emoji + line breaks, CTAs, hashtags (grouped by reach), reel cover text |
| Instagram Post | Caption with structured paragraphs, emoji placement, CTA, hashtags |
| Instagram Story | Short copy, hook, CTA, story slide suggestions |
| YouTube | Title (SEO-optimized), description with sections, hooks, tags |
| LinkedIn | Professional hook, structured body, appropriate CTA, professional hashtags |

The mock AI service must produce **different output structures** for each platform.

---

## 8. Brand Memory Must Be Visible

If a user sets up their brand as:
- **Name:** TechWithJoel
- **Tone:** Educational + Casual
- **Language:** English with some Malayalam
- **Niche:** Technology for students
- **Emoji:** Moderate
- **CTA Style:** Question-based

Then the generated content must **visibly reflect all of these**. The mock outputs should:
- Reference the creator's niche in generated text
- Use the specified tone consistently
- Include Malayalam/Manglish phrases where the language setting calls for it
- Match the emoji density to the preference
- Style CTAs to match the selected approach

**Test:** Show two content packs side by side — one for a "Professional/Minimal" tech creator and one for a "Funny/Heavy emoji" food creator. They should look and feel completely different.

---

## 9. Multilingual Mock Content

The mock AI outputs must include realistic examples in:
- **English** — primary
- **Malayalam** — full Malayalam script content
- **Manglish** — Malayalam written in English script (common among Kerala creators)
- **Hindi** — Devanagari script content

These should not be afterthoughts. The multilingual packs should feel as polished and realistic as the English ones.

### Example Manglish hooks:
- "Ithu arinjaal nee rich aakum 💰"
- "Ee 5 tools illathe students padikkanda"
- "Njan ithuvare kanditta illatha AI trick 🤯"

### Example Malayalam hooks:
- "ഈ 5 AI ടൂളുകൾ നിങ്ങൾ അറിഞ്ഞിരിക്കണം"
- "ഇത് അറിഞ്ഞാൽ നിങ്ങളുടെ ജീവിതം മാറും"

---

## 10. Security & Architecture

- **Never** expose API keys, tokens, or credentials in the FlutterFlow client
- The AI provider layer must be **replaceable**: Mock → API Call → Backend Proxy → Provider
- Mark all AI-related API calls as **Private** in FlutterFlow (server-side proxy)
- Build for **Android first**, but never use Android-specific APIs that break iOS
- Use FlutterFlow's built-in Safe Area handling for both platforms

---

## 11. One Primary Action Per Screen

Every screen must have **one obvious thing the user should do**.

| Screen | Primary Action | Visual Treatment |
|---|---|---|
| Home | Create Content | Quick action grid, prominent |
| Create (Step 1) | Select content type | Content type cards |
| Create (Step 2) | Generate | "Create Content" button, full-width, accent color |
| Content Pack | Use This Content | Full-width primary button, bottom-pinned |
| Design Selection | Use This Design | Full-width primary button, bottom-pinned |
| History | Tap a past project | List items with clear tap targets |
| Profile | Edit brand | Edit action on each section |

If a user lands on a screen and pauses for more than 2 seconds wondering "what do I do?", the screen has failed.

---

## 12. No Feature Creep

Do **not** add any of these to the MVP:
- Video editing
- AI video generation
- Social media scheduling
- Analytics dashboard
- Social account integrations
- Team collaboration
- Marketplace
- Enterprise features
- Complex subscription management
- Multiple AI model selection UI

The MVP ships when the core flow works beautifully:
**Splash → Onboarding → Brand Setup → Home → Create → Content Pack → Design → Save**

---

## 13. Design Quality = Product Differentiator

Design quality is not a cosmetic finishing step applied after "the real work." It **is** the real work.

CreateDiff's design should make users feel:
- "This feels like a real product"
- "This is made for people like me"
- "I trust this with my brand"

The bar is: **quietly impressive, not visually loud.**
