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
    final primaryColor = AppColors.primary;
    final unselectedBg = isDark ? AppColors.darkSurface1 : AppColors.lightSecondarySurface;
    final unselectedText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

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
                onTap: () {
                  AppHaptics.selection();
                  onPlatformSelected(platform);
                },
                borderRadius: AppRadius.rPill,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : unselectedBg,
                    borderRadius: AppRadius.rPill,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPlatformIcon(platform, isSelected ? Colors.white : unselectedText),
                      const SizedBox(width: 5),
                      Text(
                        platform,
                        style: TextStyle(
                          fontSize: 12,
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
    return Icon(iconData, size: 14, color: color);
  }
}
