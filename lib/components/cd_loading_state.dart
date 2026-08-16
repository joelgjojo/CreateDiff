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
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    final primaryColor = CDColors.primary;
    final bg = CDColors.background(context).withValues(alpha: 0.95);
    final surfaceColor = CDColors.elevated(context);
    final borderColor = CDColors.border(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: bg,
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Calm pulsing animation
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 1.0,
                ),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: CDSpacing.xxl),
            Text(
              'Creating your content pack',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: CDSpacing.xs),
            AnimatedSwitcher(
              duration: CDMotion.standard,
              switchInCurve: CDMotion.enterCurve,
              switchOutCurve: CDMotion.exitCurve,
              child: Text(
                widget.currentMessage,
                key: ValueKey(widget.currentMessage),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CDColors.textSecondary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
