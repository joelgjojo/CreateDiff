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
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'badge': 'Productivity Studio',
      'headline': 'Create better content.\nFaster.',
      'description': 'Turn one idea into a complete content pack — hooks, captions, hashtags, and designs in seconds.',
      'icon': Icons.bolt_rounded,
    },
    {
      'badge': 'Zero Prompting',
      'headline': 'No prompting\nrequired.',
      'description': 'Tell CreateDiff what you\'re posting in plain words. We handle all the platform formatting & AI engineering.',
      'icon': Icons.tune_rounded,
    },
    {
      'badge': 'Brand Memory',
      'headline': 'Make it sound\nlike you.',
      'description': 'CreateDiff remembers your niche, tone, language, and audience for consistent, personalized output every time.',
      'icon': Icons.fingerprint_rounded,
    },
    {
      'badge': 'Visual Studio',
      'headline': 'Designed, not\njust generated.',
      'description': 'Turn your content directly into ready-to-post social media visuals with custom brand styling.',
      'icon': Icons.palette_outlined,
    },
  ];

  void _onNext() {
    AppHaptics.light();
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    AppHaptics.success();
    await AppState.instance.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CreatorProfileScreen(isInitialSetup: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Brand & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'CreateDiff',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  if (_currentIndex < _slides.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
            // Swipeable Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  final s = _slides[index];
                  return CDOnboardingSlide(
                    badge: s['badge'] as String,
                    headline: s['headline'] as String,
                    description: s['description'] as String,
                    visualIcon: s['icon'] as IconData,
                  );
                },
              ),
            ),
            // Indicators & Navigation Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2, vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? primaryColor
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: AppRadius.rPill,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  CDPrimaryButton(
                    label: _currentIndex < _slides.length - 1 ? 'Continue' : 'Set Up My Brand ✦',
                    isFullWidth: true,
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
