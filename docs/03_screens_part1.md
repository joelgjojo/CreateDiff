# CreateDiff Screen Specifications - Part 1

This document contains COMPLETE FlutterFlow screen specifications for the first 5 screens of the CreateDiff application. 
All color references use FlutterFlow Theme conventions (e.g., `Theme Primary`, `Theme PrimaryText`, etc.). Components with `CD` prefix refer to the app's reusable component library.

---

## 1. SplashPage

**Page Name:** SplashPage  
**Route:** `/splash`  
**Description:** The initial loading screen that automatically routes the user based on their onboarding and profile setup status.

### Page State:
- None

### On Page Load Actions:
1. **Wait Action:** 2500ms
2. **Conditional Action:** Check App State `hasCompletedOnboarding`
   - **If FALSE:**
     - Navigate to `OnboardingPage`
     - Transition Type: Fade
     - Duration: 500ms
     - Route Replacement: TRUE (Clear history)
   - **If TRUE:**
     - **Conditional Action (Nested):** Check App State `hasCompletedProfileSetup`
       - **If FALSE:**
         - Navigate to `CreatorProfilePage`
         - Route Replacement: TRUE
       - **If TRUE:**
         - Navigate to `HomePage`
         - Route Replacement: TRUE

### Widget Tree:
```text
Scaffold
  Key Properties: Background Color = Theme PrimaryBackground
└── SafeArea
    └── Column
        Key Properties: Main Axis Alignment = center, Cross Axis Alignment = center
        ├── Spacer
        │   Key Properties: Flex = 3
        ├── Text: 'CreateDiff'
        │   Key Properties:
        │     Style = Theme Display Large
        │     Color = Theme PrimaryText
        │     Letter Spacing = -1.0
        │   Animations:
        │     1. Fade In: Duration = 800ms
        │     2. Slide: Duration = 800ms, Offset Y = 20px -> 0px
        ├── SizedBox
        │   Key Properties: Height = 8px
        ├── Text: 'Idea → Content → Design'
        │   Key Properties:
        │     Style = Theme Body Medium
        │     Color = Theme SecondaryText
        │   Animations:
        │     1. Fade In: Duration = 1200ms, Delay = 400ms
        ├── Spacer
        │   Key Properties: Flex = 4
        └── SizedBox
            Key Properties: Height = 80px (Accounts for safe area/home indicator)
```

### Action Flows & Navigation:
- **Automatic Navigation:** Handled entirely by the On Page Load action. No user interaction required.

### Conditional Visibility:
- None

### Animations & Transitions:
- Splash text has sequenced entry animations.
- Fade transition (500ms) to subsequent pages.

### Components Used:
- None

---

## 2. OnboardingPage

**Page Name:** OnboardingPage  
**Route:** `/onboarding`  
**Description:** A swipeable introduction to the app's core value propositions, culminating in the profile setup phase.

### Page State:
- `currentSlideIndex` (Integer, Default: 0)

### On Page Load Actions:
- None

### Widget Tree:
```text
Scaffold
  Key Properties: Background Color = Theme PrimaryBackground
└── SafeArea
    └── Column
        Key Properties: Main Axis Alignment = start, Cross Axis Alignment = stretch
        ├── Row // Top Bar
        │   Key Properties: Padding = L:20 R:20 T:12 B:0
        │   ├── Spacer
        │   └── InkWell
        │       Action: 
        │         1. Update App State: hasCompletedOnboarding = true
        │         2. Navigate to CreatorProfilePage (Route Replacement: True)
        │       └── Text: 'Skip'
        │           Key Properties:
        │             Style = Theme Label Large
        │             Color = Theme SecondaryText
        ├── Expanded
        │   Key Properties: Flex = 1
        │   └── PageView
        │       Key Properties: 
        │         Axis = Horizontal
        │         Controller = PageViewController (default)
        │       Action (On Page Changed):
        │         Update Page State: currentSlideIndex = Widget State PageView Index
        │       ├── CDOnboardingSlide (Component)
        │       │   Parameters:
        │       │     headline: 'Create better content.\nFaster.'
        │       │     description: 'Turn one idea into a complete content pack — hooks, captions, hashtags, and designs.'
        │       │     illustrationIcon: Icons.bolt
        │       ├── CDOnboardingSlide (Component)
        │       │   Parameters:
        │       │     headline: 'No prompting\nrequired.'
        │       │     description: 'Tell CreateDiff what you\'re posting and we\'ll handle the rest. No AI knowledge needed.'
        │       │     illustrationIcon: Icons.auto_awesome
        │       ├── CDOnboardingSlide (Component)
        │       │   Parameters:
        │       │     headline: 'Make it sound\nlike you.'
        │       │     description: 'CreateDiff remembers your niche, tone, language, and brand style for every generation.'
        │       │     illustrationIcon: Icons.fingerprint
        │       └── CDOnboardingSlide (Component)
        │           Parameters:
        │             headline: 'Designed, not\njust generated.'
        │             description: 'Turn your content into polished social media visuals — ready to post.'
        │             illustrationIcon: Icons.palette
        ├── SizedBox
        │   Key Properties: Height = 32px
        ├── Row // Progress Dots
        │   Key Properties: Main Axis Alignment = center
        │   ├── Container (Dot 0)
        │   │   Key Properties:
        │   │     Width: If currentSlideIndex == 0 then 24px else 8px
        │   │     Height: 8px
        │   │     Border Radius: 8px
        │   │     Background Color: If currentSlideIndex == 0 then Theme Primary else Theme Accent3
        │   │   Animations: Implicit Animations Enabled (Duration 300ms)
        │   ├── SizedBox (Width = 8px)
        │   ├── Container (Dot 1) // Same logic as Dot 0, checking index 1
        │   ├── SizedBox (Width = 8px)
        │   ├── Container (Dot 2) // Same logic as Dot 0, checking index 2
        │   ├── SizedBox (Width = 8px)
        │   └── Container (Dot 3) // Same logic as Dot 0, checking index 3
        ├── SizedBox
        │   Key Properties: Height = 32px
        ├── Padding
        │   Key Properties: Padding = L:24 R:24 T:0 B:0
        │   └── CDPrimaryButton (Component)
        │       Parameters:
        │         label: If currentSlideIndex < 3 then 'Continue' else 'Get Started'
        │         isFullWidth: true
        │       Action (On Pressed):
        │         Conditional:
        │           If currentSlideIndex < 3:
        │             Control PageView: Next Page (Duration: 300ms, Curve: easeInOut)
        │           Else:
        │             1. Update App State: hasCompletedOnboarding = true
        │             2. Navigate to CreatorProfilePage
        └── SizedBox
            Key Properties: Height = 24px
```

### Action Flows & Navigation:
- **Skip Button Tap:** Sets `hasCompletedOnboarding` to true and skips to `CreatorProfilePage`.
- **Swipe PageView:** Updates `currentSlideIndex` page state variable.
- **Bottom Button Tap:** Advances PageView if not on the last slide. If on the last slide, saves onboarding state and navigates to `CreatorProfilePage`.

### Conditional Visibility:
- None directly hiding elements, but button text and dot styles are conditional based on `currentSlideIndex`.

### Animations & Transitions:
- Implicit animations on the pagination dots (width and color change smoothly).
- PageView swipe transitions.

### Components Used:
- `CDOnboardingSlide`
- `CDPrimaryButton`

---

## 3. CreatorProfilePage

**Page Name:** CreatorProfilePage  
**Route:** `/profile/setup`  
**Description:** A multi-step wizard to collect the user's brand identity, tone, language, and aesthetics.

### Page State:
- `currentStep` (Integer, Default: 0, Range: 0-4)
- Form Field States (Managed natively by FlutterFlow Widget States, but logic references these):
  - `creatorName`, `username`, `niche`, `category`
  - `targetAudience`, `tone`, `contentStyle`
  - `primaryLanguage`, `secondaryLanguage`, `emojiUsage`
  - `brandDescription`, `preferredCTAStyle`, `primaryColor`, `secondaryColor`
  - `websiteUrl`, `instagramHandle`, `youtubeHandle`, `logoUrl`

### On Page Load Actions:
- None

### Widget Tree:
```text
Scaffold
  Key Properties: Background Color = Theme PrimaryBackground
└── SafeArea
    └── Column
        Key Properties: Main Axis Alignment = start, Cross Axis Alignment = stretch
        ├── Padding // Header
        │   Key Properties: Padding = L:24 R:24 T:16 B:8
        │   └── Row
        │       ├── IconButton
        │       │   Key Properties: Icon = arrow_back, Color = Theme PrimaryText
        │       │   Conditional Visibility: currentStep > 0
        │       │   Action (On Tap): Update Page State currentStep = currentStep - 1
        │       ├── Expanded
        │       │   └── Column
        │       │       Key Properties: Cross Axis Alignment = start
        │       │       ├── Text: 'Set up your brand'
        │       │       │   Key Properties: Style = Theme Headline Medium, Color = Theme PrimaryText
        │       │       └── Text: 'Step ${currentStep + 1} of 5'
        │       │           Key Properties: Style = Theme Body Small, Color = Theme SecondaryText
        │       └── Text: 'Skip'
        │           Key Properties: Style = Theme Label Large, Color = Theme SecondaryText
        │           Conditional Visibility: currentStep == 4
        │           Action (On Tap): 
        │             1. Save available data to App State
        │             2. Update App State: hasCompletedProfileSetup = true
        │             3. Navigate to HomePage (Replace Route)
        ├── Padding // Progress Bar
        │   Key Properties: Padding = L:24 R:24 T:8 B:0
        │   └── ProgressBar
        │       Key Properties:
        │         Value: (currentStep + 1) / 5
        │         Background Color: Theme Accent3
        │         Progress Color: Theme Primary
        │         Thickness: 3px
        │         Border Radius: 8px
        ├── Expanded // Form Content Area
        │   Key Properties: Flex = 1
        │   └── SingleChildScrollView
        │       └── Padding
        │           Key Properties: Padding = L:24 R:24 T:32 B:32
        │           └── Column
        │               Key Properties: Cross Axis Alignment = stretch
        │               
        │               // --- STEP 0: Identity ---
        │               // Conditional Visibility: currentStep == 0
        │               ├── CDTextInput (label: 'Creator / Business Name', hint: 'e.g., TechWithJoel')
        │               ├── SizedBox (Height = 16)
        │               ├── CDTextInput (label: 'Username / Handle', hint: '@yourusername')
        │               ├── SizedBox (Height = 16)
        │               ├── DropDown (Label: 'Niche', Options: ['Technology', 'Education', 'Food', 'Fashion', 'Business', 'Other'])
        │               ├── SizedBox (Height = 16)
        │               ├── DropDown (Label: 'Category', Options: ['B2B', 'B2C', 'Personal Brand'])
        │               
        │               // --- STEP 1: Audience & Tone ---
        │               // Conditional Visibility: currentStep == 1
        │               ├── CDTextInput (label: 'Target Audience', hint: 'e.g., College students...', maxLines: 2)
        │               ├── SizedBox (Height = 24)
        │               ├── Text: 'Choose your tone' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── Wrap (Spacing: 8, Run Spacing: 8)
        │               │   └── ChoiceChips (Options: Professional, Friendly, Bold, Minimal, Funny, Educational, Premium, Casual)
        │               │       Key Properties: Selected Color = Theme Primary, Unselected Color = Theme Accent3
        │               ├── SizedBox (Height = 24)
        │               ├── CDTextInput (label: 'Content Style', hint: 'Short-form educational...', maxLines: 2)
        │
        │               // --- STEP 2: Language ---
        │               // Conditional Visibility: currentStep == 2
        │               ├── Text: 'Primary language' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── ChoiceChips (Options: English, Malayalam, Hindi, Tamil, Telugu)
        │               ├── SizedBox (Height = 24)
        │               ├── Text: 'Secondary language' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── ChoiceChips (Options: None, English, Malayalam, Hindi, Tamil, Telugu)
        │               ├── SizedBox (Height = 24)
        │               ├── Text: 'Emoji usage' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── ChoiceChips (Options: None, Minimal, Moderate, Heavy)
        │
        │               // --- STEP 3: Brand ---
        │               // Conditional Visibility: currentStep == 3
        │               ├── CDTextInput (label: 'Brand Description', hint: 'What makes your brand unique?', maxLines: 4)
        │               ├── SizedBox (Height = 24)
        │               ├── Text: 'Preferred CTA style' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── ChoiceChips (Options: Direct, Subtle, Question, Urgency)
        │               ├── SizedBox (Height = 24)
        │               ├── Text: 'Brand colors' (Theme Label Large)
        │               ├── SizedBox (Height = 12)
        │               ├── Row // Color Presets
        │               │   └── [8 Container circles with specific hex colors, tap updates Page State primaryColor]
        │
        │               // --- STEP 4: Socials ---
        │               // Conditional Visibility: currentStep == 4
        │               ├── CDTextInput (label: 'Website (optional)', hint: 'https://yoursite.com')
        │               ├── SizedBox (Height = 16)
        │               ├── CDTextInput (label: 'Instagram handle (optional)', hint: '@yourinstagram')
        │               ├── SizedBox (Height = 16)
        │               ├── CDTextInput (label: 'YouTube handle (optional)', hint: '@youryoutube')
        │               ├── SizedBox (Height = 24)
        │               ├── Container // Logo Upload Area
        │               │   Key Properties: Border = Dashed Theme Alternate, Height = 120
        │               │   Action (On Tap): Upload Media (Firebase/Local) -> Set Page State logoUrl
        │               │   └── Column (center alignment): Icon(upload), Text('Tap to upload logo')
        ├── Padding // Bottom Button
        │   Key Properties: Padding = L:24 R:24 T:24 B:24
        │   └── CDPrimaryButton
        │       Parameters:
        │         label: If currentStep < 4 then 'Continue' else 'Complete Setup'
        │         isFullWidth: true
        │       Action (On Pressed):
        │         Conditional:
        │           If currentStep < 4:
        │             Update Page State: currentStep = currentStep + 1
        │           Else:
        │             1. Action: Create/Update CreatorProfile Document in Firestore or AppState based on all Widget States.
        │             2. Update App State: hasCompletedProfileSetup = true
        │             3. Navigate to HomePage (Replace Route)
```

### Action Flows & Navigation:
- Multi-step validation can be added on the `Continue` button to ensure required fields for the current step are filled before incrementing `currentStep`.
- Navigation at the end replaces the route stack to prevent going back to onboarding.

### Conditional Visibility:
- Form fields are conditionally rendered based on `currentStep == X`.
- Back button visible only if `currentStep > 0`.
- Skip button visible only if `currentStep == 4`.

### Animations & Transitions:
- Progress bar fills with implicit animation.
- Optional: Add simple Fade/Slide transitions to the Step containers when `currentStep` changes for a smoother wizard feel.

### Components Used:
- `CDTextInput`
- `CDPrimaryButton`

---

## 4. HomePage

**Page Name:** HomePage  
**Route:** `/home`  
**Description:** The primary dashboard for the user, showing quick actions, recent history, and a brand summary. Part of the main bottom navigation shell.

### Page State:
- `greeting` (String)

### On Page Load Actions:
1. **Custom Function:** `getGreetingByTime()` (Returns 'Good morning', 'Good afternoon', or 'Good evening' based on device time).
2. **Update Page State:** Set `greeting` to the result of the function.
3. **Backend Call (Optional):** Query recent `ContentProject` collection for the user.

### Widget Tree:
```text
Scaffold
  Key Properties: Background Color = Theme PrimaryBackground, Nav Bar = Hidden (handled by custom stack)
└── Stack
    ├── SafeArea
    │   └── SingleChildScrollView
    │       └── Column
    │           Key Properties: Cross Axis Alignment = stretch
    │           ├── Padding // Greeting Section
    │           │   Key Properties: Padding = L:24 R:24 T:16 B:8
    │           │   └── Column
    │           │       Key Properties: Cross Axis Alignment = start
    │           │       ├── Text: '${greeting}, ${AppState.creatorProfile.creatorName}'
    │           │       │   Key Properties: Style = Theme Display Small, Color = Theme PrimaryText
    │           │       ├── SizedBox (Height = 4)
    │           │       └── Text: 'What are you creating today?'
    │           │           Key Properties: Style = Theme Body Large, Color = Theme SecondaryText
    │           ├── SizedBox (Height = 28)
    │           ├── Padding // Quick Actions Grid
    │           │   Key Properties: Padding = L:24 R:24 T:0 B:0
    │           │   └── Column
    │           │       ├── CDSectionHeader (title: 'Quick Create')
    │           │       ├── SizedBox (Height = 16)
    │           │       └── GridView
    │           │           Key Properties: 
    │           │             Cross Axis Count = 2
    │           │             Cross Axis Spacing = 12
    │           │             Main Axis Spacing = 12
    │           │             Child Aspect Ratio = 1.1
    │           │             Shrink Wrap = True
    │           │             Physics = NeverScrollableScrollPhysics
    │           │           ├── CDQuickActionCard (icon: Icons.movie_filter, label: 'Instagram Reel', accentColor: #E4405F)
    │           │           ├── CDQuickActionCard (icon: Icons.grid_on, label: 'Instagram Post', accentColor: #E4405F)
    │           │           ├── CDQuickActionCard (icon: Icons.amp_stories, label: 'Instagram Story', accentColor: #E4405F)
    │           │           ├── CDQuickActionCard (icon: Icons.play_circle, label: 'YouTube', accentColor: #FF0000)
    │           │           ├── CDQuickActionCard (icon: Icons.work, label: 'LinkedIn', accentColor: #0A66C2)
    │           │           └── CDQuickActionCard (icon: Icons.campaign, label: 'Product Promo', accentColor: #00B894)
    │           │           // Action (On Tap) for all cards: Navigate to CreatePage, passing Parameter initialPlatform based on selection.
    │           ├── SizedBox (Height = 32)
    │           ├── Padding // Recent Creations
    │           │   Key Properties: Padding = L:24 R:24 T:0 B:0
    │           │   └── Column
    │           │       ├── CDSectionHeader (title: 'Recent', actionLabel: 'See all', onAction: Navigate to HistoryPage)
    │           │       ├── SizedBox (Height = 16)
    │           │       // Conditional Logic: Check if history list is empty
    │           │       ├── ConditionalBuilder
    │           │       │   ├── IF True (List Empty):
    │           │       │   │   └── CDEmptyState (title: 'No content yet', message: 'Your generated content will appear here', actionLabel: 'Create your first')
    │           │       │   ├── ELSE:
    │           │       │   │   └── ListView (ShrinkWrap: True, Physics: NeverScrollable)
    │           │       │   │       └── CDRecentContentCard // For each item in top 3 history
    │           ├── SizedBox (Height = 24)
    │           ├── Padding // Brand Card
    │           │   Key Properties: Padding = L:24 R:24 T:0 B:0
    │           │   └── Column
    │           │       ├── CDSectionHeader (title: 'Your Brand')
    │           │       ├── SizedBox (Height = 16)
    │           │       └── CDBrandMemoryCard
    │           │           Parameters:
    │           │             creatorName: AppState.creatorProfile.creatorName
    │           │             niche: AppState.creatorProfile.niche
    │           │             primaryColor: AppState.creatorProfile.primaryColor
    │           │           Action (On Tap): Navigate to Profile Details
    │           └── SizedBox (Height = 100) // Spacer for absolute positioned bottom nav
    ├── Align // Custom Bottom Nav Bar
    │   Key Properties: Alignment = bottomCenter
    │   └── CDBottomNavBar
    │       Parameters: selectedIndex = 0
    │       Action (onTabChanged): Handle routing (0->Home, 1->Create, 2->History, 3->Profile)
```

### Action Flows & Navigation:
- Tapping a `CDQuickActionCard` navigates to `CreatePage` and sets the `initialPlatform` parameter, skipping step 0 of the creation flow.
- Tapping 'See all' on recent creations navigates to the History tab.

### Conditional Visibility:
- Renders `CDEmptyState` if the recent content list is empty, otherwise renders the `ListView` of `CDRecentContentCard`.

### Animations & Transitions:
- Standard page transitions. `CDBottomNavBar` items should have micro-interactions (handled inside the component).

### Components Used:
- `CDSectionHeader`
- `CDQuickActionCard`
- `CDEmptyState`
- `CDRecentContentCard`
- `CDBrandMemoryCard`
- `CDBottomNavBar`

---

## 5. CreatePage

**Page Name:** CreatePage  
**Route:** `/create`  
**Description:** The core creation workflow. A multi-step process to define content parameters and trigger AI generation.

### Page Parameters:
- `initialPlatform` (String, Optional)

### Page State:
- `currentStep` (Integer, Default: 0)
- `selectedPlatform` (String, Default: `initialPlatform` if provided)
- `selectedContentType` (String)
- `ideaText` (String)
- `selectedLanguage` (String, Default: from AppState profile)
- `selectedTone` (String, Default: from AppState profile)
- `selectedAudience` (String, Default: from AppState profile)
- `selectedCTAStyle` (String, Default: from AppState profile)
- `selectedLength` (String, Default: 'Medium')
- `showOptionalControls` (Boolean, Default: false)

### On Page Load Actions:
- **Conditional Action:** If `initialPlatform` is Set and Not Empty:
  - Update Page State: `selectedPlatform` = `initialPlatform`
  - Update Page State: `currentStep` = 1 (Skip platform selection step)

### Widget Tree:
```text
Scaffold
  Key Properties: Background Color = Theme PrimaryBackground
└── Stack
    ├── SafeArea
    │   └── Column
    │       Key Properties: Cross Axis Alignment = stretch
    │       ├── Padding // Header
    │       │   Key Properties: Padding = L:24 R:24 T:16 B:8
    │       │   └── Row
    │       │       ├── IconButton (Icon: arrow_back)
    │       │       │   Action (On Tap): 
    │       │       │     If currentStep == 0: Navigate Back
    │       │       │     Else: Update Page State currentStep = currentStep - 1
    │       │       ├── Expanded
    │       │       │   └── Text: 
    │       │       │       Value: Conditional (0: 'What are you creating?', 1: 'What\'s your idea?', 2: 'Fine-tune')
    │       │       │       Style = Theme Headline Medium, Color = Theme PrimaryText
    │       │       └── Text: 'Step ${currentStep + 1} of 3'
    │       │           Key Properties: Style = Theme Body Small, Color = Theme SecondaryText
    │       ├── Expanded // Step Content Area
    │       │   Key Properties: Flex = 1
    │       │   └── SingleChildScrollView
    │       │       └── Padding
    │       │           Key Properties: Padding = L:24 R:24 T:24 B:24
    │       │           └── Column
    │       │               Key Properties: Cross Axis Alignment = start
    │       │
    │       │               // --- STEP 0: Choose Type ---
    │       │               // Conditional Visibility: currentStep == 0
    │       │               ├── CDPlatformSelector
    │       │               │   Parameters: platforms = ['Instagram', 'YouTube', 'LinkedIn']
    │       │               │   Action (On Select): Update Page State selectedPlatform
    │       │               ├── SizedBox (Height = 24)
    │       │               ├── GridView (2 columns, Spacing: 16)
    │       │               │   // Content changes based on selectedPlatform
    │       │               │   // Example for Instagram:
    │       │               │   ├── CDContentTypeCard (icon: Icons.movie_filter, label: 'Reel', desc: 'Short-form video')
    │       │               │   ├── CDContentTypeCard (icon: Icons.grid_on, label: 'Post', desc: 'Feed post')
    │       │               │   ├── CDContentTypeCard (icon: Icons.amp_stories, label: 'Story', desc: '24-hour content')
    │       │               │   └── CDContentTypeCard (icon: Icons.view_carousel, label: 'Carousel', desc: 'Multi-slide')
    │       │               │   // Action (On Tap): Set selectedContentType
    │       │               
    │       │               // --- STEP 1: Describe Idea ---
    │       │               // Conditional Visibility: currentStep == 1
    │       │               ├── Container // Badge
    │       │               │   Key Properties: Background = Theme Accent2, Border Radius = 20, Padding = h:12 v:6
    │       │               │   └── Text: '${selectedPlatform} ${selectedContentType}' (Theme Label Medium, Color Theme Primary)
    │       │               ├── SizedBox (Height = 24)
    │       │               ├── Text: 'What\'s your content about?' (Theme Headline Small, PrimaryText)
    │       │               ├── SizedBox (Height = 8)
    │       │               ├── Text: 'Just describe the idea. CreateDiff handles the rest.' (Theme Body Medium, SecondaryText)
    │       │               ├── SizedBox (Height = 20)
    │       │               ├── CDTextInput
    │       │               │   Parameters: hint = 'e.g., 5 AI tools every student should know...', maxLines = 4
    │       │               │   Action (On Change): Update Page State ideaText
    │       │               ├── SizedBox (Height = 24)
    │       │               ├── InkWell // Optional Controls Toggle
    │       │               │   Action (On Tap): Toggle Page State showOptionalControls
    │       │               │   └── Row
    │       │               │       ├── Text: 'Fine-tune your content' (Theme Label Large, SecondaryText)
    │       │               │       └── Icon: Conditional (showOptionalControls ? expand_less : expand_more)
    │       │               ├── AnimatedSize // Optional Settings
    │       │               │   Key Properties: Duration = 300ms, Curve = easeInOut
    │       │               │   // Conditional Visibility: showOptionalControls == true
    │       │               │   └── Column
    │       │               │       ├── SizedBox (Height = 16)
    │       │               │       ├── Text: 'Language' (Theme Label Large)
    │       │               │       ├── ChoiceChips (Value = selectedLanguage, Options from profile)
    │       │               │       ├── SizedBox (Height = 16)
    │       │               │       ├── Text: 'Tone' (Theme Label Large)
    │       │               │       ├── ChoiceChips (Value = selectedTone, Options from profile)
    │       │               │       ├── SizedBox (Height = 16)
    │       │               │       ├── Text: 'Length' (Theme Label Large)
    │       │               │       └── ChoiceChips (Value = selectedLength, Options: ['Short', 'Medium', 'Long'])
    │       │               
    │       ├── Padding // Bottom Action Button
    │       │   Key Properties: Padding = L:24 R:24 T:0 B:24
    │       │   └── ConditionalBuilder // Which button to show based on step
    │       │       ├── IF currentStep == 0:
    │       │       │   └── CDPrimaryButton (label: 'Continue', isFullWidth: true)
    │       │       │       // Disable Logic: selectedContentType == null
    │       │       │       Action (On Pressed): Update Page State currentStep = 1
    │       │       ├── ELSE IF currentStep == 1:
    │       │       │   └── CDPrimaryButton (label: 'Create Content ✦', isFullWidth: true)
    │       │       │       // Disable Logic: ideaText is Empty
    │       │       │       Action (On Pressed):
    │       │       │         1. Update App State: isGenerating = true
    │       │       │         2. Backend Call: Custom Action `generateContentPack(parameters...)`
    │       │       │         3. Wait/Listen for Success
    │       │       │         4. Update App State: isGenerating = false
    │       │       │         5. Navigate to ContentResultPage (passing generated ID)
    │       └── SizedBox (Height = bottom safe area)
    │
    ├── // Generating Overlay Layer
    │   // Conditional Visibility: AppState.isGenerating == true
    │   Container
    │   Key Properties: Background Color = Theme PrimaryBackground (with Opacity 0.95), Width = infinity, Height = infinity
    │   └── CDLoadingState
    │       Parameters:
    │         messages: [
    │           'Understanding your idea...',
    │           'Applying your brand style...',
    │           'Optimizing for ${selectedPlatform}...',
    │           'Writing your content pack...',
    │           'Almost there...'
    │         ]
```

### Action Flows & Navigation:
- **Generation Flow:** When 'Create Content ✦' is tapped, a global app state flag `isGenerating` is turned on, showing a full-screen `CDLoadingState` overlay. The actual API call happens in an Action Flow, and upon success, routes to the `ContentResultPage`.

### Conditional Visibility:
- Step content switches based on `currentStep`.
- Optional tuning settings hidden behind `AnimatedSize` toggled by `showOptionalControls`.
- Loading overlay shown based on `AppState.isGenerating`.

### Animations & Transitions:
- `AnimatedSize` creates a smooth accordion effect for opening the fine-tuning options.
- The `CDLoadingState` component likely handles its own text cross-fades and spinner animations.

### Components Used:
- `CDPlatformSelector`
- `CDContentTypeCard`
- `CDTextInput`
- `CDPrimaryButton`
- `CDLoadingState`
