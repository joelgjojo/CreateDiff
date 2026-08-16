import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_onboarding_slide.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_atmospheric_background.dart';
import 'creator_profile_screen.dart';

/// Atmospheric onboarding flow introducing the studio value proposition.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Welcome to CreateDiff',
      'desc': 'Your personal studio that turns single ideas into complete, publish-ready content packs.',
      'color': CDColors.primaryLight,
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'Brand Memory Engine',
      'desc': 'Set your niche, voice, and style once. Every generation is tailored specifically to you.',
      'color': CDColors.icyBlue,
    },
    {
      'icon': Icons.bolt_rounded,
      'title': 'Zero-Prompt Creation',
      'desc': 'No complex prompt engineering required. Type a raw idea, and we handle the craft.',
      'color': CDColors.success,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: CDMotion.screen,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await AppState.instance.completeOnboarding();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CreatorProfileScreen(isInitialSetup: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: CDMotion.screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CDAtmosphericBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    AppHaptics.light();
                  },
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return CDOnboardingSlide(
                      icon: slide['icon'] as IconData,
                      title: slide['title'] as String,
                      description: slide['desc'] as String,
                      accentColor: slide['color'] as Color,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CDSpacing.xl,
                  vertical: CDSpacing.xl,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages,
                        (index) => AnimatedContainer(
                          duration: CDMotion.standard,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentPage == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? CDColors.primary
                                : (isDark ? CDColors.darkMuted : CDColors.lightMuted).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(CDRadius.pill),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: CDSpacing.xl),
                    CDPrimaryButton(
                      label: _currentPage == _totalPages - 1
                          ? 'Get Started ✦'
                          : 'Next',
                      isFullWidth: true,
                      height: 52,
                      onPressed: _currentPage == _totalPages - 1
                          ? _completeOnboarding
                          : _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
