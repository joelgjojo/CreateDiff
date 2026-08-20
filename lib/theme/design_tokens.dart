import 'package:flutter/material.dart';

/// Centralized semantic design tokens for CreateDiff.
///
/// Official Brand Identity:
/// - Primary Blue-Violet Accent: #4F43F9
/// - Soft Lavender Highlight: #E0E3FF / #7066FF
/// - Cool Blue-Violet Atmospheric Glow: rgba(79, 67, 249, 0.12)
/// - Neutral Graphite Dark Surfaces: #080A0F / #0D1017
/// - Cool Off-White Light Surfaces: #F4F6FB / #FFFFFF
class CDColors {
  CDColors._();

  // ==========================================
  // 1. OFFICIAL BRAND ACCENT SYSTEM (#4F43F9)
  // ==========================================
  static const Color brand = Color(0xFF4F43F9); // Official Electric Blue-Violet
  static const Color brandHighlight = Color(0xFF7066FF); // Bright Luminous Highlight
  static const Color primary = Color(0xFF4F43F9); // Canonical Primary Accent
  static const Color accent = Color(0xFF4F43F9);
  static const Color primaryLight = Color(0xFF7066FF); // Bright Luminous Blue-Violet
  static const Color accentBright = Color(0xFF7066FF);
  static const Color lavender = Color(0xFFE0E3FF); // Soft Lavender Highlight
  static const Color primarySubtle = Color(0x244F43F9); // 14% Blue-Violet Tint
  static const Color accentSubdued = Color(0x244F43F9);
  static const Color accentGlow = Color(0x1F4F43F9); // 12% Soft Ambient Glow

  // Secondary Soft Neutral
  static const Color softNeutral = Color(0xFFE4E7EC);

  // Light Mode Restrained Accent
  static const Color lightAccent = Color(0xFF4338CA);
  static const Color lightAccentSubtle = Color(0x1A4F43F9);

  // ==========================================
  // 2. DARK MODE PALETTE (#080A0F Graphite Deep)
  // ==========================================
  static const Color darkBackground = Color(0xFF080A0F); // Deep Graphite Base
  static const Color darkSecondaryBackground = Color(0xFF0D1017); // Secondary Base
  static const Color darkSurface = Color(0x0DFFFFFF); // 5% White Glass Surface
  static const Color darkSurfaceElevated = Color(0x14FFFFFF); // 8% White Glass Surface
  static const Color darkGlassHighlight = Color(0x1FFFFFFF); // 12% White Highlight
  static const Color darkBorderSubtle = Color(0x1FFFFFFF); // 12% White Border
  static const Color darkBorderHighlight = Color(0x33FFFFFF); // 20% White Border

  static const Color darkTextPrimary = Color(0xFFF8F9FC); // Pure Crisp White
  static const Color darkTextSecondary = Color(0xFFB0B7C3); // Silver Slate
  static const Color darkMuted = Color(0xFF717886); // Muted Graphite

  // ==========================================
  // 3. LIGHT MODE PALETTE (#F4F6FB Crisp Studio)
  // ==========================================
  static const Color lightBackground = Color(0xFFF4F6FB); // Cool Off-White
  static const Color lightSecondaryBackground = Color(0xFFEAEEF6);
  static const Color lightSurface = Color(0xBFFFFFFF); // 75% White Translucent Glass
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // Pure White
  static const Color lightGlassHighlight = Color(0xF2FFFFFF);
  static const Color lightBorderSubtle = Color(0x144F43F9); // 8% Blue-Violet Border
  static const Color lightBorderHighlight = Color(0x294F43F9);

  static const Color lightTextPrimary = Color(0xFF0F1117); // Deep Graphite Slate
  static const Color lightTextSecondary = Color(0xFF555E6D); // Neutral Slate
  static const Color lightMuted = Color(0xFF8892A2); // Light Slate

  // ==========================================
  // 4. FUNCTIONAL / FEEDBACK PALETTE
  // ==========================================
  static const Color success = Color(0xFF00B894); // Mint Green
  static const Color error = Color(0xFFFF4757); // Coral Red
  static const Color coralRed = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFA502); // Warm Amber
  static const Color info = Color(0xFF3742FA); // Electric Blue


  // Platform Subtle Identifiers
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);

  // ==========================================
  // 5. GRADIENTS (Electric Blue-Violet Light Transmission)
  // ==========================================
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C50FF), Color(0xFF4F43F9)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6358FF), Color(0xFF4A3EF5)],
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
      Color(0xF0FFFFFF), // 94% White
      Color(0xC8FFFFFF), // 78% White
    ],
  );

  static const LinearGradient atmosphericGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1017),
      Color(0xFF080A0F),
    ],
  );

  static const LinearGradient specularHighlightDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x38FFFFFF), // 22% White rim
      Color(0x00FFFFFF),
    ],
  );

  // ==========================================
  // 6. THEME-AWARE ACCESSORS
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

  static Color surfaceElevated(BuildContext context) => elevated(context);

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
      isDark(context) ? brand : lightAccent;

  static Color primarySubtleColor(BuildContext context) =>
      isDark(context) ? primarySubtle : lightAccentSubtle;
}

/// Spacing tokens (4pt baseline grid)
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
  static const double huge = 48.0;
  static const double massive = 64.0;

  static const double screenPadding = 20.0;
  static const double radiusCard = 16.0;

  /// Guaranteed bottom clearance so floating navigation never obscures content
  static const double navBarClearance = 112.0;
}

/// Standardized typography scale and font weights
class CDTypography {
  CDTypography._();

  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 22.0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}


/// Standardized corner radius tokens
class CDRadius {
  CDRadius._();

  static const double small = 12.0;
  static const double medium = 16.0;
  static const double large = 20.0;
  static const double xlarge = 28.0;
  static const double pill = 999.0;

  static final BorderRadius rSmall = BorderRadius.circular(small);
  static final BorderRadius rMedium = BorderRadius.circular(medium);
  static final BorderRadius rLarge = BorderRadius.circular(large);
  static final BorderRadius rXLarge = BorderRadius.circular(xlarge);
  static final BorderRadius rPill = BorderRadius.circular(pill);
}

/// Standardized button touch metrics
class CDButton {
  CDButton._();

  static const double standardHeight = 52.0; // 52px touch height
  static const double compactHeight = 44.0;
  static const double heroHeight = 56.0;
  static const double pressScale = 0.96; // 0.96 press scale feedback
}

/// Content and memory bounds
class CDLimits {
  CDLimits._();

  static const int maxHistoryItems = 100;
  static const int maxIdeaLength = 500;
}

/// Animation & Motion tokens
class CDMotion {
  CDMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration premium = Duration(milliseconds: 500);

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration screen = Duration(milliseconds: 300);
  static const Duration emphasis = Duration(milliseconds: 400);
  static const Duration splash = Duration(milliseconds: 800); // 800ms cinematic entrance

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve pressCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.easeOutBack;
}

/// Restrained glassmorphism blur & opacity constants
class CDGlass {
  CDGlass._();

  static const double blurSigma = 24.0; // 20-30px standard glass blur
  static const double heavyBlurSigma = 30.0;
  static const double lightBlurSigma = 14.0;

  static const double darkSurfaceOpacity = 0.05; // rgba(255,255,255,0.05)
  static const double darkElevatedOpacity = 0.08;
  static const double darkBorderOpacity = 0.12; // rgba(255,255,255,0.12)

  static const double lightSurfaceOpacity = 0.75; // rgba(255,255,255,0.75)
  static const double lightBorderOpacity = 0.08; // rgba(79,67,249,0.08)
}

/// Centralized strings & copy tokens across CreateDiff
class CDStrings {
  CDStrings._();

  /// Unified retry state loading message
  static const String retryLoadingMessage = 'Refining & elevating your content pack...';
}

