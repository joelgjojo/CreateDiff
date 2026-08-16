import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_atmospheric_background.dart';
import '../components/cd_logo.dart';
import 'onboarding_screen.dart';
import 'creator_profile_screen.dart';
import 'main_shell.dart';

/// The cinematic atmospheric brand splash screen.
///
/// Implements the official 800ms entrance with the CD Monogram
/// and refined brand lockup reveal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: CDMotion.splash, // 800ms cinematic entrance
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.40, 1.0, curve: Curves.easeOutCubic),
    );

    _animController.forward();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final appState = AppState.instance;

    Widget nextScreen;
    if (!appState.hasCompletedOnboarding) {
      nextScreen = const OnboardingScreen();
    } else if (!appState.hasCompletedProfileSetup) {
      nextScreen = const CreatorProfileScreen(isInitialSetup: true);
    } else {
      nextScreen = const MainShell();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: CDMotion.screen,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CDAtmosphericBackground(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official CD Monogram with diffused ambient glow
                    Container(
                      padding: const EdgeInsets.all(CDSpacing.xl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CDColors.brand.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.20),
                            blurRadius: 36,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CDLogo.monogram(
                        height: 54,
                        colorMode: CDLogoColorMode.adaptive,
                        isHero: true,
                        heroTag: 'cd_brand_monogram',
                      ),
                    ),
                    const SizedBox(height: CDSpacing.md),
                    // Wordmark
                    const CDLogo.wordmark(
                      height: 28,
                      colorMode: CDLogoColorMode.adaptive,
                    ),
                    const SizedBox(height: CDSpacing.sm),
                    // Studio Subtitle
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'AI CONTENT STUDIO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: CDColors.textMuted(context),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
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
  }
}
