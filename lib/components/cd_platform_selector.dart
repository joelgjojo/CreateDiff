import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDPlatformSelector extends StatelessWidget {
  final List<String> platforms;
  final String selectedPlatform;
  final ValueChanged<String> onPlatformSelected;

  const CDPlatformSelector({
    super.key,
    required this.platforms,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final unselectedBg = isDark ? AppColors.darkAccent3 : AppColors.accent3;
    final unselectedText = isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: platforms.map((platform) {
          final isSelected = selectedPlatform.toLowerCase() == platform.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onPlatformSelected(platform),
                borderRadius: AppRadius.rPill,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : unselectedBg,
                    borderRadius: AppRadius.rPill,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkGlassBorder : AppColors.glassBorder),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPlatformIcon(platform, isSelected ? Colors.white : unselectedText),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        platform,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : unselectedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _getPlatformIcon(String platform, Color color) {
    IconData iconData;
    switch (platform.toLowerCase()) {
      case 'instagram':
        iconData = Icons.camera_alt_outlined;
        break;
      case 'youtube':
        iconData = Icons.play_circle_outline_rounded;
        break;
      case 'linkedin':
        iconData = Icons.work_outline_rounded;
        break;
      default:
        iconData = Icons.auto_awesome_rounded;
    }
    return Icon(iconData, size: 16, color: color);
  }
}
