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
    final primaryColor = CDColors.primary;
    final unselectedBg = CDColors.surface(context);
    final unselectedText = CDColors.textSecondary(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: platforms.map((platform) {
          final isSelected = selectedPlatform.toLowerCase() == platform.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: CDSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  onPlatformSelected(platform);
                },
                borderRadius: CDRadius.rPill,
                child: AnimatedContainer(
                  duration: CDMotion.micro,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CDSpacing.md,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withValues(alpha: 0.12) : unselectedBg,
                    borderRadius: CDRadius.rPill,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : CDColors.borderSubtle(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPlatformIcon(platform, isSelected ? primaryColor : unselectedText),
                      const SizedBox(width: 5),
                      Text(
                        platform,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? primaryColor : unselectedText,
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
