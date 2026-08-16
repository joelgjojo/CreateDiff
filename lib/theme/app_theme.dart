import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

export 'design_tokens.dart';

/// AppTheme builds the unified ThemeData for Dark and Light modes.
///
/// Typography System: Plus Jakarta Sans with editorial hierarchy.
/// Brand Color System: Official Blue-Violet (#4F43F9) with graphite dark & cool off-white light.
class AppTheme {
  AppTheme._();

  // ==========================================
  // DARK THEME (#080A0F Graphite Deep Studio)
  // ==========================================
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CDColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: CDColors.brand,
        onPrimary: Colors.white,
        primaryContainer: CDColors.accentSubdued,
        onPrimaryContainer: CDColors.lavender,
        secondary: CDColors.accentBright,
        onSecondary: Colors.white,
        surface: CDColors.darkBackground,
        onSurface: CDColors.darkTextPrimary,
        error: CDColors.error,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(baseTextTheme, CDColors.darkTextPrimary, CDColors.darkTextSecondary, CDColors.darkMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: CDColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: CDColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: CDColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CDRadius.large),
          side: const BorderSide(color: CDColors.darkBorderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: CDColors.darkBorderSubtle,
        thickness: 0.8,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF141824),
        contentTextStyle: const TextStyle(color: CDColors.darkTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.medium)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // LIGHT THEME (#F4F6FB Crisp Daylight Studio)
  // ==========================================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CDColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: CDColors.brand,
        onPrimary: Colors.white,
        primaryContainer: CDColors.lightAccentSubtle,
        onPrimaryContainer: CDColors.brand,
        secondary: CDColors.lightAccent,
        onSecondary: Colors.white,
        surface: CDColors.lightBackground,
        onSurface: CDColors.lightTextPrimary,
        error: CDColors.error,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(baseTextTheme, CDColors.lightTextPrimary, CDColors.lightTextSecondary, CDColors.lightMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: CDColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: CDColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: CDColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CDRadius.large),
          side: const BorderSide(color: CDColors.lightBorderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: CDColors.lightBorderSubtle,
        thickness: 0.8,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: const TextStyle(color: CDColors.lightTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.medium)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary, Color muted) {
    return base.copyWith(
      // Display: 36px Bold
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: primary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: primary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.7,
        height: 1.22,
      ),
      // Section titles: 20-22px Bold
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.28,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      // Body: 14-16px Regular
      bodyLarge: base.bodyLarge?.copyWith(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: secondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: secondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
      ),
      // Metadata & Labels: 11-14px Medium/Bold with letter spacing
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: secondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: muted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Haptic feedback helpers
class AppHaptics {
  AppHaptics._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void selection() => HapticFeedback.selectionClick();
}
