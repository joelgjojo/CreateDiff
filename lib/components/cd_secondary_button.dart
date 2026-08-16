import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A frosted glass secondary button with clean typography and subtle border.
class CDSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isFullWidth;
  final double? height;

  const CDSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.height = CDButton.standardHeight,
  });

  @override
  State<CDSecondaryButton> createState() => _CDSecondaryButtonState();
}

class _CDSecondaryButtonState extends State<CDSecondaryButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
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
    final isEnabled = widget.onPressed != null;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final textColor = isEnabled
        ? CDColors.textPrimary(context)
        : CDColors.textMuted(context);
    final buttonHeight = widget.height ?? CDButton.standardHeight;

    final bgGradient = isDark
        ? CDColors.darkGlassGradient
        : CDColors.lightGlassGradient;

    final buttonWidget = AnimatedScale(
      scale: _isPressed ? CDButton.pressScale : 1.0,
      duration: CDMotion.micro,
      curve: Curves.easeInOut,
      child: Container(
        height: buttonHeight,
        constraints: BoxConstraints(
          minWidth: widget.isFullWidth ? double.infinity : 100,
        ),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(CDRadius.medium),
          border: Border.all(color: border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled
                ? () {
                    AppHaptics.light();
                    widget.onPressed!();
                  }
                : null,
            borderRadius: BorderRadius.circular(CDRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg),
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: textColor, size: 16),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: CDSpacing.xs),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: widget.isFullWidth
          ? SizedBox(width: double.infinity, child: buttonWidget)
          : buttonWidget,
    );
  }
}
