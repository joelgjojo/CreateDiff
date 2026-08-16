import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Frosted glass onboarding slide with luminous icon orb and editorial typography.
class CDOnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const CDOnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.16 : 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.40 : 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.20),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: accentColor,
            ),
          ),
          const SizedBox(height: CDSpacing.xxxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.6,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CDColors.textSecondary(context),
                  fontSize: 15,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}
