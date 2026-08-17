import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cd_logo.dart';

/// A calm, luminous generation overlay with breathing ambient pulses,
/// frosted glass backdrop, official animated CD Monogram, and rotating studio milestone messages.
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
    'Connecting to Grok AI...',
    'Finding the strongest angle...',
    'Adapting to your brand voice...',
    'Polishing your content pack...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.40, end: 0.90).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _messageTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CDGlass.heavyBlurSigma,
          sigmaY: CDGlass.heavyBlurSigma,
        ),
        child: Container(
          color: (isDark ? const Color(0xFF080A0F) : const Color(0xFFF4F6FB))
              .withValues(alpha: 0.88),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Luminous Breathing Orb Centerpiece with Official CD Monogram
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
                  final scale = disableAnimations ? 1.0 : _scaleAnimation.value;
                  final glow = disableAnimations ? 0.65 : _glowAnimation.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Diffused Outer Glow
                      Container(
                        width: 130 * scale,
                        height: 130 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              CDColors.brand.withValues(alpha: 0.28 * glow),
                              CDColors.primaryLight.withValues(alpha: 0.08 * glow),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Frosted Glass Orb Ring
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.90),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : CDColors.brand.withValues(alpha: 0.15),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CDColors.brand.withValues(alpha: isDark ? 0.30 : 0.18),
                              blurRadius: 22,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CDLogo.monogram(
                            height: 24,
                            colorMode: isDark ? CDLogoColorMode.white : CDLogoColorMode.brand,
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: CDColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: CDSpacing.xs),
              AnimatedSwitcher(
                duration: CDMotion.standard,
                child: Text(
                  displayedMessage,
                  key: ValueKey(displayedMessage),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CDColors.textSecondary(context),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(height: CDSpacing.lg),
              // 4-Stage Progress Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_rotatingMessages.length, (idx) {
                  final isActive = idx == _messageIndex;
                  return AnimatedContainer(
                    duration: CDMotion.standard,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? CDColors.brand
                          : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(CDRadius.pill),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
