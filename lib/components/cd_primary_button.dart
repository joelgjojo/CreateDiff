import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final Color? backgroundColor;
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
    final btnColor = widget.backgroundColor ?? CDColors.primary;
    final txtColor = widget.textColor ?? Colors.white;
    final height = widget.height ?? CDButton.standardHeight;

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
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.1,
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
            minWidth: widget.isFullWidth ? double.infinity : 110,
          ),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: CDRadius.rMedium,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
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
              onTapDown: (_) {
                if (isEnabled) _controller.forward();
              },
              onTapUp: (_) {
                if (isEnabled) _controller.reverse();
              },
              onTapCancel: () {
                if (isEnabled) _controller.reverse();
              },
              borderRadius: CDRadius.rMedium,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
