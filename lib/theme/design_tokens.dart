import 'package:flutter/material.dart';

/// Centralized semantic design tokens for CreateDiff.
///
/// Visual Direction: "Snowfall Hush / premium frosted glass / soft ice-blue editorial UI"
/// Primary light accent: #C9D6FF (Ice Blue)
/// Secondary soft neutral: #E2E2E2
class CDColors {
  CDColors._();

  // ==========================================
  // 1. BRAND ACCENT PALETTE (Ice Blue System)
  // ==========================================
  static const Color accent = Color(0xFFC9D6FF); // Primary Ice Blue Accent
  static const Color primary = Color(0xFFC9D6FF); // Canonical Primary Accent
  static const Color icyBlue = Color(0xFFC9D6FF); // Alias for Ice Blue
  static const Color accentBright = Color(0xFFDCE5FF); // Bright Luminous Ice Blue
  static const Color primaryLight = Color(0xFFDCE5FF);
  static const Color accentSubdued = Color(0x29C9D6FF); // 16% Ice Blue Tint
  static const Color primarySubtle = Color(0x29C9D6FF);
  static const Color accentGlow = Color(0x1AA0B9FF); // 10% Soft Blue Ambient Glow

  // Secondary Soft Neutral
  static const Color softNeutral = Color(0xFFE2E2E2);

  // Light Mode Accent (Refined restrained blue for high contrast on light surfaces)
  static const Color lightAccent = Color(0xFF4A69BD);
  static const Color lightAccentSubtle = Color(0x1F4A69BD);

  // ==========================================
  // 2. DARK MODE PALETTE (#080A0F Deep Charcoal)
  // ==========================================
  static const Color darkBackground = Color(0xFF080A0F); // Deep Charcoal / Blue-Black
  static const Color darkSecondaryBackground = Color(0xFF0D1017); // Secondary Background
  static const Color darkSurface = Color(0x0EFFFFFF); // 5.5% White Translucent Glass
  static const Color darkSurfaceElevated = Color(0x16FFFFFF); // 8.5% White Glass Elevated
  static const Color darkGlassHighlight = Color(0x1CFFFFFF); // 11% White Glass Highlight
  static const Color darkBorderSubtle = Color(0x1FFFFFFF); // 12% White Glass Border
  static const Color darkBorderHighlight = Color(0x33FFFFFF); // 20% White Glass Highlight Border

  static const Color darkTextPrimary = Color(0xFFF4F6FA); // Soft White
  static const Color darkTextSecondary = Color(0xFFB7BDCA); // Muted Silver Gray
  static const Color darkMuted = Color(0xFF7F8796); // Slate Gray

  // ==========================================
  // 3. LIGHT MODE PALETTE (#F1F4F8 Frosted Daylight)
  // ==========================================
  static const Color lightBackground = Color(0xFFF1F4F8); // Frosted Daylight Gray
  static const Color lightSecondaryBackground = Color(0xFFE8EDF5);
  static const Color lightSurface = Color(0xB3FFFFFF); // 70% White Translucent Glass
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // Solid White Elevated
  static const Color lightGlassHighlight = Color(0xE6FFFFFF); // 90% White Glass Highlight
  static const Color lightBorderSubtle = Color(0x14000000); // 8% Black Border
  static const Color lightBorderHighlight = Color(0x26000000); // 15% Black Border

  static const Color lightTextPrimary = Color(0xFF111318); // Deep Slate
  static const Color lightTextSecondary = Color(0xFF5E6675); // Neutral Gray
  static const Color lightMuted = Color(0xFF8E96A8); // Light Slate Gray

  // ==========================================
  // 4. FUNCTIONAL / FEEDBACK PALETTE
  // ==========================================
  static const Color success = Color(0xFF00B894); // Mint Green
  static const Color error = Color(0xFFFF5252); // Coral Red
  static const Color warning = Color(0xFFFFB142); // Warm Amber
  static const Color info = Color(0xFFA0B9FF); // Soft Ambient Blue

  // Platform Subtle Identifiers
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);

  // ==========================================
  // 5. GRADIENTS (Ice-Blue Light Transmission)
  // ==========================================
  static const LinearGradient studioGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9D6FF), Color(0xFFAFC4FF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD9DFFF), Color(0xFFB9C8FF)],
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF), // 8% White top
      Color(0x05FFFFFF), // 2% White bottom
    ],
  );

  static const LinearGradient lightGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEEFFFFFF), // 93% White
      Color(0xC0FFFFFF), // 75% White
    ],
  );

  static const LinearGradient specularHighlightDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x38FFFFFF), // 22% White rim highlight
      Color(0x00FFFFFF), // Fades out
    ],
  );

  static const LinearGradient specularHighlightLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x80FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  // ==========================================
  // 6. SEMANTIC ACCESSORS (Theme-Aware)
  // ==========================================
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color secondaryBackground(BuildContext context) =>
      isDark(context) ? darkSecondaryBackground : lightSecondaryBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color elevated(BuildContext context) =>
      isDark(context) ? darkSurfaceElevated : lightSurfaceElevated;

  static Color glassHighlight(BuildContext context) =>
      isDark(context) ? darkGlassHighlight : lightGlassHighlight;

  static Color borderSubtle(BuildContext context) =>
      isDark(context) ? darkBorderSubtle : lightBorderSubtle;

  static Color borderHighlight(BuildContext context) =>
      isDark(context) ? darkBorderHighlight : lightBorderHighlight;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      isDark(context) ? darkMuted : lightMuted;

  static Color primaryColor(BuildContext context) =>
      isDark(context) ? accent : lightAccent;

  static Color primarySubtleColor(BuildContext context) =>
      isDark(context) ? accentSubdued : lightAccentSubtle;
}

/// Spacing tokens (4pt baseline grid)
class CDSpacing {
  CDSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  /// Guaranteed bottom clearance so floating navigation never obscures content
  static const double navBarClearance = 112.0;
}

/// Button tokens
class CDButton {
  CDButton._();

  static const double standardHeight = 48.0;
  static const double compactHeight = 40.0;
  static const double heroHeight = 52.0;
}

/// Content and memory bounds
class CDLimits {
  CDLimits._();

  static const int maxHistoryItems = 100;
  static const int maxIdeaLength = 500;
}

/// Corner radius tokens
class CDRadius {
  CDRadius._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 18.0;
  static const double xlarge = 24.0;
  static const double pill = 999.0;

  static final BorderRadius rSmall = BorderRadius.circular(small);
  static final BorderRadius rMedium = BorderRadius.circular(medium);
  static final BorderRadius rLarge = BorderRadius.circular(large);
  static final BorderRadius rXLarge = BorderRadius.circular(xlarge);
  static final BorderRadius rPill = BorderRadius.circular(pill);
}

/// Animation & Motion tokens
class CDMotion {
  CDMotion._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasis = Duration(milliseconds: 320);
  static const Duration screen = Duration(milliseconds: 280);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve pressCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.easeOutBack;
}

/// Frosted glass blur & opacity constants
class CDGlass {
  CDGlass._();

  static const double blurSigma = 14.0;
  static const double heavyBlurSigma = 24.0;
  static const double lightBlurSigma = 8.0;

  static const double darkSurfaceOpacity = 0.055;
  static const double darkElevatedOpacity = 0.085;
  static const double darkBorderOpacity = 0.12;

  static const double lightSurfaceOpacity = 0.70;
  static const double lightBorderOpacity = 0.08;
}
