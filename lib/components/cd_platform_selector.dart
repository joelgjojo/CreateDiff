import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A horizontal scrollable row of frosted glass platform selector chips.
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
    final isDark = CDColors.isDark(context);
    final primaryColor = CDColors.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: platforms.map((platform) {
          final isSelected = selectedPlatform.toLowerCase() == platform.toLowerCase();

          final chipGradient = isSelected
              ? (isDark
                  ? LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.22),
                        primaryColor.withValues(alpha: 0.10),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        CDColors.icyBlue.withValues(alpha: 0.50),
                        Colors.white.withValues(alpha: 0.90),
                      ],
                    ))
              : (isDark
                  ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.70),
                      ],
                    ));

          final borderColor = isSelected
              ? primaryColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.06));

          return Padding(
            padding: const EdgeInsets.only(right: CDSpacing.sm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  onPlatformSelected(platform);
                },
                borderRadius: BorderRadius.circular(CDRadius.pill),
                child: AnimatedContainer(
                  duration: CDMotion.micro,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CDSpacing.md,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: chipGradient,
                    borderRadius: BorderRadius.circular(CDRadius.pill),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.20),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPlatformIcon(platform, isSelected ? primaryColor : CDColors.textSecondary(context)),
                      const SizedBox(width: 6),
                      Text(
                        platform,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? primaryColor : CDColors.textPrimary(context),
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
    return Icon(iconData, size: 15, color: color);
  }
}
