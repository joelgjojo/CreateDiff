import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted glass card for selecting a content format (Reel, Post, Story, etc.)
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
    final isDark = CDColors.isDark(context);
    final accentColor = CDColors.primaryColor(context);

    final unselectedGradient = isDark
        ? CDColors.darkGlassGradient
        : CDColors.lightGlassGradient;

    final selectedGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC9D6FF).withValues(alpha: 0.14),
              const Color(0xFFA0B9FF).withValues(alpha: 0.04),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC9D6FF).withValues(alpha: 0.35),
              Colors.white.withValues(alpha: 0.90),
            ],
          );

    final border = isSelected
        ? accentColor
        : (isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(CDRadius.large),
        child: AnimatedContainer(
          duration: CDMotion.micro,
          curve: CDMotion.defaultCurve,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? selectedGradient : unselectedGradient,
            borderRadius: BorderRadius.circular(CDRadius.large),
            border: Border.all(
              color: border,
              width: isSelected ? 1.4 : 0.9,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFFC9D6FF).withValues(alpha: 0.18)
                          : const Color(0xFF4A69BD).withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                      blurRadius: 8,
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: isDark ? 0.20 : 0.12)
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(CDRadius.medium),
                    ),
                    child: Icon(
                      icon,
                      size: 17,
                      color: isSelected
                          ? accentColor
                          : CDColors.textPrimary(context),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: isDark ? const Color(0xFF080A0F) : Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isSelected
                                ? accentColor
                                : CDColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10.5,
                            height: 1.2,
                            color: CDColors.textSecondary(context),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
