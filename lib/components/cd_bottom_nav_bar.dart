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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final glassBg = isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceElevated;
    final glassBorder = isDark ? AppColors.darkGlassBorder : AppColors.glassBorder;
    final inactiveColor = isDark ? AppColors.darkSecondaryText : AppColors.secondaryText;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.sm,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: glassBg.withOpacity(isDark ? 0.88 : 0.92),
            borderRadius: AppRadius.rXl,
            border: Border.all(color: glassBorder, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.rXl,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTab(
                    index: 0,
                    icon: Icons.home_rounded,
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
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: AppRadius.rLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab({required Color activeColor}) {
    final isSelected = selectedIndex == 1;
    return Expanded(
      child: InkWell(
        onTap: () => onTabChanged(1),
        borderRadius: AppRadius.rLarge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : activeColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: isSelected ? Colors.white : activeColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Create',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
