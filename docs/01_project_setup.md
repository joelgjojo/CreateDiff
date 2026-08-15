# CreateDiff - FlutterFlow Project Setup Guide

This document outlines the complete setup procedure for the **CreateDiff** FlutterFlow project. Follow these steps meticulously in the FlutterFlow visual editor to ensure the project foundation is solid.

---

## 1. Project Creation

1. Navigate to your FlutterFlow dashboard and click **+ Create New**.
2. Name the project: **`CreateDiff`**
3. Create a blank project or start from a template, then proceed to the project settings.
4. Go to **Settings & Integrations > General > App Details**.
   *   **Project Name:** `CreateDiff`
   *   **Package Name:** `com.vyqodsgn.creatediff`
5. Go to **Settings & Integrations > Platforms**.
   *   Target Platforms: Enable **Android (Primary)**, **iOS (Secondary)**, and **Web** (if desired, but focus on mobile).
6. Go to **Theme Settings > Colors**.
   *   Ensure **Material 3** toggle is **ON** (Enabled).

---

## 2. Theme Configuration

Navigate to **Theme Settings > Colors** to configure the global color palette for Light and Dark modes.

### Colors (Light Mode)

Enter these EXACT hex values in the corresponding color slots.

*   **Primary:** `#6C5CE7` *(Refined violet — the CreateDiff accent)*
*   **Secondary:** `#A29BFE` *(Lighter violet for secondary actions)*
*   **Tertiary:** `#2D2D3A` *(Dark tone for cards/badges)*
*   **Alternate:** `#F0F0F5` *(Subtle alternate background)*
*   **PrimaryText:** `#1A1A1E` *(Near-black)*
*   **SecondaryText:** `#6B7280` *(Medium gray)*
*   **PrimaryBackground:** `#FAFAFA` *(Warm white)*
*   **SecondaryBackground:** `#FFFFFF` *(Pure white for cards)*
*   **Accent1:** `rgba(108, 92, 231, 0.15)` *(Violet tint)*
*   **Accent2:** `rgba(108, 92, 231, 0.08)` *(Very subtle violet)*
*   **Accent3:** `rgba(26, 26, 30, 0.05)` *(Subtle dark tint)*
*   **Accent4:** `rgba(255, 255, 255, 0.90)` *(Glass surface)*
*   **Success:** `#00B894`
*   **Warning:** `#FDCB6E`
*   **Error:** `#E17055`
*   **Info:** `#74B9FF`

### Colors (Dark Mode)

Switch the theme editor to Dark Mode and enter this intentional dark palette.

*   **Primary:** `#7C6CF0` *(Slightly brighter violet for dark bg)*
*   **Secondary:** `#B0A8FF`
*   **Tertiary:** `#3D3D4E`
*   **Alternate:** `#2A2A35`
*   **PrimaryText:** `#F5F5F7` *(Soft white)*
*   **SecondaryText:** `#9CA3AF` *(Muted gray)*
*   **PrimaryBackground:** `#121218` *(Deep graphite)*
*   **SecondaryBackground:** `#1C1C24` *(Slightly lighter surface)*
*   **Accent1:** `rgba(124, 108, 240, 0.20)`
*   **Accent2:** `rgba(124, 108, 240, 0.10)`
*   **Accent3:** `rgba(245, 245, 247, 0.06)`
*   **Accent4:** `rgba(28, 28, 36, 0.85)`
*   **Success:** `#00D2A0`
*   **Warning:** `#FFD93D`
*   **Error:** `#FF6B6B`
*   **Info:** `#6CB4EE`

### Custom Colors

Scroll down in the Colors panel and click **+ Add Custom Color**. Add the following exactly as named:

| Name | Light Mode | Dark Mode |
| :--- | :--- | :--- |
| **glassBackground** | `rgba(255, 255, 255, 0.72)` | `rgba(28, 28, 36, 0.65)` |
| **glassBorder** | `rgba(255, 255, 255, 0.18)` | `rgba(255, 255, 255, 0.08)` |
| **surfaceElevated** | `rgba(255, 255, 255, 0.95)` | `rgba(40, 40, 52, 0.90)` |
| **cardSurface** | `#FFFFFF` | `#1E1E28` |
| **divider** | `rgba(0, 0, 0, 0.06)` | `rgba(255, 255, 255, 0.06)` |
| **shimmer** | `rgba(108, 92, 231, 0.04)` | `rgba(124, 108, 240, 0.06)` |

---

## 3. Typography Configuration

Navigate to **Theme Settings > Typography**.
Set the primary font family for all styles to **Inter** (search in Google Fonts).

Apply the following exact settings for each style variant. Ensure you set the Color to `PrimaryText` (or `SecondaryText` where appropriate) and allow FlutterFlow to automatically handle the Light/Dark mode swap based on the colors defined above.

| Style Name | Font | Size (px) | Weight | Letter Spacing | Line Height | Suggested Color |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Large** | Inter | 32 | 700 (Bold) | -0.5 | 1.2 | Primary Text |
| **Display Medium** | Inter | 28 | 700 (Bold) | -0.3 | 1.25 | Primary Text |
| **Display Small** | Inter | 24 | 600 (SemiBold) | -0.2 | 1.3 | Primary Text |
| **Headline Large** | Inter | 22 | 600 (SemiBold) | -0.2 | 1.3 | Primary Text |
| **Headline Medium** | Inter | 20 | 600 (SemiBold) | 0 | 1.35 | Primary Text |
| **Headline Small** | Inter | 18 | 600 (SemiBold) | 0 | 1.35 | Primary Text |
| **Title Large** | Inter | 18 | 500 (Medium) | 0 | 1.4 | Primary Text |
| **Title Medium** | Inter | 16 | 500 (Medium) | 0.1 | 1.4 | Primary Text |
| **Title Small** | Inter | 14 | 500 (Medium) | 0.1 | 1.4 | Primary Text |
| **Body Large** | Inter | 16 | 400 (Regular) | 0.15 | 1.5 | Primary Text |
| **Body Medium** | Inter | 15 | 400 (Regular) | 0.15 | 1.5 | Secondary Text |
| **Body Small** | Inter | 13 | 400 (Regular) | 0.2 | 1.5 | Secondary Text |
| **Label Large** | Inter | 14 | 500 (Medium) | 0.1 | 1.4 | Secondary Text |
| **Label Medium** | Inter | 12 | 500 (Medium) | 0.3 | 1.3 | Secondary Text |
| **Label Small** | Inter | 11 | 500 (Medium) | 0.4 | 1.3 | Secondary Text |

---

## 4. Spacing & Border Radius Constants

When building layouts (padding, margins, gaps, border radii), strictly adhere to this scale. Do not use arbitrary numbers.

**Spacing Scale (Padding / Margin / Gap):**
*   `xs`: 4px
*   `sm`: 8px
*   `md`: 12px
*   `lg`: 16px
*   `xl`: 20px
*   `2xl`: 24px
*   `3xl`: 32px
*   `4xl`: 40px
*   `5xl`: 48px
*   `6xl`: 64px

**Border Radius Scale:**
*   `small`: 8px (Buttons, small inputs)
*   `medium`: 12px (Cards, dialogs)
*   `large`: 16px (Main containers, bottom sheets)
*   `xl`: 20px (Large structural elements)
*   `pill`: 100px (Capsule buttons, tags)

*(Tip: You can set up Design System Variables in FlutterFlow for these values to ensure exact consistency across the app.)*

---

## 5. App Settings

Navigate to **App Settings > Routing & Routing**.
*   **Routing:** Enable Web Routing (if applicable) and choose **Hash-based**.
*   **Default Transition:** Set to **Fade** with a duration of **300ms**.

Navigate to **App Settings > App Assets**.
*   **Splash Screen:** Upload a minimal logo centered on the `PrimaryBackground` color.
*   **Launcher Icon:** Upload a 1024x1024 flat app icon reflecting the brand. Ensure no transparency.

---

## 6. Custom Data Types

Navigate to **Data Types** in the left menu (the `{}` icon). Create the following data types EXACTLY as defined. Check "Is List" where indicated.

### 1. `CreatorProfile`
| Field Name | Data Type | Is List |
| :--- | :--- | :--- |
| `creatorName` | String | False |
| `username` | String | False |
| `niche` | String | False |
| `category` | String | False |
| `targetAudience` | String | False |
| `primaryLanguage` | String | False |
| `secondaryLanguage` | String | False |
| `tone` | String | False |
| `contentStyle` | String | False |
| `brandDescription` | String | False |
| `preferredCTAStyle` | String | False |
| `emojiUsage` | String | False *(Values: 'none', 'minimal', 'moderate', 'heavy')* |
| `primaryColor` | Color | False |
| `secondaryColor` | Color | False |
| `logoUrl` | Image Path / String | False |
| `websiteUrl` | String | False |
| `instagramHandle` | String | False |
| `youtubeHandle` | String | False |

### 2. `ContentProject`
| Field Name | Data Type | Is List |
| :--- | :--- | :--- |
| `id` | String | False |
| `platform` | String | False |
| `contentType` | String | False |
| `idea` | String | False |
| `createdAt` | DateTime | False |
| `status` | String | False |

### 3. `GeneratedContent`
| Field Name | Data Type | Is List |
| :--- | :--- | :--- |
| `hooks` | String | True |
| `caption` | String | False |
| `ctas` | String | True |
| `hashtagsHighReach` | String | True |
| `hashtagsMediumReach` | String | True |
| `hashtagsNiche` | String | True |
| `coverText` | String | False |
| `variations` | String | True |

### 4. `DesignTemplate`
| Field Name | Data Type | Is List |
| :--- | :--- | :--- |
| `id` | String | False |
| `name` | String | False |
| `style` | String | False *(Values: 'minimal', 'bold', 'premium')* |
| `previewUrl` | Image Path / String | False |
| `isSelected` | Boolean | False |

---

## 7. App State Variables

Navigate to **App State** in the left menu. Define the global variables that will drive the application logic.

### Persisted Variables (Check the 'Persisted' toggle)
These survive app restarts and are saved locally.

| Variable Name | Type | Is List | Default Value | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `currentCreatorProfile` | Data Type: CreatorProfile | False | *(Null)* | User's brand setup |
| `hasCompletedOnboarding` | Boolean | False | `false` | First-launch flag |
| `hasCompletedProfileSetup` | Boolean | False | `false` | Profile completion flag |
| `contentHistory` | Data Type: ContentProject | True | `[]` (Empty List) | Saved projects |
| `selectedThemeMode` | String | False | `'system'` | 'light', 'dark', 'system' |
| `defaultPlatform` | String | False | `'instagram'` | User preference |
| `defaultTone` | String | False | `'professional'`| User preference |

### Non-Persisted Variables (Leave 'Persisted' unchecked)
These clear when the app is restarted. Used for current session state.

| Variable Name | Type | Is List | Default Value | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `currentContentProject` | Data Type: ContentProject | False | *(Null)* | Active draft |
| `currentGeneratedContent` | Data Type: GeneratedContent | False | *(Null)* | AI response data |
| `isGenerating` | Boolean | False | `false` | UI loading flag |
| `generationStep` | String | False | *(Null)* | Tracks loading message step |
| `selectedNavIndex` | Integer | False | `0` | Bottom Nav state |

---
*End of Setup Guide.*
