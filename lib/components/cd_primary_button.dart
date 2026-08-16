import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A luminous Ice-Blue primary studio CTA button.
///
/// Features a #C9D6FF -> #AFC4FF gradient, deep charcoal high-contrast typography,
/// top specular bevel line, soft blue ambient glow, and 0.97 press scale animation.
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
    this.height = 48.0,
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
        ? (isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDCE5FF), // Bright Luminous Ice Blue
                  Color(0xFFC9D6FF), // Primary Ice Blue
                  Color(0xFFAFC4FF), // Soft Blue Glow
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5A7BC7),
                  Color(0xFF4A69BD),
                ],
              ))
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

    // In dark mode: dark charcoal text on ice-blue button for high contrast physical feel
    final textColor = isEnabled
        ? (isDark ? const Color(0xFF080A0F) : Colors.white)
        : (isDark ? CDColors.darkMuted : CDColors.lightMuted);

    final buttonWidget = AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: CDMotion.micro,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: CDMotion.micro,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(CDRadius.medium),
          border: Border.all(
            color: isEnabled
                ? (isDark ? Colors.white.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.20))
                : Colors.transparent,
            width: 1.0,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFC9D6FF).withValues(alpha: 0.22)
                        : const Color(0xFF4A69BD).withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Row(
                        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            IconTheme(
                              data: IconThemeData(color: textColor, size: 16),
                              child: widget.icon!,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
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
