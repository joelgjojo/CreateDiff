import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const CDPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
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
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final btnColor = widget.backgroundColor ?? primaryColor;
    final txtColor = widget.textColor ?? Colors.white;

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
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: txtColor,
                  fontWeight: FontWeight.w600,
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
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.45,
        child: Container(
          height: widget.height,
          constraints: BoxConstraints(
            minWidth: widget.isFullWidth ? double.infinity : 100,
          ),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: AppRadius.rMedium,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: btnColor.withOpacity(0.24),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              onTapDown: (_) {
                if (isEnabled) _controller.forward();
              },
              onTapUp: (_) {
                if (isEnabled) _controller.reverse();
              },
              onTapCancel: () {
                if (isEnabled) _controller.reverse();
              },
              borderRadius: AppRadius.rMedium,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
