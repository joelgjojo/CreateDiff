import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A luminous Blue-Violet primary studio CTA button.
///
/// Features the official #4F43F9 brand gradient, crisp typography,
/// soft blue-violet ambient glow, and 0.96 press scale animation.
class CDPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final Widget? icon;

  const CDPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = CDButton.standardHeight,
    this.icon,
  });

  @override
  State<CDPrimaryButton> createState() => _CDPrimaryButtonState();
}

class _CDPrimaryButtonState extends State<CDPrimaryButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final gradient = isEnabled
        ? CDColors.brandGradient
        : (isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.05),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.04),
                ],
              ));

    const textColor = Colors.white;

    final buttonWidget = AnimatedScale(
      scale: _isPressed ? CDButton.pressScale : 1.0,
      duration: CDMotion.micro,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: CDMotion.micro,
        height: widget.height ?? CDButton.standardHeight,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(CDRadius.medium),
          border: Border.all(
            color: isEnabled
                ? Colors.white.withValues(alpha: isDark ? 0.20 : 0.15)
                : Colors.transparent,
            width: 1.0,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: CDColors.brand.withValues(alpha: isDark ? 0.32 : 0.24),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            IconTheme(
                              data: const IconThemeData(color: textColor, size: 16),
                              child: widget.icon!,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
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
