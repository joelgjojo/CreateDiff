import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

// Re-export design tokens so screens can import from a single file.
export 'design_tokens.dart';

// =============================================================================
// CreateDiff App Theme V2 — Atmospheric Glassmorphism
// =============================================================================
// Builds Material 3 ThemeData for light and dark modes using the centralized
// design tokens defined in design_tokens.dart.
//
// Typography uses Inter with refined editorial scale.
// Colors reference CDColors (Icy Blue, Cool Lavender, Studio Violet, Deep Charcoal).
// =============================================================================

class AppHaptics {
  AppHaptics._();
  static void light() => HapticFeedback.lightImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void medium() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
}

class AppTheme {
  AppTheme._();

  // -------------------------------------------------------------------------
  // LIGHT THEME (Frosted Daylight)
  // -------------------------------------------------------------------------

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: CDColors.primary,
      scaffoldBackgroundColor: CDColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: CDColors.primary,
        secondary: CDColors.primaryLight,
        tertiary: CDColors.icyBlue,
        surface: CDColors.lightSurface,
        surfaceContainerHighest: CDColors.lightSoftSurface,
        error: CDColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CDColors.lightText,
        onError: Colors.white,
        outline: CDColors.lightBorder,
        outlineVariant: CDColors.lightBorderSubtle,
      ),
      textTheme: _buildTextTheme(CDColors.lightText, CDColors.lightSecondary),
      dividerTheme: const DividerThemeData(
        color: CDColors.lightBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: CDColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: CDColors.lightText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CDColors.lightText,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: CDColors.lightSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: CDRadius.rMedium,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DARK THEME (Atmospheric Obsidian & Icy Glow)
  // -------------------------------------------------------------------------

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: CDColors.primary,
      scaffoldBackgroundColor: CDColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: CDColors.primary,
        secondary: CDColors.primaryLight,
        tertiary: CDColors.icyBlue,
        surface: CDColors.darkSurface,
        surfaceContainerHighest: CDColors.darkElevated,
        error: CDColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CDColors.darkText,
        onError: Colors.white,
        outline: CDColors.darkBorder,
        outlineVariant: CDColors.darkBorderSubtle,
      ),
      textTheme: _buildTextTheme(CDColors.darkText, CDColors.darkSecondary),
      dividerTheme: const DividerThemeData(
        color: CDColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: CDColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: CDColors.darkText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CDColors.darkElevated,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: CDColors.darkText,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: CDRadius.rMedium,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // TYPOGRAPHY (Inter) — Editorial & Modern Scale
  // -------------------------------------------------------------------------

  static TextTheme _buildTextTheme(
      Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // 36px — Hero headings with strong tracking
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.15,
        color: primaryTextColor,
      ),
      // 28px — Screen titles
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.2,
        color: primaryTextColor,
      ),
      // 22px — Section titles
      displaySmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
        color: primaryTextColor,
      ),
      // 20px — Prominent Card titles
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: primaryTextColor,
      ),
      // 18px — Standard Card titles
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
        color: primaryTextColor,
      ),
      // 16px — Prominent subheadings
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 16px — Regular title
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 14px — Subtitle / Section headers
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 13px — Small title
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 16px — Body Large
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.55,
        color: primaryTextColor,
      ),
      // 14px — Body Regular
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: secondaryTextColor,
      ),
      // 12px — Caption / metadata
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.45,
        color: secondaryTextColor,
      ),
      // 15px — CTA Button labels
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.35,
        color: primaryTextColor,
      ),
      // 12px — Secondary buttons / Small labels
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.3,
        color: secondaryTextColor,
      ),
      // 11px — Tiny metadata / badges
      labelSmall: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        height: 1.25,
        color: secondaryTextColor,
      ),
    );
  }
}
