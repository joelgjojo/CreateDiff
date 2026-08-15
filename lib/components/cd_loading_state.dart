import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CDLoadingState extends StatefulWidget {
  final String currentMessage;

  const CDLoadingState({
    super.key,
    required this.currentMessage,
  });

  @override
  State<CDLoadingState> createState() => _CDLoadingStateState();
}

class _CDLoadingStateState extends State<CDLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final bg = isDark
        ? AppColors.darkPrimaryBackground.withOpacity(0.92)
        : AppColors.primaryBackground.withOpacity(0.92);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          color: bg,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkAccent1 : AppColors.accent1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.8,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl3),
              Text(
                'CreateDiff Studio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Text(
                  widget.currentMessage,
                  key: ValueKey(widget.currentMessage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(0, primaryColor),
                  _buildDot(1, primaryColor),
                  _buildDot(2, primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}
