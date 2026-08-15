import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDContentTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const CDContentTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final cardBg = isDark ? AppColors.darkSurface1 : AppColors.lightSurface;
    final selectedBg = isDark
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.primary.withValues(alpha: 0.08);
    final border = isSelected
        ? primaryColor
        : (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: AppRadius.rLarge,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : cardBg,
            borderRadius: AppRadius.rLarge,
            border: Border.all(
              color: border,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface),
                      borderRadius: AppRadius.rMedium,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.25,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
