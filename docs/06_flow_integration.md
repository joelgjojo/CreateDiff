# CreateDiff — End-to-End Flow Integration & Polish Spec

> This document fills every gap in the existing screen specifications that would prevent a coherent, polished end-to-end experience. It specifies exact data flow between screens, save mechanics, export/share state, error recovery, and the precise action chains that make the core workflow feel seamless.
>
> **Read this after building all screens. Apply before considering the MVP complete.**

---

## 1. THE FLOW (with every data handoff)

```
SplashPage
  │  [auto 2.5s]
  │  Reads: hasCompletedOnboarding, hasCompletedProfileSetup
  ▼
OnboardingPage
  │  [tap "Get Started"]
  │  Writes: hasCompletedOnboarding = true
  ▼
CreatorProfilePage
  │  [tap "Complete Setup"]
  │  Writes: currentCreatorProfile = {all form fields}
  │  Writes: hasCompletedProfileSetup = true
  ▼
HomePage
  │  [tap Quick Action, e.g., "Instagram Reel"]
  │  Passes: initialPlatform = "Instagram" (page parameter)
  ▼
CreatePage
  │  [Step 0: select content type → Step 1: describe idea → tap "Create Content ✦"]
  │  Writes: currentContentProject = new ContentProject(...)
  │  Writes: isGenerating = true
  │  Calls: generateMockContent(...) with ALL brand memory fields
  │  On success: Writes currentGeneratedContent = parsed result
  │  Writes: isGenerating = false
  │  Writes: add currentContentProject to contentHistory (persisted)
  │  Passes: contentProjectId (page parameter)
  ▼
ContentResultPage
  │  Reads: currentContentProject, currentGeneratedContent
  │  [user reviews hooks, caption, CTAs, hashtags, cover text]
  │  [tap "Choose Design"]
  │  Passes: contentProjectId (page parameter)
  ▼
DesignSelectionPage
  │  Reads: currentGeneratedContent (for cover text / content preview in templates)
  │  Reads: currentCreatorProfile (for brand colors, logo in templates)
  │  [select a template → tap "Use This Design"]
  │  Writes: update currentContentProject.status = 'designed'
  ▼
ExportShareSheet (Bottom Sheet)
  │  Shows: export/share options
  │  [user taps Share, Copy All, or Done]
  │  On "Done": Navigate to HomePage (Replace All routes)
```

---

## 2. MISSING DATA TYPE FIELDS

The existing `ContentProject` data type is missing fields needed for the full flow. Add these:

### Updated `ContentProject`

| Field Name | Data Type | Is List | New? | Purpose |
|:---|:---|:---|:---|:---|
| `id` | String | False | | Unique identifier |
| `platform` | String | False | | e.g., "Instagram" |
| `contentType` | String | False | | e.g., "Reel" |
| `idea` | String | False | | User's input |
| `createdAt` | DateTime | False | | Timestamp |
| `status` | String | False | | 'generated', 'designed', 'exported' |
| **`generatedContent`** | **GeneratedContent** | **False** | **✓** | **The AI output, stored WITH the project** |
| **`selectedDesignTemplate`** | **String** | **False** | **✓** | **Which template was chosen** |
| **`selectedDesignStyle`** | **String** | **False** | **✓** | **'minimal', 'bold', 'premium'** |
| **`language`** | **String** | **False** | **✓** | **Language used for generation** |
| **`tone`** | **String** | **False** | **✓** | **Tone used for generation** |

> **Why:** Without `generatedContent` stored on the project, opening a history item cannot display the content pack. Without `selectedDesignTemplate`, there is no record of which design the user chose.

---

## 3. MISSING APP STATE VARIABLE

Add one persisted variable:

| Variable Name | Type | Is List | Default | Persisted | Purpose |
|:---|:---|:---|:---|:---|:---|
| **`generatedContentMap`** | **JSON** | **False** | `{}` | **Yes** | **Maps contentProjectId → GeneratedContent JSON. Enables reopening history items.** |

### Why a separate map instead of nesting inside ContentProject?
FlutterFlow's persisted App State works best with flat data types. Storing the full GeneratedContent (with its multiple List<String> fields) nested inside a List<ContentProject> can cause serialization issues. The map approach keeps contentHistory lightweight while the actual content is stored by ID.

### Alternative approach (simpler):
If FlutterFlow handles nested persisted data types cleanly in your version, skip the map and embed `generatedContent` directly on ContentProject. Test persistence with a round-trip (generate → close app → reopen → open history item) before committing to either approach.

---

## 4. EXACT ACTION CHAIN: "Create Content ✦" BUTTON

This is the most important action in the entire app. Every step must be specified:

```
User taps "Create Content ✦" on CreatePage (Step 1)
│
├── 1. Validate ideaText is not empty (button should already be disabled, but guard)
│
├── 2. Update App State: isGenerating = true
│      → This triggers the CDLoadingState overlay (conditional visibility)
│
├── 3. Create a new ContentProject:
│      id: generateUUID() — use a Custom Function that returns DateTime.now().millisecondsSinceEpoch.toString()
│      platform: selectedPlatform
│      contentType: selectedContentType
│      idea: ideaText
│      createdAt: getCurrentTimestamp()
│      status: 'generating'
│      language: selectedLanguage
│      tone: selectedTone
│      → Store as App State: currentContentProject
│
├── 4. Call Custom Action: generateMockContent(
│      platform: selectedPlatform,
│      contentType: selectedContentType,
│      idea: ideaText,
│      creatorName: currentCreatorProfile.creatorName,
│      niche: currentCreatorProfile.niche,
│      audience: currentCreatorProfile.targetAudience,
│      tone: selectedTone,
│      language: selectedLanguage,
│      emojiUsage: currentCreatorProfile.emojiUsage,
│      ctaStyle: currentCreatorProfile.preferredCTAStyle,
│      brandVoice: currentCreatorProfile.brandDescription,
│    )
│    → Returns: String (JSON)
│
├── 5. ON SUCCESS:
│    ├── Call Custom Action: parseGeneratedContent(jsonString)
│    │   → Returns: parsed data
│    ├── Update App State: currentGeneratedContent = parsed GeneratedContent
│    ├── Update currentContentProject.status = 'generated'
│    ├── Add currentContentProject to contentHistory (App State, persisted)
│    ├── Store generatedContentMap[project.id] = jsonString (persisted)
│    ├── Update App State: isGenerating = false
│    └── Navigate to ContentResultPage
│        Parameters: contentProjectId = currentContentProject.id
│        Transition: SlideRight 300ms
│        Type: Push (not Replace — user can go back)
│
├── 6. ON ERROR:
│    ├── Update App State: isGenerating = false
│    ├── Show SnackBar / Bottom Sheet:
│    │   "Something went wrong. Please try again."
│    │   Action: [Try Again] button → re-run from step 2
│    └── Do NOT navigate away. Stay on CreatePage.
```

---

## 5. EXACT ACTION CHAIN: SAVE BUTTON (ContentResultPage)

When the user taps "Save" on the ContentResultPage bottom bar:

```
User taps "Save" (CDSecondaryButton with bookmark_border icon)
│
├── 1. Check if project already in contentHistory
│      (it should be — it was added during generation)
│
├── 2. Show SnackBar:
│      Text: "Content saved to your history"
│      Duration: 2 seconds
│      Icon: check_circle, Success color
│
├── 3. Animate the bookmark icon:
│      Change icon from bookmark_border → bookmark (filled)
│      Change color from SecondaryText → Primary
│      This is a visual confirmation only — the save already happened at generation time
│
└── 4. No navigation. User stays on ContentResultPage.
```

---

## 6. EXACT ACTION CHAIN: "Use This Content" BUTTON (ContentResultPage)

When the user taps "Use This Content" (the primary button on ContentResultPage):

```
User taps "Use This Content"
│
├── 1. Show Bottom Sheet: ExportShareSheet
│      (See Section 8 below for full specification)
│
└── 2. The bottom sheet provides:
       • Copy All — copies hooks + caption + CTAs + hashtags as formatted text
       • Share — triggers native share dialog
       • Done — dismisses sheet
```

---

## 7. EXACT ACTION CHAIN: "Use This Design" BUTTON (DesignSelectionPage)

When the user taps "Use This Design" after selecting a template:

```
User taps "Use This Design"
│
├── 1. Update currentContentProject:
│      selectedDesignTemplate: template name (e.g., "Clean Type")
│      selectedDesignStyle: template style (e.g., "minimal")
│      status: 'designed'
│
├── 2. Update the project in contentHistory (replace matching id)
│
├── 3. Show Bottom Sheet: ExportShareSheet
│      (full specification in Section 8)
│
└── 4. When ExportShareSheet is dismissed with "Done":
       Navigate to HomePage
       Transition: Fade 400ms
       Type: Replace All (clear the navigation stack)
```

---

## 8. NEW: ExportShareSheet (Bottom Sheet)

This is the **final step** of the core flow — the moment the user reaches "ready to publish." It must feel satisfying and conclusive.

### Trigger:
Shown when the user taps "Use This Content" on ContentResultPage OR "Use This Design" on DesignSelectionPage.

### Type:
FlutterFlow Bottom Sheet (modal, non-dismissible by backdrop tap)

### Widget Tree:
```
BottomSheet
  Key Properties:
    Background: Theme SecondaryBackground
    Border Radius: Top-Left 24, Top-Right 24
    enableDrag: true
    Padding: 0

└── Column (crossAxisAlignment: center)
    ├── // Drag handle
    │   Container (width: 40, height: 4, borderRadius: pill)
    │   Background: custom divider color
    │   Margin: top 12, bottom 20
    │
    ├── // Success state
    │   Icon: check_circle_rounded (48px, Success color)
    │   Animation: scale from 0 to 1 (spring, 400ms)
    │
    ├── SizedBox(16)
    │
    ├── Text: "Your content is ready"
    │   Style: Headline Medium, PrimaryText, center
    │
    ├── SizedBox(4)
    │
    ├── Text: "${platform} ${contentType} • ${idea truncated to 30 chars}"
    │   Style: Body Small, SecondaryText, center
    │
    ├── SizedBox(28)
    │
    ├── // Actions
    │   Padding (horizontal: 24)
    │   └── Column
    │       ├── _ExportActionRow
    │       │   icon: content_copy
    │       │   label: "Copy All Content"
    │       │   subtitle: "Hooks, caption, CTA, and hashtags"
    │       │   onTap: → copyAllContent() action, then show SnackBar "Copied to clipboard ✓"
    │       │
    │       ├── Divider (custom divider color, indent: 52)
    │       │
    │       ├── _ExportActionRow
    │       │   icon: share_rounded
    │       │   label: "Share"
    │       │   subtitle: "Share via other apps"
    │       │   onTap: → trigger native Share intent with formatted content text
    │       │
    │       ├── Divider (custom divider color, indent: 52)
    │       │
    │       ├── _ExportActionRow
    │       │   icon: download_rounded
    │       │   label: "Save Design"
    │       │   subtitle: "Save image to gallery"
    │       │   // Conditional visibility: only show if a design was selected
    │       │   onTap: → save design image (future capability — for MVP show "Coming soon" toast)
    │       │
    │       ├── // If design was selected:
    │       │   Divider (custom divider color, indent: 52)
    │       │
    │       └── _ExportActionRow
    │           icon: history_rounded
    │           label: "Open in History"
    │           subtitle: "View or edit later"
    │           onTap: → dismiss sheet, navigate to ContentResultPage for this project
    │
    ├── SizedBox(24)
    │
    ├── // Done button
    │   Padding (horizontal: 24)
    │   └── CDPrimaryButton
    │       label: "Done"
    │       isFullWidth: true
    │       onPressed:
    │         1. Dismiss bottom sheet
    │         2. Navigate to HomePage (Replace All, Fade 400ms)
    │
    └── SizedBox(bottom safe area + 16)
```

### _ExportActionRow (inline pattern, not a separate component):
```
InkWell
└── Padding (vertical: 14)
    └── Row
        ├── Container (40x40, Accent2 bg, circle)
        │   └── Icon (icon, 20px, Primary color)
        ├── SizedBox(12)
        ├── Expanded
        │   └── Column (crossAxisAlignment: start)
        │       ├── Text: label — Title Small, PrimaryText
        │       └── Text: subtitle — Body Small, SecondaryText
        └── Icon: chevron_right, 18px, SecondaryText
```

---

## 9. CUSTOM ACTION: `copyAllContent`

Add this custom action for the "Copy All Content" feature:

```dart
// Custom Action: copyAllContent
// Parameters:
//   hooks (List<String>)
//   caption (String)
//   ctas (List<String>)
//   hashtagsHigh (List<String>)
//   hashtagsMedium (List<String>)
//   hashtagsNiche (List<String>)
//   coverText (String)
// Return type: void

import 'package:flutter/services.dart';

Future<void> copyAllContent(
  List<String> hooks,
  String caption,
  List<String> ctas,
  List<String> hashtagsHigh,
  List<String> hashtagsMedium,
  List<String> hashtagsNiche,
  String coverText,
) async {
  final buffer = StringBuffer();

  // Hooks
  buffer.writeln('═══ HOOKS ═══');
  for (int i = 0; i < hooks.length; i++) {
    buffer.writeln('${i + 1}. ${hooks[i]}');
  }
  buffer.writeln('');

  // Caption
  buffer.writeln('═══ CAPTION ═══');
  buffer.writeln(caption);
  buffer.writeln('');

  // CTA
  buffer.writeln('═══ CALL TO ACTION ═══');
  for (final cta in ctas) {
    buffer.writeln('• $cta');
  }
  buffer.writeln('');

  // Hashtags
  buffer.writeln('═══ HASHTAGS ═══');
  final allTags = [...hashtagsHigh, ...hashtagsMedium, ...hashtagsNiche];
  buffer.writeln(allTags.join(' '));
  buffer.writeln('');

  // Cover Text
  buffer.writeln('═══ COVER TEXT ═══');
  buffer.writeln(coverText);

  await Clipboard.setData(ClipboardData(text: buffer.toString()));
}
```

---

## 10. CUSTOM FUNCTION: `generateProjectId`

```dart
// Custom Function: generateProjectId
// Return type: String
// Parameters: none

String generateProjectId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}
```

---

## 11. HISTORY ITEM → CONTENT RESULT (reopening a past project)

When a user taps a `CDRecentContentCard` on HomePage or HistoryPage:

```
User taps a history item
│
├── 1. Retrieve the tapped ContentProject from contentHistory by id
│
├── 2. Retrieve the stored generated content:
│      Read generatedContentMap[project.id]
│      Parse JSON → GeneratedContent
│
├── 3. Update App State:
│      currentContentProject = selected project
│      currentGeneratedContent = parsed content
│
└── 4. Navigate to ContentResultPage
       Parameters: contentProjectId = project.id
       Transition: SlideRight 300ms
       Type: Push
```

### Edge case: missing content
If `generatedContentMap[project.id]` is null (data was cleared, corruption, etc.):
- Show the CDErrorState inside ContentResultPage
- Title: "Content unavailable"
- Message: "This content pack is no longer available. You can regenerate it."
- Action: "Regenerate" → navigate to CreatePage with the same platform and idea pre-filled

---

## 12. DESIGN TEMPLATE PREVIEW IMAGES

The DesignSelectionPage shows design templates, but the current spec says `previewImageUrl: (mock design preview)` without specifying what these images actually are.

### For the MVP, create 6 design previews as static assets:

Generate or create these as actual image files (PNG, 1080x1350px — Instagram post ratio 4:5):

| # | Name | Style | Visual Description |
|---|------|-------|--------------------|
| 1 | Clean Type | Minimal | White background, centered text in Inter Bold, thin rule lines, minimal color. Cover text displayed prominently. |
| 2 | Bold Statement | Bold | Full-bleed solid color background (user's brand primaryColor or fallback #6C5CE7), large uppercase text filling the frame, strong contrast. |
| 3 | Editorial | Premium | Off-white/cream background, serif-style layout (simulate with Inter at different weights), generous margins, subtle brand color accent line. |
| 4 | Gradient Type | Minimal | Soft neutral gradient (warm gray → white), centered text, very clean. |
| 5 | Impact | Bold | Dark background (#1A1A1E), bright text, bold weight, cinematic feel. |
| 6 | Luxe | Premium | Deep muted tone background, elegant spacing, subtle texture, gold or brand accent. |

### How brand identity applies to templates:
- **Brand primaryColor**: Used as the accent color in templates 1, 3, 4 (replacing the default violet)
- **Brand primaryColor**: Used as the full background in template 2
- **Brand logo**: Placed as a small watermark (bottom-right, 40px, 30% opacity) if `logoUrl` is set
- **Cover text from GeneratedContent**: Displayed as the main text element in all templates

### Static asset approach for MVP:
Since true dynamic image generation is not an MVP requirement, use pre-rendered static template previews. Store 6 images in FlutterFlow's asset library. The user selects a style direction — actual rendering with their brand/content happens in a future version.

---

## 13. SNACKBAR / TOAST SPECIFICATIONS

Consistent feedback throughout the flow. Use FlutterFlow's built-in SnackBar widget:

### Success SnackBar
- Background: Success color (#00B894 light / #00D2A0 dark)
- Text: white, Label Large
- Icon: check_circle, white, 20px
- Duration: 2000ms
- Position: bottom
- Border radius: medium (12)
- Margin: horizontal 20, bottom 80 (above nav bar)

### Copy SnackBar
- Background: Tertiary (#2D2D3A light / #3D3D4E dark)
- Text: white, Label Large — "Copied to clipboard"
- Icon: content_copy, white, 18px
- Duration: 1500ms

### Error SnackBar
- Background: Error color
- Text: white, Label Large
- Icon: error_outline, white, 20px
- Duration: 3000ms
- Action text: "Try Again" (white, underlined)

---

## 14. BACK NAVIGATION & STATE PRESERVATION

### From ContentResultPage → back to CreatePage:
- The generated content is already saved in App State and contentHistory
- CreatePage state is NOT preserved (standard Flutter behavior)
- This is acceptable — the user's content is safe in history

### From DesignSelectionPage → back to ContentResultPage:
- No state loss — contentProjectId is passed as parameter
- ContentResultPage reads from App State currentGeneratedContent

### From any screen → Home via Bottom Nav:
- Use **Replace Route** (not Push) to prevent stack buildup
- The bottom nav should track `selectedNavIndex` in App State

### Dismissing ExportShareSheet:
- Tapping "Done" → Navigate to HomePage with Replace All
- Swiping down / tapping outside → only dismiss sheet, stay on current page

---

## 15. FIRST-RUN FLOW: ZERO CONTENT STATE

On first launch after completing profile setup, the user arrives at HomePage with:
- Empty contentHistory → CDEmptyState in "Recent" section
- Brand card populated from profile
- Quick actions fully functional

The CTA in the empty state should say **"Create your first content pack"** and navigate to CreatePage.

After the user's first successful generation:
- The content appears in "Recent" on HomePage immediately (contentHistory is updated before navigating to ContentResultPage)
- When the user eventually returns to HomePage (via "Done" in ExportShareSheet), the recent section shows their creation

---

## 16. LOADING STATE TIMING

The CDLoadingState component cycles through messages during generation. Exact timing:

```
0ms     → "Understanding your idea..."
2500ms  → "Applying your brand style..."
5000ms  → "Optimizing for ${platform}..."
7500ms  → "Writing your content pack..."
10000ms → "Almost there..."
```

The mock generation takes 2-4 seconds (random). The messages should still cycle at least once to feel natural. If generation completes during the first message, hold the overlay for an additional 500ms before transitioning to avoid a jarring flash.

### Implementation:
In CDLoadingState's component state, use a periodic timer (2500ms interval) that increments `currentMessageIndex`. On generation complete:
1. Wait 500ms minimum display time
2. Fade out the overlay (300ms opacity animation)
3. Then navigate

---

## 17. SCREEN-LEVEL VERIFICATION CHECKLIST

Before considering the MVP complete, verify each of these as a continuous flow (do not test in isolation):

### Full Flow Test
- [ ] Cold launch → SplashPage auto-navigates to OnboardingPage
- [ ] Swipe through all 4 onboarding slides
- [ ] Tap "Get Started" → CreatorProfilePage
- [ ] Fill Step 0: name "TechWithJoel", handle "@techwjoel", niche "Technology"
- [ ] Fill Step 1: audience "College students", tone "Educational", style "Short-form casual"
- [ ] Fill Step 2: language "Manglish", secondary "English", emoji "Moderate"
- [ ] Fill Step 3: brand description, CTA style "Question", pick brand color
- [ ] Fill Step 4: skip socials → "Complete Setup"
- [ ] Arrive at HomePage → greeting shows, brand card populated, recent section empty
- [ ] Tap "Instagram Reel" quick action
- [ ] CreatePage opens at Step 1 (platform pre-selected)
- [ ] Type idea: "5 AI tools students should know"
- [ ] Tap "Create Content ✦"
- [ ] Loading overlay appears with cycling messages
- [ ] ContentResultPage appears with 5 hooks, caption, CTAs, hashtags, cover text
- [ ] Verify content reflects Manglish + Educational tone + Moderate emoji
- [ ] Tap copy on a hook → "Copied" snackbar
- [ ] Tap "Choose Design" → DesignSelectionPage
- [ ] Select "Bold Statement" template
- [ ] Tap "Use This Design" → ExportShareSheet appears
- [ ] Tap "Copy All Content" → "Copied" snackbar
- [ ] Tap "Done" → HomePage
- [ ] Verify recent section now shows the content card
- [ ] Tap the recent card → ContentResultPage reopens with saved content
- [ ] Close app completely, reopen → SplashPage → auto-navigates to HomePage (skips onboarding)
- [ ] Verify recent content and brand card persist

### Error Flow Test
- [ ] If generation fails: loading overlay dismisses, error snackbar shows, user can retry
- [ ] If history item has no stored content: error state with "Regenerate" option

### Dark Mode Test
- [ ] Toggle to dark mode in Profile → Preferences
- [ ] Verify all screens are legible, glass surfaces render correctly, accent color is visible
- [ ] No white text on white backgrounds, no invisible borders

---

*End of integration spec.*
