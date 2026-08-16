import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium luminous CTA button featuring a rich studio gradient,
/// top specular bevel highlight, soft ambient glow shadow, and smooth press scale.
class CDPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? textColor;

  const CDPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.textColor,
  });

  @override
  State<CDPrimaryButton> createState() => _CDPrimaryButtonState();
}

class _CDPrimaryButtonState extends State<CDPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CDMotion.micro,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: CDButton.pressScale).animate(
      CurvedAnimation(parent: _controller, curve: CDMotion.defaultCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final height = widget.height ?? CDButton.standardHeight;
    final txtColor = widget.textColor ?? Colors.white;

    final defaultGradient = widget.gradient ??
        (widget.backgroundColor != null
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8C7DFF),
                  Color(0xFF6C5CE7),
                ],
              ));

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(txtColor),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: CDSpacing.sm),
          ],
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: txtColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: AnimatedOpacity(
        duration: CDMotion.micro,
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          height: height,
          constraints: BoxConstraints(
            minWidth: widget.isFullWidth ? double.infinity : 118,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? (defaultGradient == null ? CDColors.primary : null),
            gradient: defaultGradient,
            borderRadius: BorderRadius.circular(CDRadius.medium),
            boxShadow: isEnabled
                ? [
                    // Studio luminous ambient glow
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    // Crisp bottom depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Top specular rim light
              Positioned(
                top: 0,
                left: CDRadius.medium * 0.5,
                right: CDRadius.medium * 0.5,
                height: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled
                      ? () {
                          AppHaptics.light();
                          widget.onPressed!();
                        }
                      : null,
                  onTapDown: (_) {
                    if (isEnabled) _controller.forward();
                  },
                  onTapUp: (_) {
                    if (isEnabled) _controller.reverse();
                  },
                  onTapCancel: () {
                    if (isEnabled) _controller.reverse();
                  },
                  borderRadius: BorderRadius.circular(CDRadius.medium),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl),
                    child: Center(child: content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
