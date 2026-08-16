import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Renders a high-performance atmospheric background with soft environmental
/// ambient lighting (icy blue + cool lavender + deep violet).
///
/// Designed to sit behind screens so translucent frosted glass cards placed
/// above it exhibit natural refraction and luminous depth.
class CDAtmosphericBackground extends StatelessWidget {
  final Widget child;

  const CDAtmosphericBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CDColors.background(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Orb 1: Top-Right (Icy Blue / Cool Lavender Ambient Glow)
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.2,
            child: IgnorePointer(
              child: Container(
                width: size.width * 1.1,
                height: size.width * 1.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.55,
                    colors: isDark
                        ? [
                            CDColors.icyBlue.withValues(alpha: 0.12),
                            CDColors.primaryLight.withValues(alpha: 0.06),
                            Colors.transparent,
                          ]
                        : [
                            CDColors.icyBlue.withValues(alpha: 0.35),
                            CDColors.primaryLight.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Orb 2: Bottom-Left (Deep Studio Violet / Lavender Halo)
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.25,
            child: IgnorePointer(
              child: Container(
                width: size.width * 1.2,
                height: size.width * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: isDark
                        ? [
                            CDColors.primary.withValues(alpha: 0.10),
                            CDColors.primarySubtle.withValues(alpha: 0.04),
                            Colors.transparent,
                          ]
                        : [
                            CDColors.lavender.withValues(alpha: 0.25),
                            CDColors.primaryLight.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient Orb 3: Center-Right Subtle Shimmer (Center breathing room)
          Positioned(
            top: size.height * 0.35,
            right: -size.width * 0.35,
            child: IgnorePointer(
              child: Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: isDark
                        ? [
                            CDColors.lavender.withValues(alpha: 0.04),
                            Colors.transparent,
                          ]
                        : [
                            CDColors.icyBlue.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                  ),
                ),
              ),
            ),
          ),

          // Screen Content Layer
          child,
        ],
      ),
    );
  }
}
