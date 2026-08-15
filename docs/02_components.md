# CreateDiff - Component Specifications

This document outlines the detailed specifications for every reusable FlutterFlow component needed for CreateDiff. These components should be built in the FlutterFlow Component Builder and utilized across the application to ensure consistency and maintainability.

---

## 1. CDBottomNavBar

**Purpose:** Floating bottom navigation bar providing primary app navigation across 5 main tabs (Home, Create, Designs, History, Profile).

**Parameters:**
- `selectedIndex` (Integer, Required): The currently active tab index (0 to 4).

**Callback Actions:**
- `onTabChanged` (Action): Fired when a tab is tapped. Passes `int index` as an Action Argument.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Main Wrapper)
└── ClipRRect (Backdrop Filter - Blur)
    └── Container (Glass Background)
        └── Row (Main Axis Alignment: Space Evenly)
            ├── Column (Tab 0 - Home)
            │   ├── Icon (home_rounded)
            │   └── Text ('Home') [Conditional Visibility]
            ├── Stack (Tab 1 - Create - Prominent)
            │   ├── Container (Subtle Filled Circle)
            │   └── Column
            │       ├── Icon (add_circle_rounded)
            │       └── Text ('Create') [Conditional Visibility]
            ├── Column (Tab 2 - Designs)
            │   ├── Icon (palette_rounded)
            │   └── Text ('Designs') [Conditional Visibility]
            ├── Column (Tab 3 - History)
            │   ├── Icon (history_rounded)
            │   └── Text ('History') [Conditional Visibility]
            └── Column (Tab 4 - Profile)
                ├── Icon (person_rounded)
                └── Text ('Profile') [Conditional Visibility]
```

**Styling Details:**
- **Main Container:** Margin Bottom 16, Margin Horizontal 20. Safe area bottom padding enabled.
- **Glass Container:** Padding Vertical 8, Padding Horizontal 12. Background Color: `surfaceElevated`. Border: 1px `glassBorder`. Border Radius: 20 (xl). Shadow: Offset(0, 2), Blur 12, Color `rgba(0,0,0,0.06)`.
- **Icons:** Size 24 (28 for Create tab).
  - Active Tab: `Primary` color.
  - Inactive Tab: `SecondaryText` color.
- **Text Labels:** `Label Small`, `Primary` color.
- **Create Tab Background Circle:** Width 48, Height 48, Shape Circle, Color `Primary` at 10% opacity.

**Conditional Visibility Rules:**
- The `Text` label in each tab column is only visible if `selectedIndex == [tab_index]`.

**Action Flows on Interactions:**
- **On Tap (any tab Column/Stack):** Execute Callback `onTabChanged`, passing the respective integer index.

---

## 2. CDPrimaryButton

**Purpose:** Main call-to-action button used for primary user actions.

**Parameters:**
- `label` (String, Required): Button text.
- `icon` (Widget, Optional): Leading icon.
- `isLoading` (Boolean, Optional, Default: false): Shows loading state.
- `isFullWidth` (Boolean, Optional, Default: false): Expands to parent width.

**Callback Actions:**
- `onPressed` (Action): Executed when tapped (only if `isLoading` is false).

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Wrapper for width/scale control)
└── MouseRegion (For hover effects if needed)
    └── InkWell (Tap interaction)
        └── Container (Button Background)
            └── Stack (Center Alignment)
                ├── Row (Main Axis Alignment: Center) [Conditional: !isLoading]
                │   ├── [Passed Widget] icon [Conditional: icon is set]
                │   └── Text (label)
                └── CircularProgressIndicator [Conditional: isLoading]
```

**Styling Details:**
- **Wrapper Container:** Width: `double.infinity` (if `isFullWidth` == true) else `null`. Height: 48.
- **Button Container:** Background Color: `Primary`. Border Radius: 12 (medium). Disabled State (if `isLoading` or disabled): 40% opacity.
- **Text:** Color `White`, Typography `Label Large`, Font Weight Bold.
- **CircularProgressIndicator:** Color `White`, Size 24.

**Conditional Visibility Rules:**
- Show `Row` containing text/icon ONLY IF `isLoading == false`.
- Show `CircularProgressIndicator` ONLY IF `isLoading == true`.
- Show `icon` ONLY IF the `icon` parameter is provided.

**Action Flows on Interactions:**
- **On Tap (InkWell):**
  1. Add a slight scale-down animation to 0.97 (Duration 100ms), then scale back up to 1.0 (Duration 100ms).
  2. Conditional Action: If `isLoading == false`, Execute Callback `onPressed`.

---

## 3. CDSecondaryButton

**Purpose:** Alternative action button for secondary interactions (e.g., Edit, Cancel).

**Parameters:**
- `label` (String, Required): Button text.
- `icon` (Widget, Optional): Leading icon.

**Callback Actions:**
- `onPressed` (Action): Executed when tapped.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Button Background)
    └── Row (Main Axis Alignment: Center)
        ├── [Passed Widget] icon [Conditional: icon is set]
        └── Text (label)
```

**Styling Details:**
- **Container:** Height: 44. Background Color: `Accent2` (very subtle violet). Border: 1px `Primary` at 20% opacity. Border Radius: 12 (medium). Padding Horizontal 16.
- **Text:** Color `Primary`, Typography `Label Large`.

**Conditional Visibility Rules:**
- Show `icon` ONLY IF the `icon` parameter is provided.

**Action Flows on Interactions:**
- **On Tap:** Execute Callback `onPressed`.

---

## 4. CDGlassCard

**Purpose:** Reusable, slightly elevated card container with a glassmorphism aesthetic for content grouping.

**Parameters:**
- `child` (Widget, Required): The content to place inside the card.

**Callback Actions:** None.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Main Card)
└── [Passed Widget] child
```

**Styling Details:**
- **Container:** Background Color: `cardSurface`. Border: 1px `glassBorder`. Border Radius: 16 (large). Shadow: Offset(0, 1), Blur 8, Color `rgba(0,0,0,0.04)`. Padding: 16 (all sides).

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:** None.

---

## 5. CDContentTypeCard

**Purpose:** Selectable card for choosing the type of content to generate (e.g., Reel, Post) in a grid layout.

**Parameters:**
- `icon` (IconData, Required): Representational icon.
- `label` (String, Required): Type name.
- `description` (String, Required): Brief explanation.
- `isSelected` (Boolean, Required): True if currently selected.

**Callback Actions:**
- `onTap` (Action): Fired when the card is tapped.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Card Wrapper)
    └── Column (Cross Axis Alignment: Start)
        ├── Icon (icon parameter)
        ├── Text (label parameter)
        └── Text (description parameter)
```

**Styling Details:**
- **Card Wrapper:**
  - Selected State (`isSelected == true`): Border 2px `Primary`, Background `Accent1`.
  - Unselected State (`isSelected == false`): Border 1px `glassBorder`, Background `cardSurface`.
  - Border Radius: 16 (large). Padding: 16.
- **Icon:** Size 28. Color: `Primary` if selected, else `SecondaryText`. Padding Bottom: 12.
- **Label Text:** Typography `Title Small`. Color `PrimaryText`. Padding Bottom: 4.
- **Description Text:** Typography `Body Small`. Color `SecondaryText`.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Tap:**
  1. Trigger subtle scale animation (scale to 0.98, duration 100ms).
  2. Execute Callback `onTap`.

---

## 6. CDPlatformSelector

**Purpose:** Horizontal scrollable row of pill-shaped chips to select a target platform.

**Parameters:**
- `platforms` (List<String>, Required): Available platforms (e.g., ['Instagram', 'TikTok', 'LinkedIn']).
- `selectedPlatform` (String, Required): Currently selected platform.

**Callback Actions:**
- `onPlatformSelected` (Action): Fired when a chip is tapped. Passes `String platformName`.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Wrapper for constrained height)
└── ListView (Direction: Horizontal)
    └── Generating Children from Variable (platforms list)
        └── InkWell
            └── Container (Chip)
                └── Text (platform item)
```

**Styling Details:**
- **ListView:** Spacing: 8. Padding Horizontal: 20.
- **Chip Container:**
  - Selected State (`item == selectedPlatform`): Background `Primary`.
  - Unselected State: Background `Accent3`.
  - Border Radius: 100 (pill). Padding Horizontal 16, Vertical 8.
- **Text:**
  - Selected State: Color `White`, Typography `Label Large`.
  - Unselected State: Color `SecondaryText`, Typography `Label Large`.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Tap (InkWell):** Execute Callback `onPlatformSelected`, passing the current item string.

---

## 7. CDHookCard

**Purpose:** Displays a single generated video/post hook with action buttons.

**Parameters:**
- `index` (Integer, Required): The 1-based index of the hook.
- `hookText` (String, Required): The hook content.
- `isSaved` (Boolean, Required): Whether the hook is saved to user's favorites.

**Callback Actions:**
- `onCopy` (Action): Copy text to clipboard.
- `onSave` (Action): Toggle save state.
- `onRegenerate` (Action): Request a new hook for this slot.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Column
├── Row (Cross Axis Alignment: Start)
│   ├── Container (Number Badge)
│   │   └── Text (index.toString())
│   ├── Expanded
│   │   └── Text (hookText)
│   └── Row (Action Buttons)
│       ├── IconButton (Copy)
│       ├── IconButton (Save)
│       └── IconButton (Regenerate)
└── Divider [Conditional Visibility]
```

**Styling Details:**
- **Number Badge Container:** Width 20, Height 20, Shape Circle, Background Color `Accent2`. Margin Right 12.
- **Number Badge Text:** Typography `Label Small`, Color `Primary`, Center aligned.
- **Hook Text:** Typography `Body Medium`, Color `PrimaryText`.
- **Action Buttons:** Size 36, Icon Size 18. Color `SecondaryText`.
  - Copy Icon: `content_copy`.
  - Save Icon: `bookmark_filled` (if `isSaved`) else `bookmark_outline`.
  - Regenerate Icon: `refresh`.
- **Divider:** Color `glassBorder`, Height 1, Margin Top 16, Margin Bottom 16.

**Conditional Visibility Rules:**
- Show **Divider** only if it's not the last item in a list (handled by parent ListView context or passed boolean parameter like `isLast`).

**Action Flows on Interactions:**
- **On Tap Copy:** Copy `hookText` to clipboard, show snackbar "Copied!".
- **On Tap Save:** Execute Callback `onSave`. Icon color temporarily pulses `Primary`.
- **On Tap Regenerate:** Execute Callback `onRegenerate`. Icon spins.

---

## 8. CDCaptionCard

**Purpose:** Displays the generated caption formatted for readability, with quick actions.

**Parameters:**
- `captionText` (String, Required): The generated caption.
- `platform` (String, Required): The target platform (e.g., 'Instagram').

**Callback Actions:**
- `onCopy` (Action): Fired when copy is requested.
- `onEdit` (Action): Fired to open edit modal/screen.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (CardWrapper)
└── Column (Cross Axis Alignment: Start)
    ├── Container (Platform Badge)
    │   └── Text (platform)
    ├── Text (captionText)
    └── Row (Actions Row - Main Axis Alignment: End)
        ├── CDSecondaryButton (Copy)
        └── CDSecondaryButton (Edit)
```

**Styling Details:**
- **CardWrapper Container:** Background `cardSurface`, Border Radius 16 (large), Padding 20 (all sides).
- **Platform Badge Container:** Background `Accent2`, Border Radius 100 (pill), Padding Horizontal 10, Vertical 4, Margin Bottom 12.
- **Platform Badge Text:** Typography `Label Small`, Color `Primary`.
- **Caption Text:** Typography `Body Large`, Color `PrimaryText`, Line Height 1.6. Margin Bottom 20.
- **Actions Row:** Gap 12. Use compact versions of `CDSecondaryButton` if necessary.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Tap Copy:** Execute Callback `onCopy`.
- **On Tap Edit:** Execute Callback `onEdit`.

---

## 9. CDHashtagGroup

**Purpose:** Displays a block of generated hashtags categorized by reach/relevance.

**Parameters:**
- `label` (String, Required): Category title (e.g., 'High Reach').
- `hashtags` (List<String>, Required): List of hashtags without the '#'.

**Callback Actions:**
- `onCopyAll` (Action): Fired to copy the entire block of tags.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Column (Cross Axis Alignment: Start)
├── Row (Main Axis Alignment: Space Between)
│   ├── Text (label)
│   └── InkWell (Copy Action)
│       └── Row
│           ├── Icon (copy)
│           └── Text ('Copy')
└── Wrap
    └── Generating Children from Variable (hashtags)
        └── Container (Hashtag Chip)
            └── Text ('#' + item)
```

**Styling Details:**
- **Column Container:** Margin Bottom 20.
- **Label Row:** Margin Bottom 12.
- **Label Text:** Typography `Label Large`, Color `PrimaryText`.
- **Copy Action:** Icon Size 16, Color `SecondaryText`. Text `Label Small`, `SecondaryText`.
- **Wrap Widget:** Spacing (Main Axis): 6, Run Spacing (Cross Axis): 6.
- **Hashtag Chip Container:** Background `Accent3`, Border Radius 100 (pill), Padding Horizontal 10, Vertical 4.
- **Hashtag Text:** Typography `Body Small`, Color `SecondaryText`.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Tap Copy Action:** Combine `hashtags` list into a single space-separated string with '#' prefixes. Copy to clipboard. Execute Callback `onCopyAll`.

---

## 10. CDDesignTemplateCard

**Purpose:** Selectable preview card for a Canva/FlutterFlow design template.

**Parameters:**
- `templateName` (String, Required): Name of the template.
- `style` (String, Required): Style category (e.g., 'Minimal').
- `previewImageUrl` (String, Required): URL for the template image.
- `isSelected` (Boolean, Required): True if selected.

**Callback Actions:**
- `onSelect` (Action): Fired when card is tapped.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Wrapper)
    └── Column
        ├── Stack (Image Preview Area)
        │   ├── ClipRRect (Image Wrapper)
        │   │   └── Image (previewImageUrl, BoxFit.cover)
        │   └── Positioned (Top Right)
        │       └── Container (Style Badge)
        │           └── Text (style)
        └── Container (Text Area)
            └── Text (templateName)
```

**Styling Details:**
- **Wrapper Container:**
  - Selected: Border 2px `Primary`, Scale transform to 1.02.
  - Unselected: Border 1px `glassBorder`.
  - Border Radius 16.
- **Image Preview Area:** Aspect Ratio 4:5 (Standard Instagram Portrait).
- **ClipRRect:** Border Radius 16.
- **Style Badge:** Background `Accent2`, Padding Horizontal 8, Vertical 4, Border Radius 100, Margin Top 8, Margin Right 8.
- **Style Badge Text:** Typography `Label Small`, Color `Primary`.
- **Text Area:** Padding Top 12.
- **Template Name Text:** Typography `Title Small`, Center aligned.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Tap:** Execute Callback `onSelect`.

---

## 11. CDRecentContentCard

**Purpose:** List item displaying a historical or recently created content piece.

**Parameters:**
- `platform` (String, Required): E.g., 'Instagram', 'YouTube'.
- `idea` (String, Required): The core idea or title.
- `contentType` (String, Required): E.g., 'Reel', 'Short'.
- `date` (String, Required): Formatted date string (e.g., '2 hours ago').
- `thumbnailUrl` (String, Optional): Preview image.

**Callback Actions:**
- `onTap` (Action): Fired to view details.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Card Wrapper)
    └── Row
        ├── Stack (Thumbnail Area)
        │   ├── ClipRRect (Image) [Conditional Visibility]
        │   └── Container (Fallback Icon Circle) [Conditional Visibility]
        │       └── Icon (Platform Icon)
        ├── Expanded (Content Area)
        │   └── Column (Cross Axis Alignment: Start)
        │       ├── Text (idea)
        │       └── Text (contentType + ' • ' + date)
        └── Icon (chevron_right)
```

**Styling Details:**
- **Card Wrapper:** Background `cardSurface` (or transparent if in list), Padding 12, Border Radius 16 (large).
- **Thumbnail Area:** Width 48, Height 48, Margin Right 12.
- **ClipRRect (Image):** Border Radius 8 (small), BoxFit cover.
- **Fallback Icon Circle:** Border Radius 8 (small). Background color dynamically set based on `platform` (Instagram: `#E4405F`, YouTube: `#FF0000`, LinkedIn: `#0A66C2`). Icon color White, size 24.
- **Title Text:** Typography `Title Small`, Color `PrimaryText`, Max Lines 2, Text Overflow: Ellipsis.
- **Subtitle Text:** Typography `Body Small`, Color `SecondaryText`.
- **Chevron Icon:** Size 18, Color `SecondaryText`.

**Conditional Visibility Rules:**
- **ClipRRect Image:** Show IF `thumbnailUrl` is set and not empty.
- **Fallback Icon Circle:** Show IF `thumbnailUrl` is empty or null.

**Action Flows on Interactions:**
- **On Tap:** Execute Callback `onTap`.

---

## 12. CDBrandMemoryCard

**Purpose:** Compact widget summarizing a brand profile on the Home screen.

**Parameters:**
- `creatorName` (String, Required)
- `niche` (String, Required)
- `primaryColor` (Color, Required)
- `logoUrl` (String, Optional)

**Callback Actions:**
- `onTap` (Action): Open Brand Settings.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Card Wrapper)
    └── Row
        ├── Stack (Avatar)
        │   ├── ClipRRect (Image) [Conditional]
        │   └── Container (Initials Fallback) [Conditional]
        │       └── Text (First letter of creatorName)
        ├── Expanded (Text Info)
        │   └── Column (Cross Axis Alignment: Start)
        │       ├── Text (creatorName)
        │       └── Text (niche)
        └── Icon (edit_rounded)
```

**Styling Details:**
- **Card Wrapper:** Background `cardSurface`, Border 1px `glassBorder`, Border Radius 16, Padding 12.
- **Avatar Area:** Width 36, Height 36, Margin Right 12.
- **ClipRRect:** Shape Circle.
- **Initials Fallback Container:** Shape Circle, Background Color: `primaryColor` parameter.
- **Initials Text:** Typography `Label Large`, Color White, Center aligned.
- **Name Text:** Typography `Title Small`, Color `PrimaryText`.
- **Niche Text:** Typography `Body Small`, Color `SecondaryText`.
- **Edit Icon:** Size 16, Color `SecondaryText`.

**Conditional Visibility Rules:**
- Show Image IF `logoUrl` is set.
- Show Initials IF `logoUrl` is empty.

**Action Flows on Interactions:**
- **On Tap:** Execute Callback `onTap`.

---

## 13. CDLoadingState

**Purpose:** Full-screen or inline polished loading component to entertain users while AI generates content.

**Parameters:**
- `messages` (List<String>, Required): E.g., ['Analyzing trend...', 'Writing hooks...', 'Polishing captions...'].

**Callback Actions:** None.

**Component State Variables:**
- `currentMessageIndex` (Integer, Default: 0)

**EXACT Widget Tree:**
```text
Container (Wrapper)
└── Column (Main Axis Alignment: Center, Cross Axis Alignment: Center)
    ├── LottieAnimation (or Image with pulsing animation)
    ├── Text (messages[currentMessageIndex]) (Wrapped in implicit animation)
    └── Row (Progress Dots - optional purely visual indicator)
```

**Styling Details:**
- **Wrapper:** Center aligned in available space.
- **Animation/Icon:** Size 80x80. Subtle pulsing or rotating effect.
- **Text:** Typography `Title Medium`, Color `PrimaryText`, Center aligned. Margin Top 24. Apply Fade transition when text changes.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:**
- **On Initialization:** Start a Periodic Timer (interval: 2500ms).
- **On Timer Tick:** Update Component State: `currentMessageIndex = (currentMessageIndex + 1) % messages.length`.
- **On Dispose:** Cancel Timer.

---

## 14. CDErrorState

**Purpose:** Generic error display when an API call or generation fails.

**Parameters:**
- `title` (String, Optional, Default: 'Something went wrong')
- `message` (String, Required): Detailed error description.
- `showRetry` (Boolean, Optional, Default: true)

**Callback Actions:**
- `onRetry` (Action): Executed when the user wants to try again.

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Wrapper)
└── Column (Main Axis Alignment: Center, Cross Axis Alignment: Center)
    ├── Icon (error_outline)
    ├── Text (title)
    ├── Text (message)
    └── CDPrimaryButton (Label: 'Try Again') [Conditional]
```

**Styling Details:**
- **Wrapper:** Centered padding 24.
- **Icon:** Size 48, Color `Error` theme color. Margin Bottom 16.
- **Title Text:** Typography `Headline Small`, Color `PrimaryText`. Margin Bottom 8.
- **Message Text:** Typography `Body Medium`, Color `SecondaryText`, Center aligned. Margin Bottom 24.

**Conditional Visibility Rules:**
- Show `CDPrimaryButton` ONLY IF `showRetry == true`.

**Action Flows on Interactions:**
- **On Retry Button Tap:** Execute Callback `onRetry`.

---

## 15. CDEmptyState

**Purpose:** Displayed when lists are empty (e.g., no history, no designs).

**Parameters:**
- `title` (String, Required)
- `message` (String, Required)
- `actionLabel` (String, Optional)

**Callback Actions:**
- `onAction` (Action, Optional)

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Wrapper)
└── Column (Main Axis Alignment: Center, Cross Axis Alignment: Center)
    ├── Image/Icon (Illustration placeholder)
    ├── Text (title)
    ├── Text (message)
    └── CDPrimaryButton (Label: actionLabel) [Conditional]
```

**Styling Details:**
- **Image:** Width/Height 120, Opacity 0.5. Margin Bottom 16.
- **Title Text:** Typography `Headline Small`, Color `PrimaryText`. Margin Bottom 8.
- **Message Text:** Typography `Body Medium`, Color `SecondaryText`, Center aligned. Margin Bottom 24.

**Conditional Visibility Rules:**
- Show `CDPrimaryButton` ONLY IF `actionLabel` is provided.

**Action Flows on Interactions:**
- **On Button Tap:** Execute Callback `onAction`.

---

## 16. CDSectionHeader

**Purpose:** Standard header for UI sections (e.g., 'Recent Designs').

**Parameters:**
- `title` (String, Required)
- `actionLabel` (String, Optional, e.g., 'View All')

**Callback Actions:**
- `onAction` (Action, Optional)

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Container (Wrapper)
└── Row (Main Axis Alignment: Space Between, Cross Axis Alignment: Center)
    ├── Text (title)
    └── InkWell [Conditional]
        └── Text (actionLabel)
```

**Styling Details:**
- **Wrapper:** Padding Bottom 12, Horizontal 0.
- **Title Text:** Typography `Headline Small`, Color `PrimaryText`.
- **Action Label Text:** Typography `Label Large`, Color `Primary`.

**Conditional Visibility Rules:**
- Show `InkWell` (Action Label) ONLY IF `actionLabel` is provided.

**Action Flows on Interactions:**
- **On Action Label Tap:** Execute Callback `onAction`.

---

## 17. CDTextInput

**Purpose:** Styled form input field to maintain consistent design.

**Parameters:**
- `label` (String, Required)
- `hint` (String, Required)
- `maxLines` (Integer, Optional, Default: 1)
- `isRequired` (Boolean, Optional, Default: false)

**Component State Variables:** None. (State is typically managed by a Page-level Form/Widget State).

**EXACT Widget Tree:**
```text
Column (Cross Axis Alignment: Start)
├── Text (label) (Append '*' if isRequired)
└── TextField
```

**Styling Details:**
- **Label Text:** Typography `Label Large`, Color `SecondaryText`. Margin Bottom 8.
- **TextField:**
  - Fill Color: `Accent3`
  - Border: None (UnderlineInputBorder/OutlineInputBorder set to borderSide.none)
  - Focused Border: Outline border, 1.5px `Primary`, Border Radius 12.
  - Border Radius: 12 (medium).
  - Content Padding: Horizontal 16, Vertical 14.
  - Input Text Style: Typography `Body Large`, Color `PrimaryText`.
  - Max Lines: `maxLines` parameter.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:** Standard text field behaviors.

---

## 18. CDOnboardingSlide

**Purpose:** Content structure for a single page in the onboarding PageView.

**Parameters:**
- `headline` (String, Required)
- `description` (String, Required)
- `illustrationWidget` (Widget, Required)

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
Column (Main Axis Alignment: Center, Cross Axis Alignment: Center)
├── Spacer
├── [Passed Widget] illustrationWidget
├── Spacer
├── Text (headline)
├── Text (description)
└── Spacer
```

**Styling Details:**
- **Headline Text:** Typography `Display Medium`, Color `PrimaryText`, Center aligned. Margin Bottom 12.
- **Description Text:** Typography `Body Large`, Color `SecondaryText`, Center aligned. Max Width: 300.
- **Spacers:** Used to balance the illustration in the top half and text in the bottom half.

**Conditional Visibility Rules:** None.

**Action Flows on Interactions:** None.

---

## 19. CDQuickActionCard

**Purpose:** Prominent square-ish button for the Home screen to trigger specific flows (e.g., 'New Reel').

**Parameters:**
- `icon` (IconData, Required)
- `label` (String, Required)
- `sublabel` (String, Optional)
- `accentColor` (Color, Required)

**Callback Actions:**
- `onTap` (Action)

**Component State Variables:** None.

**EXACT Widget Tree:**
```text
InkWell
└── Container (Card Wrapper)
    └── Column (Main Axis Alignment: Center, Cross Axis Alignment: Center)
        ├── Container (Icon Circle)
        │   └── Icon (icon parameter)
        ├── Text (label)
        └── Text (sublabel) [Conditional]
```

**Styling Details:**
- **Card Wrapper:** Size: Designed to fit flexibly within a GridView or Row (Expanded). Background `cardSurface`, Border Radius 16, Border 1px `glassBorder`. Padding 16.
- **Icon Circle Container:** Size 52x52, Shape Circle. Background Color: `accentColor` at 10% opacity. Margin Bottom 12.
- **Icon:** Color `accentColor`, Size 28.
- **Label Text:** Typography `Label Large`, Color `PrimaryText`, Center aligned.
- **Sublabel Text:** Typography `Body Small`, Color `SecondaryText`, Center aligned. Margin Top 4.

**Conditional Visibility Rules:**
- Show `sublabel` Text ONLY IF `sublabel` is provided.

**Action Flows on Interactions:**
- **On Tap:**
  1. Subtle scale animation.
  2. Execute Callback `onTap`.

---
*Generated for CreateDiff FlutterFlow Implementation*
