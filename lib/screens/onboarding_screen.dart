import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_onboarding_slide.dart';
import '../components/cd_primary_button.dart';
import 'creator_profile_screen.dart';

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
      'desc': 'Your AI-powered creator studio...',
      'color': CDColors.primary
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'Brand Memory',
      'desc': 'Set your niche, tone, and audience once.',
      'color': CDColors.success
    },
    {
      'icon': Icons.bolt_rounded,
      'title': 'Zero-Prompt Engine',
      'desc': 'Just type an idea, and we handle the prompts.',
      'color': CDColors.info
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
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    await AppState.instance.completeOnboarding();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const CreatorProfileScreen(isInitialSetup: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: CDColors.surface(context),
      body: SafeArea(
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
                horizontal: CDSpacing.lg,
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
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? CDColors.primary
                              : (isDark ? CDColors.darkMuted : CDColors.lightMuted).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(CDRadius.pill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: CDSpacing.xl),
                  CDPrimaryButton(
                    label: _currentPage == _totalPages - 1
                        ? 'Get Started'
                        : 'Next',
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
    );
  }
}
