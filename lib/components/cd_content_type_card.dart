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
    final primaryColor = CDColors.primary;
    final cardBg = CDColors.surface(context);
    final selectedBg = primaryColor.withValues(alpha: 0.12);
    final border = isSelected
        ? primaryColor
        : CDColors.borderSubtle(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: CDRadius.rLarge,
        child: AnimatedContainer(
          duration: CDMotion.micro,
          curve: CDMotion.defaultCurve,
          padding: const EdgeInsets.all(CDSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : cardBg,
            borderRadius: CDRadius.rLarge,
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
                          : CDColors.elevated(context),
                      borderRadius: CDRadius.rMedium,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? primaryColor
                          : CDColors.textPrimary(context),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: CDColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: CDSpacing.sm),
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
                              : CDColors.textPrimary(context),
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
                          color: CDColors.textSecondary(context),
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
