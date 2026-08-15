import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDOnboardingSlide extends StatelessWidget {
  final String headline;
  final String description;
  final IconData visualIcon;
  final String badge;

  const CDOnboardingSlide({
    super.key,
    required this.headline,
    required this.description,
    required this.visualIcon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkAccent1 : AppColors.accent1,
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              badge.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl3),
          // Minimal Tactile Visual Element
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
              borderRadius: AppRadius.rXl,
              border: Border.all(
                color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                visualIcon,
                size: 52,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl4),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.4,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
