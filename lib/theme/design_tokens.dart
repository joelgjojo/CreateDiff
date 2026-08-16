import 'package:flutter/material.dart';

// =============================================================================
// CreateDiff Design Tokens
// =============================================================================
// Single source of truth for the CreateDiff visual language.
// All spacing, radius, motion, glass, and color values live here.
// Screen/component code must reference these tokens — never hardcode values.
// =============================================================================

// ---------------------------------------------------------------------------
// COLORS
// ---------------------------------------------------------------------------

class CDColors {
  CDColors._();

  // --- Brand Accent ---
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA99CFF); // Soft Lavender
  static const Color primarySubtle = Color(0xFF5A4BD1); // Deeper variant

  // --- Dark Mode Palette ---
  static const Color darkBackground = Color(0xFF0B0C10);
  static const Color darkSurface = Color(0xFF12141A);
  static const Color darkElevated = Color(0xFF181B23);
  static const Color darkText = Color(0xFFF5F7FA);
  static const Color darkSecondary = Color(0xFFA8ADB8);
  static const Color darkMuted = Color(0xFF747A86);
  static const Color darkBorder = Color(0x14FFFFFF); // ~8% white
  static const Color darkBorderSubtle = Color(0x0AFFFFFF); // ~4% white
  static const Color darkGlass = Color(0x14FFFFFF); // ~8% white fill

  // --- Light Mode Palette ---
  static const Color lightBackground = Color(0xFFF3F5F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSoftSurface = Color(0xFFE9EDF3);
  static const Color lightText = Color(0xFF111318);
  static const Color lightSecondary = Color(0xFF626875);
  static const Color lightMuted = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0x14111318); // ~8% dark
  static const Color lightBorderSubtle = Color(0x0A111318); // ~4% dark
  static const Color lightGlass = Color(0x0A111318); // ~4% dark fill

  // --- Semantic ---
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // --- Platform Accents (for tiny indicators only) ---
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);

  // --- Helpers ---
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
// SPACING  (4/8-based scale)
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

  /// Bottom padding to clear the floating navigation bar.
  static const double navBarClearance = 100.0;
}

// ---------------------------------------------------------------------------
// CORNER RADII
// ---------------------------------------------------------------------------

class CDRadius {
  CDRadius._();

  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 20.0;
  static const double floating = 28.0;
  static const double pill = 999.0;

  static BorderRadius get rSmall => BorderRadius.circular(small);
  static BorderRadius get rMedium => BorderRadius.circular(medium);
  static BorderRadius get rLarge => BorderRadius.circular(large);
  static BorderRadius get rFloating => BorderRadius.circular(floating);
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
  static const Duration screen = Duration(milliseconds: 300);
  static const Duration emphasis = Duration(milliseconds: 400);

  // Curves
  static const Curve defaultCurve = Curves.easeOut;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve emphasize = Curves.easeInOut;
  static const Curve snap = Curves.fastOutSlowIn;
}

// ---------------------------------------------------------------------------
// GLASS MATERIAL PARAMETERS
// ---------------------------------------------------------------------------

class CDGlass {
  CDGlass._();

  static const double blurSigma = 12.0;
  static const double borderWidth = 1.0;
  static const double shadowBlur = 8.0;
  static const Offset shadowOffset = Offset(0, 2);
  static const double shadowOpacity = 0.08; // for dark mode
  static const double lightShadowOpacity = 0.04;
}

// ---------------------------------------------------------------------------
// BUTTON & TOUCH TARGETS
// ---------------------------------------------------------------------------

class CDButton {
  CDButton._();

  static const double minHeight = 48.0;
  static const double standardHeight = 52.0;
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
