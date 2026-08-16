import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(CDSpacing.xl),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: accentColor,
            ),
          ),
          const SizedBox(height: CDSpacing.xxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: CDColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: CDSpacing.md),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CDColors.textSecondary(context),
                  fontSize: 14,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}
