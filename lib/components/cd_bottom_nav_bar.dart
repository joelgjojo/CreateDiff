import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/create_screen.dart';

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
    final primaryColor = CDColors.primary;
    // Remove BackdropFilter, use semi-opaque solid background instead
    final isDark = CDColors.isDark(context);
    final bgColor = isDark 
        ? CDColors.darkSurface.withValues(alpha: 0.95) 
        : CDColors.lightSurface.withValues(alpha: 0.95);
    final border = CDColors.border(context);
    final inactiveColor = CDColors.textSecondary(context);

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: CDSpacing.lg,
          right: CDSpacing.lg,
          bottom: CDSpacing.xs,
        ),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: CDRadius.rPill,
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
                onTabChanged: onTabChanged,
                selectedIndex: selectedIndex,
              ),
              _buildCreateTab(
                context: context,
                activeColor: primaryColor,
                selectedIndex: selectedIndex,
              ),
              _buildTab(
                index: 2,
                icon: Icons.palette_outlined,
                activeIcon: Icons.palette_rounded,
                label: 'Designs',
                activeColor: primaryColor,
                inactiveColor: inactiveColor,
                onTabChanged: onTabChanged,
                selectedIndex: selectedIndex,
              ),
              _buildTab(
                index: 3,
                icon: Icons.history_rounded,
                activeIcon: Icons.history_rounded,
                label: 'History',
                activeColor: primaryColor,
                inactiveColor: inactiveColor,
                onTabChanged: onTabChanged,
                selectedIndex: selectedIndex,
              ),
              _buildTab(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                activeColor: primaryColor,
                inactiveColor: inactiveColor,
                onTabChanged: onTabChanged,
                selectedIndex: selectedIndex,
              ),
            ],
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
    required ValueChanged<int> onTabChanged,
    required int selectedIndex,
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
          borderRadius: CDRadius.rPill,
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

  Widget _buildCreateTab({
    required BuildContext context,
    required Color activeColor,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == 1;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.light();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen()),
            );
          },
          borderRadius: CDRadius.rPill,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : activeColor.withValues(alpha: 0.12),
                  borderRadius: CDRadius.rPill,
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
