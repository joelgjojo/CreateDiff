import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A layered frosted glass container.
///
/// Combines a top specular highlight border, dual-tone translucent fill,
/// and subtle depth shadow. Selective blur is used only when `useBlur: true`.
class CDGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool elevated;
  final bool useBlur;
  final Color? backgroundColor;
  final Color? borderColor;

  const CDGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = CDRadius.large,
    this.onTap,
    this.elevated = false,
    this.useBlur = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CDGlassCard> createState() => _CDGlassCardState();
}

class _CDGlassCardState extends State<CDGlassCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);

    final defaultBorder = widget.elevated
        ? (isDark ? CDColors.darkBorderHighlight : CDColors.lightBorderHighlight)
        : (isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle);

    final border = widget.borderColor ?? defaultBorder;

    final fillGradient = widget.backgroundColor != null
        ? null
        : (isDark
            ? (widget.elevated
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: CDColors.darkSurfaceElevated.a),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: CDColors.darkSurface.a),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ))
            : (widget.elevated
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF7F9FC),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      Colors.white.withValues(alpha: 0.65),
                    ],
                  )));

    final card = AnimatedContainer(
      duration: CDMotion.micro,
      margin: widget.margin,
      transform: _isPressed ? Matrix4.diagonal3Values(0.985, 0.985, 1.0) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        gradient: fillGradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: border, width: widget.elevated ? 1.2 : 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: widget.elevated ? 16 : 8,
            offset: Offset(0, widget.elevated ? 6 : 2),
          ),
          if (isDark && widget.elevated)
            BoxShadow(
              color: const Color(0xFFC9D6FF).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -1),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Top rim specular highlight line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? CDColors.specularHighlightDark
                      : CDColors.specularHighlightLight,
                ),
              ),
            ),
            Padding(
              padding: widget.padding ?? const EdgeInsets.all(CDSpacing.lg),
              child: widget.child,
            ),
          ],
        ),
      ),
    );

    Widget content = card;

    if (widget.useBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: CDGlass.blurSigma,
            sigmaY: CDGlass.blurSigma,
          ),
          child: card,
        ),
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          AppHaptics.selection();
          widget.onTap!();
        },
        child: content,
      );
    }

    return content;
  }
}
