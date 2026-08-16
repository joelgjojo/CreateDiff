import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A high-performance environmental background that renders subtle,
/// non-distracting atmospheric lighting (electric blue-violet ambient glow).
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
              Color(0xFFF7F9FC),
              Color(0xFFEDF1F8),
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
            CDColors.darkSecondaryBackground,
            CDColors.darkBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Ambient Orb 1: Top-Right (Electric Blue-Violet Glow #4F43F9)
          Positioned(
            top: -60,
            right: -60,
            width: 340,
            height: 340,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CDColors.brand.withValues(alpha: 0.12),
                      CDColors.primaryLight.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Ambient Orb 2: Bottom-Left (Soft Lavender Ambient #E0E3FF)
          Positioned(
            bottom: 40,
            left: -80,
            width: 360,
            height: 360,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CDColors.lavender.withValues(alpha: 0.06),
                      CDColors.brand.withValues(alpha: 0.02),
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
