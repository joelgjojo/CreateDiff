import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium Frosted Glass Card with subtle gradient fill, specular rim light,
/// soft diffused shadow, and optional selective backdrop blur.
class CDGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;
  final bool useBlur;
  final bool showHighlight;

  const CDGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.elevated = false,
    this.useBlur = false,
    this.showHighlight = true,
  });

  @override
  State<CDGlassCard> createState() => _CDGlassCardState();
}

class _CDGlassCardState extends State<CDGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final r = widget.borderRadius ?? CDRadius.large;
    final borderRadius = BorderRadius.circular(r);

    // Dynamic glass fills
    final defaultGlassGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: widget.elevated ? 0.12 : 0.08),
              Colors.white.withValues(alpha: widget.elevated ? 0.04 : 0.02),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: widget.elevated ? 0.95 : 0.82),
              Colors.white.withValues(alpha: widget.elevated ? 0.85 : 0.65),
            ],
          );

    // Specular border color
    final defaultBorder = widget.borderColor ??
        (isDark
            ? (widget.elevated
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.10))
            : (widget.elevated
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05)));

    Widget cardContent = Padding(
      padding: widget.padding ?? const EdgeInsets.all(CDSpacing.lg),
      child: widget.child,
    );

    // Specular top highlight shimmer (subtle gradient line at top inside)
    if (widget.showHighlight) {
      cardContent = Stack(
        children: [
          // Top specular highlight line
          Positioned(
            top: 0,
            left: r * 0.5,
            right: r * 0.5,
            height: 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    isDark
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.white.withValues(alpha: 0.90),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          cardContent,
        ],
      );
    }

    if (widget.useBlur) {
      cardContent = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: CDGlass.blurSigma,
            sigmaY: CDGlass.blurSigma,
          ),
          child: cardContent,
        ),
      );
    }

    final card = AnimatedContainer(
      duration: CDMotion.micro,
      margin: widget.margin,
      transform: _isPressed ? Matrix4.diagonal3Values(0.985, 0.985, 1.0) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        gradient: widget.backgroundColor == null ? defaultGlassGradient : null,
        borderRadius: borderRadius,
        border: Border.all(
          color: defaultBorder,
          width: CDGlass.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: widget.elevated ? 0.35 : 0.18)
                : Colors.black.withValues(alpha: widget.elevated ? 0.08 : 0.03),
            blurRadius: widget.elevated ? 24 : 12,
            offset: widget.elevated ? const Offset(0, 8) : const Offset(0, 4),
          ),
          if (widget.elevated && isDark)
            BoxShadow(
              color: CDColors.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: cardContent,
    );

    if (widget.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            widget.onTap!();
          },
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}
