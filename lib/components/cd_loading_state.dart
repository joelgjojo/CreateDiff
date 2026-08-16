import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A calm, luminous generation overlay with breathing ambient pulses,
/// frosted glass backdrop, and rotating studio milestone messages.
class CDLoadingState extends StatefulWidget {
  final String? currentMessage;

  const CDLoadingState({
    super.key,
    this.currentMessage,
  });

  @override
  State<CDLoadingState> createState() => _CDLoadingStateState();
}

class _CDLoadingStateState extends State<CDLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  int _messageIndex = 0;
  Timer? _messageTimer;

  final List<String> _rotatingMessages = const [
    'Finding the strongest angle...',
    'Adapting to your brand voice...',
    'Structuring your hooks & caption...',
    'Curating strategic hashtags...',
    'Polishing your personalized pack...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _messageTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _rotatingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final displayedMessage = widget.currentMessage ?? _rotatingMessages[_messageIndex];
    final accentColor = CDColors.primaryColor(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CDGlass.heavyBlurSigma,
          sigmaY: CDGlass.heavyBlurSigma,
        ),
        child: Container(
          color: (isDark ? const Color(0xFF080A0F) : const Color(0xFFF1F4F8))
              .withValues(alpha: 0.88),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Luminous Breathing Orb Centerpiece
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Diffused Outer Glow
                      Container(
                        width: 120 * _scaleAnimation.value,
                        height: 120 * _scaleAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFC9D6FF).withValues(alpha: 0.22 * _glowAnimation.value),
                              const Color(0xFFA0B9FF).withValues(alpha: 0.08 * _glowAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Frosted Glass Orb Ring
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.90),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC9D6FF).withValues(alpha: isDark ? 0.22 : 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 26,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: CDSpacing.xxxl),
              Text(
                'Creating Your Studio Pack',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.4,
                      color: CDColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: CDSpacing.sm),
              AnimatedSwitcher(
                duration: CDMotion.standard,
                child: Text(
                  displayedMessage,
                  key: ValueKey(displayedMessage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CDColors.textSecondary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
