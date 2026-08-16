import 'package:flutter/material.dart';

// =============================================================================
// CreateDiff Design Tokens V2 — Atmospheric Glassmorphism
// =============================================================================
// Single source of truth for the CreateDiff visual design system.
// Inspired by icy blue, cool lavender, soft white, deep charcoal, and
// translucent frosted glass materials with subtle ambient lighting.
// =============================================================================

// ---------------------------------------------------------------------------
// COLORS
// ---------------------------------------------------------------------------

class CDColors {
  CDColors._();

  // --- Brand & Atmospheric Core Palette ---
  static const Color primary = Color(0xFF7C6CF2); // Vibrant Studio Violet
  static const Color primaryLight = Color(0xFFA99CFF); // Cool Lavender
  static const Color primarySubtle = Color(0xFF5D4FE6); // Deep Electric Violet
  static const Color icyBlue = Color(0xFFC9D6FF); // Icy Blue Ambient Highlight
  static const Color lavender = Color(0xFFB8AAFF); // Soft Lavender Tint
  static const Color softWhite = Color(0xFFF4F6FA); // High-contrast White
  static const Color mutedBlueGray = Color(0xFF8E96A8); // Refined Muted Gray

  // --- Dark Mode Atmospheric Palette ---
  static const Color darkBackground = Color(0xFF090B10); // Deep charcoal-obsidian
  static const Color darkSurface = Color(0xFF0E1118); // Sub-surface
  static const Color darkElevated = Color(0xFF141824); // Elevated glass container
  static const Color darkText = Color(0xFFF5F7FA); // Primary high-contrast text
  static const Color darkSecondary = Color(0xFF9AA0B0); // Secondary cool gray
  static const Color darkMuted = Color(0xFF636B7E); // Tertiary / metadata text
  static const Color darkBorder = Color(0x1FFFFFFF); // ~12% white border
  static const Color darkBorderSubtle = Color(0x0FFFFFFF); // ~6% white subtle border
  static const Color darkGlass = Color(0x12FFFFFF); // ~7% white glass fill
  static const Color darkGlassElevated = Color(0x1CFFFFFF); // ~11% white glass fill

  // --- Light Mode Frosted Daylight Palette ---
  static const Color lightBackground = Color(0xFFF0F3F9); // Pale icy blue-gray
  static const Color lightSurface = Color(0xFFFFFFFF); // Clean white surface
  static const Color lightSoftSurface = Color(0xFFE2E7F2); // Soft icy secondary container
  static const Color lightElevated = Color(0xFFFFFFFF); // Elevated card
  static const Color lightText = Color(0xFF0E1118); // Deep charcoal text
  static const Color lightSecondary = Color(0xFF5C6475); // Secondary slate
  static const Color lightMuted = Color(0xFF8E96A8); // Muted metadata
  static const Color lightBorder = Color(0x180E1118); // ~9% charcoal border
  static const Color lightBorderSubtle = Color(0x0D0E1118); // ~5% charcoal border
  static const Color lightGlass = Color(0xD9FFFFFF); // ~85% white frosted fill
  static const Color lightGlassElevated = Color(0xF2FFFFFF); // ~95% white frosted fill

  // --- Semantic ---
  static const Color success = Color(0xFF00B894); // Studio Mint
  static const Color warning = Color(0xFFFDCB6E); // Warm Amber
  static const Color error = Color(0xFFE17055); // Coral Error
  static const Color info = Color(0xFF74B9FF); // Sky Blue

  // --- Platform Accents (Refined & Restrained) ---
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B7DFF), Color(0xFF6C5CE7)],
  );

  static const LinearGradient icyAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9D6FF), Color(0xFFA99CFF)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x18FFFFFF),
      Color(0x06FFFFFF),
    ],
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xF5FFFFFF),
      Color(0xDDFFFFFF),
    ],
  );

  // --- Ambient Background Gradient Colors ---
  static const Color ambientIcyDark = Color(0x16C9D6FF); // 9% icy blue glow
  static const Color ambientLavenderDark = Color(0x147C6CF2); // 8% violet glow
  static const Color ambientIcyLight = Color(0x40C9D6FF); // 25% icy blue in light
  static const Color ambientLavenderLight = Color(0x28A99CFF); // 16% lavender in light

  // --- Context Helpers ---
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkElevated
          : lightSoftSurface;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : lightBackground;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkText
          : lightText;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSecondary
          : lightSecondary;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkMuted
          : lightMuted;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;

  static Color borderSubtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorderSubtle
          : lightBorderSubtle;

  static Color glass(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkGlass
          : lightGlass;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

// ---------------------------------------------------------------------------
// SPACING (4/8-based scale)
// ---------------------------------------------------------------------------

class CDSpacing {
  CDSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double xxxxl = 48.0;
  static const double huge = 64.0;

  /// Standard horizontal page margin for mobile screens.
  static const double pagePadding = 20.0;

  /// Bottom padding to clear the floating navigation bar (prevents any overlap).
  static const double navBarClearance = 112.0;
}

// ---------------------------------------------------------------------------
// CORNER RADII
// ---------------------------------------------------------------------------

class CDRadius {
  CDRadius._();

  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 22.0;
  static const double xlarge = 28.0;
  static const double pill = 999.0;

  static BorderRadius get rSmall => BorderRadius.circular(small);
  static BorderRadius get rMedium => BorderRadius.circular(medium);
  static BorderRadius get rLarge => BorderRadius.circular(large);
  static BorderRadius get rXLarge => BorderRadius.circular(xlarge);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}

// ---------------------------------------------------------------------------
// MOTION
// ---------------------------------------------------------------------------

class CDMotion {
  CDMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration screen = Duration(milliseconds: 320);
  static const Duration emphasis = Duration(milliseconds: 450);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutQuart;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve emphasize = Curves.easeInOutCubic;
  static const Curve snap = Curves.fastOutSlowIn;
}

// ---------------------------------------------------------------------------
// GLASS MATERIAL PARAMETERS
// ---------------------------------------------------------------------------

class CDGlass {
  CDGlass._();

  static const double blurSigma = 14.0;
  static const double heavyBlurSigma = 24.0;
  static const double borderWidth = 1.0;
  static const double shadowBlur = 16.0;
  static const Offset shadowOffset = Offset(0, 6);
  static const double shadowOpacity = 0.22; // for dark mode
  static const double lightShadowOpacity = 0.06; // for light mode

  // Specular top highlight opacity
  static const double specularOpacityDark = 0.18;
  static const double specularOpacityLight = 0.60;
}

// ---------------------------------------------------------------------------
// BUTTON & TOUCH TARGETS
// ---------------------------------------------------------------------------

class CDButton {
  CDButton._();

  static const double minHeight = 48.0;
  static const double standardHeight = 52.0;
  static const double largeHeight = 56.0;
  static const double minTouchTarget = 44.0;
  static const double pressScale = 0.97;
}

// ---------------------------------------------------------------------------
// CONTENT LIMITS
// ---------------------------------------------------------------------------

class CDLimits {
  CDLimits._();

  static const int maxHistoryItems = 50;
}
