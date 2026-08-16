import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

// Re-export design tokens so screens can import from a single file.
export 'design_tokens.dart';

// =============================================================================
// CreateDiff App Theme
// =============================================================================
// Builds Material 3 ThemeData for light and dark modes using the centralized
// design tokens defined in design_tokens.dart.
//
// Typography uses Inter via google_fonts.
// Colors reference CDColors (design_tokens.dart).
// Spacing, radii, motion, glass values are in design_tokens.dart.
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
  // LIGHT THEME
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
        backgroundColor: CDColors.lightBackground,
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
          fontWeight: FontWeight.w600,
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
  // DARK THEME
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
        backgroundColor: CDColors.darkBackground,
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
          fontWeight: FontWeight.w600,
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
  // TYPOGRAPHY (Inter)
  // -------------------------------------------------------------------------

  static TextTheme _buildTextTheme(
      Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      // 36px — Large hero headings
      displayLarge: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
        color: primaryTextColor,
      ),
      // 30px — Screen titles
      displayMedium: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.2,
        color: primaryTextColor,
      ),
      // 24px — Section titles
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.25,
        color: primaryTextColor,
      ),
      // 20px — Sub-sections
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: primaryTextColor,
      ),
      // 18px — Card titles
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: primaryTextColor,
      ),
      // 16px — Prominent body
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 16px — Regular title
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 14px — Subtitle
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 13px — Small title
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      // 16px — Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.55,
        color: primaryTextColor,
      ),
      // 14px — Body secondary
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
      // 14px — Button labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.35,
        color: primaryTextColor,
      ),
      // 12px — Small labels
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: secondaryTextColor,
      ),
      // 11px — Tiny metadata
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.25,
        color: secondaryTextColor,
      ),
    );
  }
}
