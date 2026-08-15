import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final glassBg = isDark ? AppColors.glassDarkBg : AppColors.glassLightBg;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inactiveColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.xs,
        ),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: AppRadius.rXl,
            border: Border.all(color: border, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.rXl,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(
                    index: 0,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    activeColor: primaryColor,
                    inactiveColor: inactiveColor,
                  ),
                  _buildCreateTab(
                    activeColor: primaryColor,
                  ),
                  _buildTab(
                    index: 2,
                    icon: Icons.palette_outlined,
                    activeIcon: Icons.palette_rounded,
                    label: 'Designs',
                    activeColor: primaryColor,
                    inactiveColor: inactiveColor,
                  ),
                  _buildTab(
                    index: 3,
                    icon: Icons.history_rounded,
                    activeIcon: Icons.history_rounded,
                    label: 'History',
                    activeColor: primaryColor,
                    inactiveColor: inactiveColor,
                  ),
                  _buildTab(
                    index: 4,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    activeColor: primaryColor,
                    inactiveColor: inactiveColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            onTabChanged(index);
          },
          borderRadius: AppRadius.rLarge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildCreateTab({required Color activeColor}) {
    final isSelected = selectedIndex == 1;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.light();
            onTabChanged(1);
          },
          borderRadius: AppRadius.rLarge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : activeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.rPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: isSelected ? Colors.white : activeColor,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : activeColor,
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
