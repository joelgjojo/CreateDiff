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
    final primaryColor = AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                width: 1,
              ),
            ),
            child: Text(
              badge.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl2),
          // Minimal tactile visual icon box
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              borderRadius: AppRadius.rXl,
              border: Border.all(
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                visualIcon,
                size: 38,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl3),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  height: 1.22,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    fontSize: 14,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
