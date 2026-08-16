import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A floating frosted glass bottom navigation bar with Snowfall Hush / Ice-Blue styling.
class CDBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const CDBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final activeColor = CDColors.primaryColor(context);

    final glassBorder = isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle;
    final glassFill = isDark
        ? const Color(0xFF0D1017).withValues(alpha: 0.88)
        : const Color(0xFFF1F4F8).withValues(alpha: 0.90);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CDRadius.pill),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              if (isDark)
                BoxShadow(
                  color: const Color(0xFFC9D6FF).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CDRadius.pill),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: CDGlass.blurSigma,
                sigmaY: CDGlass.blurSigma,
              ),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: glassFill,
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  border: Border.all(color: glassBorder, width: 1.0),
                ),
                child: Row(
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      icon: Icons.home_rounded,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                    _buildCreateTab(
                      context: context,
                      activeColor: activeColor,
                      selectedIndex: selectedIndex,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 2,
                      icon: Icons.palette_outlined,
                      activeIcon: Icons.palette_rounded,
                      label: 'Studio',
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      icon: Icons.history_rounded,
                      activeIcon: Icons.history_rounded,
                      label: 'Archive',
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      activeColor: activeColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
    required bool isDark,
  }) {
    final isSelected = selectedIndex == index;
    final inactiveColor = CDColors.textMuted(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTabChanged(index);
          },
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: CDMotion.standard,
                curve: CDMotion.defaultCurve,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFFC9D6FF).withValues(alpha: 0.14)
                          : const Color(0xFF4A69BD).withValues(alpha: 0.12))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  border: isSelected
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFFC9D6FF).withValues(alpha: 0.28)
                              : const Color(0xFF4A69BD).withValues(alpha: 0.20),
                          width: 0.8,
                        )
                      : null,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTab({
    required BuildContext context,
    required Color activeColor,
    required int selectedIndex,
    required bool isDark,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.light();
            onTabChanged(1);
          },
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFDCE5FF),
                          Color(0xFFC9D6FF),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5A7BC7),
                          Color(0xFF4A69BD),
                        ],
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.40) : Colors.white.withValues(alpha: 0.20),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFC9D6FF).withValues(alpha: 0.25)
                        : const Color(0xFF4A69BD).withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 24,
                color: isDark ? const Color(0xFF080A0F) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
