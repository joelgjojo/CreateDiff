# CreateDiff MVP - Screen Specifications (Part 2)

## SCREEN 6: ContentResultPage

Route: /result/:id
The premium content workspace showing all generated content.

### Page Parameters:
- contentProjectId (String)

### Page State:
- selectedVariation (int, default 0)
- expandedSection (String, default 'hooks') — which section is expanded

### Widget Tree:
```
Scaffold (bg: Theme PrimaryBackground)
└── SafeArea
    └── Column
        ├── // Header
        │   Padding (horizontal: 20, top: 12, bottom: 8)
        │   └── Row
        │       ├── IconButton (arrow_back, onTap: go back)
        │       ├── Expanded
        │       │   └── Column (crossAxisAlignment: start)
        │       │       ├── Text: 'Content Pack'
        │       │       │   Style: Headline Medium, PrimaryText
        │       │       └── Row
        │       │           ├── Container (Accent2 bg, pill, padding h:8 v:3)
        │       │           │   └── Text: platform — Label Small, Primary
        │       │           ├── SizedBox(6)
        │       │           └── Container (Accent3 bg, pill, padding h:8 v:3)
        │       │               └── Text: contentType — Label Small, SecondaryText
        │       └── IconButton (more_vert) — options menu (save, share, regenerate all)
        │
        ├── // Variation selector (if multiple variations)
        │   Padding (horizontal: 20, top: 8)
        │   └── Row
        │       ├── Text: 'Variation' — Label Large, SecondaryText
        │       ├── SizedBox(12)
        │       └── Row of variation dots/chips
        │           // Variation 1, 2, 3 — small numbered circles
        │           // Active: Primary bg, white text
        │           // Inactive: Accent3 bg, SecondaryText
        │
        ├── // Content sections — flex: 1
        │   Expanded
        │   └── SingleChildScrollView
        │       └── Padding (horizontal: 20, top: 16)
        │           └── Column
        │
        │               // === HOOKS SECTION ===
        │               CDGlassCard
        │               └── Column
        │                   ├── Row
        │                   │   ├── Text: 'Hooks' — Headline Small, PrimaryText
        │                   │   ├── Spacer
        │                   │   ├── IconButton (content_copy, 18px, SecondaryText) — copy all hooks
        │                   │   └── IconButton (refresh, 18px, SecondaryText) — regenerate hooks
        │                   ├── SizedBox(16)
        │                   ├── CDHookCard (index: 1, hookText: hooks[0])
        │                   ├── Divider (color: divider custom color, height: 1, indent: 28)
        │                   ├── CDHookCard (index: 2, hookText: hooks[1])
        │                   ├── Divider
        │                   ├── CDHookCard (index: 3, hookText: hooks[2])
        │                   ├── Divider
        │                   ├── CDHookCard (index: 4, hookText: hooks[3])
        │                   ├── Divider
        │                   └── CDHookCard (index: 5, hookText: hooks[4])
        │
        │               SizedBox(16)
        │
        │               // === CAPTION SECTION ===
        │               CDCaptionCard
        │                   captionText: generatedContent.caption
        │                   platform: selectedPlatform
        │
        │               SizedBox(16)
        │
        │               // === CTA SECTION ===
        │               CDGlassCard
        │               └── Column
        │                   ├── Row
        │                   │   ├── Text: 'Call to Action' — Headline Small, PrimaryText
        │                   │   ├── Spacer
        │                   │   └── IconButton (content_copy, 18px, SecondaryText)
        │                   ├── SizedBox(12)
        │                   └── Column
        │                       └── [For each CTA option: Row with bullet + text + copy icon]
        │                           // Bullet: 6x6 circle, Primary color
        │                           // Text: Body Medium, PrimaryText
        │                           // SizedBox(10) between items
        │
        │               SizedBox(16)
        │
        │               // === HASHTAGS SECTION ===
        │               CDGlassCard
        │               └── Column
        │                   ├── Text: 'Hashtags' — Headline Small, PrimaryText
        │                   ├── SizedBox(16)
        │                   ├── CDHashtagGroup (label: 'High Reach', hashtags: hashtagsHighReach)
        │                   ├── SizedBox(16)
        │                   ├── CDHashtagGroup (label: 'Medium Reach', hashtags: hashtagsMediumReach)
        │                   ├── SizedBox(16)
        │                   └── CDHashtagGroup (label: 'Niche', hashtags: hashtagsNiche)
        │
        │               SizedBox(16)
        │
        │               // === COVER TEXT SECTION ===
        │               CDGlassCard
        │               └── Column
        │                   ├── Row
        │                   │   ├── Text: 'Cover Text' — Headline Small, PrimaryText
        │                   │   ├── Spacer
        │                   │   └── IconButton (content_copy)
        │                   ├── SizedBox(12)
        │                   └── Text: coverText — Title Large, PrimaryText
        │                       // Display this prominently as it's for visual use
        │
        │               SizedBox(32)
        │
        │               // === DESIGN CTA ===
        │               CDGlassCard (special: slightly elevated, Accent1 background)
        │               └── Column (crossAxisAlignment: center)
        │                   ├── Text: 'Turn this into a design' — Headline Small, PrimaryText, center
        │                   ├── SizedBox(4)
        │                   ├── Text: 'Choose from professional templates' — Body Small, SecondaryText
        │                   ├── SizedBox(16)
        │                   └── CDPrimaryButton (label: 'Choose Design', onPressed: navigate to DesignSelectionPage)
        │
        │               SizedBox(100) // space for bottom
        │
        └── // Bottom action bar
            Container (surfaceElevated bg, border top: glassBorder)
            └── Padding (horizontal: 20, vertical: 12)
                └── Row
                    ├── CDSecondaryButton (label: 'Save', icon: bookmark_border)
                    │   onPressed: save to content history
                    ├── SizedBox(12)
                    └── Expanded
                        └── CDPrimaryButton (label: 'Use This Content')
                            onPressed: copy all content / show share options
```

### Copy Action Flow:
When user taps copy on any element:
1. Copy text to clipboard (using Clipboard custom action)
2. Show brief Toast/SnackBar: 'Copied!' with checkmark icon
3. Animate the copy icon to a checkmark briefly (300ms), then back

---

## SCREEN 7: DesignSelectionPage

Route: /designs/:id
Shows design templates for the generated content.

### Page Parameters:
- contentProjectId (String)

### Page State:
- selectedDesignIndex (int, default -1)
- selectedStyle (String, default 'all') — filter: all/minimal/bold/premium

### Widget Tree:
```
Scaffold (bg: Theme PrimaryBackground)
└── SafeArea
    └── Column
        ├── // Header
        │   Padding (horizontal: 20, top: 12, bottom: 8)
        │   └── Row
        │       ├── IconButton (arrow_back)
        │       ├── Expanded
        │       │   └── Text: 'Choose a Design' — Headline Medium, PrimaryText
        │       └── Text: 'Skip' — Label Large, SecondaryText
        │
        ├── // Style filter
        │   Padding (horizontal: 20, top: 8, bottom: 16)
        │   └── CDPlatformSelector  // reuse as style filter
        │       platforms: ['All', 'Minimal', 'Bold', 'Premium']
        │       selectedPlatform: selectedStyle
        │       onPlatformSelected: update selectedStyle filter
        │
        ├── // Design grid — flex: 1
        │   Expanded
        │   └── Padding (horizontal: 20)
        │       └── GridView (2 columns, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75)
        │           ├── CDDesignTemplateCard
        │           │   templateName: 'Clean Type'
        │           │   style: 'minimal'
        │           │   previewImageUrl: (mock design preview)
        │           │   isSelected: selectedDesignIndex == 0
        │           │   onSelect: set selectedDesignIndex = 0
        │           │
        │           ├── CDDesignTemplateCard
        │           │   templateName: 'Bold Statement'
        │           │   style: 'bold'
        │           │   ...
        │           │
        │           ├── CDDesignTemplateCard
        │           │   templateName: 'Editorial'
        │           │   style: 'premium'
        │           │   ...
        │           │
        │           ├── CDDesignTemplateCard (Gradient Type, minimal)
        │           ├── CDDesignTemplateCard (Impact, bold)
        │           └── CDDesignTemplateCard (Luxe, premium)
        │
        └── // Bottom action
            Container (surfaceElevated bg, border top: glassBorder)
            └── Padding (horizontal: 20, vertical: 12)
                └── CDPrimaryButton
                    label: selectedDesignIndex >= 0 ? 'Use This Design' : 'Select a design'
                    isFullWidth: true
                    // Disabled if nothing selected
                    onPressed:
                      1. Save design selection
                      2. Navigate to preview/export (or show success and go to Home for MVP)
```

---

## SCREEN 8: HistoryPage

Route: /history
Shows all previously generated content projects.

### Page State:
- filterPlatform (String, default 'all')
- sortOrder (String, default 'newest')

### Widget Tree:
```
Scaffold (bg: Theme PrimaryBackground)
└── Stack
    ├── SafeArea
    │   └── Column
    │       ├── // Header
    │       │   Padding (horizontal: 24, top: 16, bottom: 8)
    │       │   └── Text: 'History' — Display Small, PrimaryText
    │       │
    │       ├── // Platform filter
    │       │   Padding (horizontal: 24, top: 4, bottom: 16)
    │       │   └── CDPlatformSelector
    │       │       platforms: ['All', 'Instagram', 'YouTube', 'LinkedIn']
    │       │       selectedPlatform: filterPlatform
    │       │       onPlatformSelected: update filter, rebuild list
    │       │
    │       ├── // Content list — flex: 1
    │       │   Expanded
    │       │   └── // If no history:
    │       │       CDEmptyState
    │       │           title: 'No content yet'
    │       │           message: 'Content you create will be saved here for easy access'
    │       │           actionLabel: 'Create Content'
    │       │           onAction: navigate to CreatePage
    │       │       
    │       │       // If has history:
    │       │       ListView.builder (padding horizontal: 24)
    │       │       └── [For each filtered content project, sorted by date]:
    │       │           CDRecentContentCard
    │       │               platform: project.platform
    │       │               idea: project.idea
    │       │               contentType: project.contentType
    │       │               date: formatted relative date
    │       │               onTap: navigate to ContentResultPage with projectId
    │       │           SizedBox(8)
    │       │
    │       └── SizedBox(80) // space for nav
    │
    └── Align (bottomCenter)
        └── CDBottomNavBar (selectedIndex: 3)
```

---

## SCREEN 9: ProfilePage

Route: /profile
Profile, brand settings, and app preferences.

### Page State:
- editingSection (String, default '') — which section is being edited

### Widget Tree:
```
Scaffold (bg: Theme PrimaryBackground)
└── Stack
    ├── SafeArea
    │   └── SingleChildScrollView
    │       └── Column
    │           ├── // Header
    │           │   Padding (horizontal: 24, top: 16, bottom: 24)
    │           │   └── Column (crossAxisAlignment: center)
    │           │       ├── // Avatar
    │           │       │   Container (72x72, circle)
    │           │       │   └── if logoUrl: CircleAvatar with image
    │           │       │       else: CircleAvatar with initials, Primary bg
    │           │       ├── SizedBox(12)
    │           │       ├── Text: creatorName — Headline Medium, PrimaryText
    │           │       ├── SizedBox(4)
    │           │       └── Text: '@${username} • ${niche}' — Body Medium, SecondaryText
    │           │
    │           ├── // Profile Section
    │           │   Padding (horizontal: 24)
    │           │   └── CDGlassCard
    │           │       └── Column
    │           │           ├── CDSectionHeader (title: 'Profile', actionLabel: 'Edit')
    │           │           ├── _ProfileRow (label: 'Name', value: creatorName)
    │           │           ├── Divider (divider color)
    │           │           ├── _ProfileRow (label: 'Username', value: username)
    │           │           ├── Divider
    │           │           ├── _ProfileRow (label: 'Niche', value: niche)
    │           │           ├── Divider
    │           │           └── _ProfileRow (label: 'Audience', value: targetAudience)
    │           │   // _ProfileRow: Row with label (Body Medium, SecondaryText) and value (Body Medium, PrimaryText)
    │           │
    │           ├── SizedBox(16)
    │           │
    │           ├── // Brand Section
    │           │   Padding (horizontal: 24)
    │           │   └── CDGlassCard
    │           │       └── Column
    │           │           ├── CDSectionHeader (title: 'Brand', actionLabel: 'Edit')
    │           │           ├── _ProfileRow (label: 'Tone', value: tone)
    │           │           ├── Divider
    │           │           ├── _ProfileRow (label: 'Language', value: primaryLanguage)
    │           │           ├── Divider
    │           │           ├── _ProfileRow (label: 'CTA Style', value: ctaStyle)
    │           │           ├── Divider
    │           │           ├── Row
    │           │           │   ├── Text: 'Colors' — Body Medium, SecondaryText
    │           │           │   ├── Spacer
    │           │           │   ├── Circle (20x20, primaryColor)
    │           │           │   ├── SizedBox(6)
    │           │           │   └── Circle (20x20, secondaryColor)
    │           │           ├── Divider
    │           │           └── _ProfileRow (label: 'Emoji', value: emojiUsage)
    │           │
    │           ├── SizedBox(16)
    │           │
    │           ├── // Preferences Section
    │           │   Padding (horizontal: 24)
    │           │   └── CDGlassCard
    │           │       └── Column
    │           │           ├── CDSectionHeader (title: 'Preferences')
    │           │           ├── _PreferenceRow (label: 'Theme', value: 'System' / 'Light' / 'Dark')
    │           │           │   // Tap to cycle through options or show bottom sheet
    │           │           ├── Divider
    │           │           ├── _PreferenceRow (label: 'Default Platform', value: defaultPlatform)
    │           │           ├── Divider
    │           │           └── _PreferenceRow (label: 'Default Tone', value: defaultTone)
    │           │
    │           ├── SizedBox(16)
    │           │
    │           ├── // Account Section
    │           │   Padding (horizontal: 24)
    │           │   └── CDGlassCard
    │           │       └── Column
    │           │           ├── CDSectionHeader (title: 'Account')
    │           │           ├── _AccountRow (label: 'Privacy Policy', icon: chevron_right)
    │           │           ├── Divider
    │           │           ├── _AccountRow (label: 'Terms of Service', icon: chevron_right)
    │           │           ├── Divider
    │           │           ├── _AccountRow (label: 'About CreateDiff', icon: chevron_right)
    │           │           ├── Divider
    │           │           └── _AccountRow (label: 'Log Out', textColor: Error, icon: logout)
    │           │
    │           ├── SizedBox(24)
    │           │
    │           ├── // App version
    │           │   Text: 'CreateDiff v1.0.0' — Label Small, SecondaryText, center
    │           │
    │           └── SizedBox(100) // space for nav
    │
    └── Align (bottomCenter)
        └── CDBottomNavBar (selectedIndex: 4)
```

### Edit Action Flow:
When 'Edit' is tapped on Profile or Brand sections:
1. Navigate to CreatorProfilePage with current data pre-filled
2. On return, refresh profile data from App State
