import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A high-performance environmental background that renders subtle,
/// non-distracting atmospheric lighting (ice blue + soft blue hush).
///
/// Designed to shine softly through translucent frosted glass layers
/// without introducing frame drops or saturated purple gradients.
class CDAtmosphericBackground extends StatelessWidget {
  final Widget child;

  const CDAtmosphericBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    if (!isDark) {
      return Container(
        decoration: const BoxDecoration(
          color: CDColors.lightBackground,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6F8FB),
              Color(0xFFEBF0F7),
            ],
          ),
        ),
        child: child,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: CDColors.darkBackground,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CDColors.darkBackground,
            CDColors.darkSecondaryBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient Orb 1: Top-Right (Soft Ice Blue Ambient #C9D6FF)
          Positioned(
            top: -60,
            right: -60,
            width: 320,
            height: 320,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC9D6FF).withValues(alpha: 0.08),
                      const Color(0xFFA0B9FF).withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Ambient Orb 2: Bottom-Left (Calm Soft Blue Hush #A0B9FF)
          Positioned(
            bottom: 40,
            left: -80,
            width: 340,
            height: 340,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA0B9FF).withValues(alpha: 0.05),
                      const Color(0xFFC9D6FF).withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Screen Content
          child,
        ],
      ),
    );
  }
}
