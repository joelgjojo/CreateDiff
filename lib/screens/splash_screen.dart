import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import 'onboarding_screen.dart';
import 'creator_profile_screen.dart';
import 'main_shell.dart';

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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 1600));
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
        transitionDuration: const Duration(milliseconds: 300),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                    borderRadius: AppRadius.rXl,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'CD',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'CreateDiff',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'IDEA → READY-TO-POST CONTENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
