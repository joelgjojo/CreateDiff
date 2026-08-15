import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- CreateDiff Primary Brand Accent ---
  static const Color primary = Color(0xFF6C5CE7); // Refined Violet
  static const Color secondary = Color(0xFFA29BFE); // Soft Lavender Accent

  // --- Dark Mode Surfaces (Layered Neutrals) ---
  static const Color darkBackground = Color(0xFF121218); // Deep Charcoal Canvas
  static const Color darkSurface1 = Color(0xFF18181F); // Level 1 Card Surface
  static const Color darkSurface2 = Color(0xFF202027); // Level 2 Elevated Surface
  static const Color darkSurface3 = Color(0xFF282831); // Level 3 Higher Elevation
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% Crisp White Border
  static const Color darkBorderSubtle = Color(0x0FFFFFFF); // 6% Subtle Border

  static const Color darkPrimaryText = Color(0xFFF5F5F7); // Soft White
  static const Color darkSecondaryText = Color(0xFFA1A1AA); // Muted Slate
  static const Color darkTertiaryText = Color(0xFF71717A); // Deep Muted Slate

  // --- Light Mode Surfaces (Warm Neutrals) ---
  static const Color lightBackground = Color(0xFFF7F7F8); // Clean Warm Canvas
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White Surface
  static const Color lightSecondarySurface = Color(0xFFF1F1F4); // Soft Grey Surface
  static const Color lightSurface3 = Color(0xFFE4E4E7); // Level 3 Surface
  static const Color lightBorder = Color(0x1F1A1A1E); // 12% Slate Border
  static const Color lightBorderSubtle = Color(0x0D1A1A1E); // 5% Subtle Border

  static const Color lightPrimaryText = Color(0xFF17171B); // Near-Black
  static const Color lightSecondaryText = Color(0xFF6B7280); // Neutral Slate
  static const Color lightTertiaryText = Color(0xFF9CA3AF); // Muted Slate

  // --- Semantic State Accents ---
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // --- Platform Branding Accents ---
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);

  // --- Custom Glass Surface Properties ---
  static const Color glassDarkBg = Color(0xD918181F); // 85% Surface
  static const Color glassLightBg = Color(0xEBFFFFFF); // 92% Surface
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 20.0;
  static const double pill = 100.0;

  static BorderRadius get rSmall => BorderRadius.circular(small);
  static BorderRadius get rMedium => BorderRadius.circular(medium);
  static BorderRadius get rLarge => BorderRadius.circular(large);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}

class AppHaptics {
  static void light() => HapticFeedback.lightImpact();
  static void selection() => HapticFeedback.selectionClick();
  static void medium() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightPrimaryText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppColors.lightPrimaryText, AppColors.lightSecondaryText),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface1,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkPrimaryText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppColors.darkPrimaryText, AppColors.darkSecondaryText),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.18,
        color: primaryTextColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.22,
        color: primaryTextColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.26,
        color: primaryTextColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: primaryTextColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.32,
        color: primaryTextColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.35,
        color: primaryTextColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.38,
        color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
        height: 1.4,
        color: primaryTextColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
        color: secondaryTextColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.45,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.35,
        color: primaryTextColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: secondaryTextColor,
      ),
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
