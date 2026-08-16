import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/create_screen.dart';

/// A floating frosted glass bottom navigation bar with selective blur,
/// specular rim lighting, and luminous active pill indicators.
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
    final primaryColor = CDColors.primary;
    final inactiveColor = CDColors.textSecondary(context);

    final glassGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF141824).withValues(alpha: 0.85),
              const Color(0xFF0C0E14).withValues(alpha: 0.88),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.92),
              const Color(0xFFF0F3F9).withValues(alpha: 0.88),
            ],
          );

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: CDSpacing.lg,
          right: CDSpacing.lg,
          bottom: CDSpacing.xs,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: CDGlass.blurSigma,
              sigmaY: CDGlass.blurSigma,
            ),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: glassGradient,
                borderRadius: BorderRadius.circular(CDRadius.pill),
                border: Border.all(color: borderColor, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  if (isDark)
                    BoxShadow(
                      color: CDColors.primary.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -2),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Top specular highlight line
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    height: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.95),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
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
                        isDark: isDark,
                      ),
                      _buildCreateTab(
                        context: context,
                        activeColor: primaryColor,
                        selectedIndex: selectedIndex,
                        isDark: isDark,
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
                        isDark: isDark,
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
                        isDark: isDark,
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
                        isDark: isDark,
                      ),
                    ],
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
    required ValueChanged<int> onTabChanged,
    required int selectedIndex,
    required bool isDark,
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
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: CDMotion.standard,
                curve: CDMotion.defaultCurve,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? CDColors.primary.withValues(alpha: 0.16)
                          : CDColors.primary.withValues(alpha: 0.10))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                ),
                child: Icon(
                  isSelected ? (activeIcon ?? icon) : icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 20,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateScreen()),
            );
          },
          borderRadius: BorderRadius.circular(CDRadius.pill),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8C7DFF),
                      Color(0xFF6C5CE7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: CDColors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
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
