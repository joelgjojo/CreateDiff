import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- Light Theme Palette ---
  static const Color primary = Color(0xFF6C5CE7); // Refined CreateDiff Violet
  static const Color secondary = Color(0xFFA29BFE); // Lighter violet for secondary accents
  static const Color tertiary = Color(0xFF2D2D3A); // Dark tone for badges/cards
  static const Color alternate = Color(0xFFF0F0F5); // Subtle alternate background
  static const Color primaryText = Color(0xFF1A1A1E); // Near-black for crisp readability
  static const Color secondaryText = Color(0xFF6B7280); // Medium slate gray
  static const Color primaryBackground = Color(0xFFFAFAFA); // Warm white
  static const Color secondaryBackground = Color(0xFFFFFFFF); // Pure white for cards

  static const Color accent1 = Color(0x266C5CE7); // 15% violet tint
  static const Color accent2 = Color(0x146C5CE7); // 8% subtle violet
  static const Color accent3 = Color(0x0D1A1A1E); // 5% dark tint
  static const Color accent4 = Color(0xE6FFFFFF); // 90% white glass

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Custom Glass & Surface (Light)
  static const Color glassBackground = Color(0xB8FFFFFF); // 72% white
  static const Color glassBorder = Color(0x2E1A1A1E); // 18% subtle dark border
  static const Color surfaceElevated = Color(0xF2FFFFFF); // 95% white
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0x0F000000); // 6% black
  static const Color shimmer = Color(0x0A6C5CE7);

  // --- Dark Theme Palette (Intentional Graphite) ---
  static const Color darkPrimary = Color(0xFF7C6CF0); // Brighter violet for dark contrast
  static const Color darkSecondary = Color(0xFFB0A8FF);
  static const Color darkTertiary = Color(0xFF3D3D4E);
  static const Color darkAlternate = Color(0xFF2A2A35);
  static const Color darkPrimaryText = Color(0xFFF5F5F7); // Soft white
  static const Color darkSecondaryText = Color(0xFF9CA3AF); // Muted slate
  static const Color darkPrimaryBackground = Color(0xFF121218); // Deep graphite
  static const Color darkSecondaryBackground = Color(0xFF1C1C24); // Slightly lighter surface

  static const Color darkAccent1 = Color(0x337C6CF0); // 20% violet
  static const Color darkAccent2 = Color(0x1A7C6CF0); // 10% violet
  static const Color darkAccent3 = Color(0x0FF5F5F7); // 6% light tint
  static const Color darkAccent4 = Color(0xD91C1C24); // 85% dark surface

  static const Color darkSuccess = Color(0xFF00D2A0);
  static const Color darkWarning = Color(0xFFFFD93D);
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkInfo = Color(0xFF6CB4EE);

  // Custom Glass & Surface (Dark)
  static const Color darkGlassBackground = Color(0xA61C1C24); // 65% dark
  static const Color darkGlassBorder = Color(0x1FFFFFFF); // 12% white border
  static const Color darkSurfaceElevated = Color(0xE6282834); // 90% elevated
  static const Color darkCardSurface = Color(0xFF1E1E28);
  static const Color darkDividerColor = Color(0x14FFFFFF); // 8% white
  static const Color darkShimmer = Color(0x0F7C6CF0);

  // Platform Branding Accents
  static const Color instagram = Color(0xFFE4405F);
  static const Color youtube = Color(0xFFFF0000);
  static const Color linkedin = Color(0xFF0A66C2);
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
  static const double xl6 = 64.0;
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

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.secondaryBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppColors.primaryText, AppColors.secondaryText),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkPrimaryBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSecondaryBackground,
        error: AppColors.darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkPrimaryText,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(AppColors.darkPrimaryText, AppColors.darkSecondaryText),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: primaryTextColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: primaryTextColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
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
        letterSpacing: 0,
        height: 1.35,
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
        height: 1.4,
        color: primaryTextColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
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
        letterSpacing: 0.15,
        height: 1.5,
        color: primaryTextColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: secondaryTextColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.5,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.3,
        color: secondaryTextColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        height: 1.3,
        color: secondaryTextColor,
      ),
    );
  }
}
