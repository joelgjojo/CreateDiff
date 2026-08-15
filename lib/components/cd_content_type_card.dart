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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.cardSurface;
    final selectedBg = isDark ? AppColors.darkAccent1 : AppColors.accent1;
    final defaultBorder = isDark ? AppColors.darkGlassBorder : AppColors.glassBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rLarge,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : cardBg,
            borderRadius: AppRadius.rLarge,
            border: Border.all(
              color: isSelected ? primaryColor : defaultBorder,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withOpacity(0.16)
                          : (isDark ? AppColors.darkAccent3 : AppColors.accent3),
                      borderRadius: AppRadius.rMedium,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.3,
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
