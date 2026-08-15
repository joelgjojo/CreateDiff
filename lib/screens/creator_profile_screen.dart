import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';
import '../services/app_state.dart';
import '../components/cd_text_input.dart';
import '../components/cd_primary_button.dart';
import 'main_shell.dart';

class CreatorProfileScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CreatorProfileScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends State<CreatorProfileScreen> {
  int _currentStep = 0;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _audienceController;
  late TextEditingController _contentStyleController;
  late TextEditingController _brandDescController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;

  String _niche = 'Technology';
  final String _category = 'Content Creator';
  String _tone = 'Educational';
  String _primaryLang = 'English';
  String _secondaryLang = 'Manglish';
  String _emojiUsage = 'moderate';
  String _ctaStyle = 'Direct';
  Color _primaryColor = const Color(0xFF6C5CE7);
  final Color _secondaryColor = const Color(0xFFA29BFE);

  final List<String> _niches = [
    'Technology',
    'Education & Students',
    'Food & Culinary',
    'Fashion & Style',
    'Fitness & Health',
    'Gaming & Esports',
    'Finance & Business',
    'Local Business & Retail',
    'Travel & Hospitality',
    'Entertainment',
    'Design & Art',
  ];

  final List<String> _tones = [
    'Educational',
    'Friendly',
    'Bold',
    'Casual',
    'Professional',
    'Funny',
    'Minimal',
    'Premium',
  ];

  final List<String> _languages = [
    'English',
    'Malayalam',
    'Manglish',
    'Hindi',
    'Tamil',
    'Telugu',
  ];

  final List<String> _ctaStyles = [
    'Direct',
    'Question',
    'Urgency',
    'Subtle',
  ];

  final List<String> _emojiOptions = [
    'none',
    'minimal',
    'moderate',
    'heavy',
  ];

  final List<Color> _brandColors = [
    const Color(0xFF6C5CE7), // Violet
    const Color(0xFFE4405F), // Crimson
    const Color(0xFF00B894), // Emerald
    const Color(0xFF0984E3), // Electric Blue
    const Color(0xFFE84393), // Pink
    const Color(0xFFFDCB6E), // Amber
    const Color(0xFF2D3436), // Graphite
  ];

  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.profile;

    _nameController = TextEditingController(text: profile.creatorName.isNotEmpty ? profile.creatorName : 'Joel G Jojo');
    _usernameController = TextEditingController(text: profile.username.isNotEmpty ? profile.username : '@joelgjojo');
    _audienceController = TextEditingController(text: profile.targetAudience.isNotEmpty ? profile.targetAudience : 'Creators, students, and small businesses');
    _contentStyleController = TextEditingController(text: profile.contentStyle.isNotEmpty ? profile.contentStyle : 'Short-form educational with a casual twist');
    _brandDescController = TextEditingController(text: profile.brandDescription.isNotEmpty ? profile.brandDescription : 'Building AI studio tools for modern creators');
    _websiteController = TextEditingController(text: profile.websiteUrl);
    _instagramController = TextEditingController(text: profile.instagramHandle.isNotEmpty ? profile.instagramHandle : '@joelgjojo');
    _youtubeController = TextEditingController(text: profile.youtubeHandle);

    if (profile.niche.isNotEmpty && _niches.contains(profile.niche)) _niche = profile.niche;
    if (profile.tone.isNotEmpty && _tones.contains(profile.tone)) _tone = profile.tone;
    if (profile.primaryLanguage.isNotEmpty) _primaryLang = profile.primaryLanguage;
    if (profile.secondaryLanguage.isNotEmpty) _secondaryLang = profile.secondaryLanguage;
    if (profile.emojiUsage.isNotEmpty) _emojiUsage = profile.emojiUsage;
    if (profile.preferredCTAStyle.isNotEmpty) _ctaStyle = profile.preferredCTAStyle;
    _primaryColor = profile.primaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _audienceController.dispose();
    _contentStyleController.dispose();
    _brandDescController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _saveAndProceed() async {
    AppHaptics.light();
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      final updatedProfile = CreatorProfile(
        creatorName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        niche: _niche,
        category: _category,
        targetAudience: _audienceController.text.trim(),
        primaryLanguage: _primaryLang,
        secondaryLanguage: _secondaryLang,
        tone: _tone,
        contentStyle: _contentStyleController.text.trim(),
        brandDescription: _brandDescController.text.trim(),
        preferredCTAStyle: _ctaStyle,
        emojiUsage: _emojiUsage,
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        websiteUrl: _websiteController.text.trim(),
        instagramHandle: _instagramController.text.trim(),
        youtubeHandle: _youtubeController.text.trim(),
      );

      await AppState.instance.updateProfile(updatedProfile);

      if (!mounted) return;
      if (widget.isInitialSetup) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand Memory updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  AppHaptics.selection();
                  setState(() => _currentStep--);
                },
              )
            : (widget.isInitialSetup
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  )),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Brand Memory',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
            ),
            Text(
              'Step ${_currentStep + 1} of 5',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (widget.isInitialSetup && _currentStep == 4)
            TextButton(
              onPressed: _saveAndProceed,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ClipRRect(
              borderRadius: AppRadius.rPill,
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                minHeight: 3,
                backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: _buildStepContent(isDark, primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: CDPrimaryButton(
                label: _currentStep < 4 ? 'Continue →' : (widget.isInitialSetup ? 'Complete Setup ✦' : 'Save Brand Changes'),
                isFullWidth: true,
                onPressed: _saveAndProceed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark, Color primaryColor) {
    switch (_currentStep) {
      case 0:
        return _buildStep0Identity(isDark, primaryColor);
      case 1:
        return _buildStep1AudienceTone(isDark, primaryColor);
      case 2:
        return _buildStep2Language(isDark, primaryColor);
      case 3:
        return _buildStep3BrandColors(isDark, primaryColor);
      case 4:
      default:
        return _buildStep4Socials(isDark, primaryColor);
    }
  }

  Widget _buildStep0Identity(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who are you creating for?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'CreateDiff will use this identity to tailor all future content packs.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        CDTextInput(
          label: 'Creator / Business Name',
          hint: 'e.g., TechWithJoel or Artisan Bakery',
          controller: _nameController,
          isRequired: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        CDTextInput(
          label: 'Username / Handle',
          hint: '@yourbrand',
          controller: _usernameController,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Select your niche',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _niches.map((n) {
            final isSelected = _niche == n;
            return ChoiceChip(
              label: Text(n),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _niche = n);
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep1AudienceTone(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Audience & Voice',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Help CreateDiff match your unique personality and audience expectations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        CDTextInput(
          label: 'Who is your target audience?',
          hint: 'e.g., College students, freelancers, foodies in Kerala...',
          controller: _audienceController,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Choose your default tone',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tones.map((t) {
            final isSelected = _tone == t;
            return ChoiceChip(
              label: Text(t),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _tone = t);
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        CDTextInput(
          label: 'Content Style / Description',
          hint: 'e.g., Short-form educational with actionable takeaways',
          controller: _contentStyleController,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildStep2Language(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language & Expression',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Support for regional languages and custom emoji density.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        Text(
          'Primary Language',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languages.map((l) {
            final isSelected = _primaryLang == l;
            return ChoiceChip(
              label: Text(l),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _primaryLang = l);
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Emoji Usage in Captions',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _emojiOptions.map((e) {
            final isSelected = _emojiUsage == e;
            return ChoiceChip(
              label: Text(e.toUpperCase()),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _emojiUsage = e);
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3BrandColors(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand Identity & Aesthetics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'These colors will be automatically applied to your visual designs.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        CDTextInput(
          label: 'Brand One-Liner Description',
          hint: 'What makes your content or business special?',
          controller: _brandDescController,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Call to Action (CTA) Preference',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ctaStyles.map((cta) {
            final isSelected = _ctaStyle == cta;
            return ChoiceChip(
              label: Text(cta),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _ctaStyle = cta);
              },
              selectedColor: primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Brand Accent Color',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _brandColors.map((color) {
            final isSelected = _primaryColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () {
                AppHaptics.selection();
                setState(() => _primaryColor = color);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2.5)
                      : Border.all(color: Colors.white38, width: 1),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep4Socials(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Channels (Optional)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Add your handles so they can be embedded in descriptions and visuals.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        CDTextInput(
          label: 'Instagram Handle',
          hint: '@yourinstagram',
          controller: _instagramController,
          prefixIcon: const Icon(Icons.camera_alt_outlined, size: 18),
        ),
        const SizedBox(height: AppSpacing.lg),
        CDTextInput(
          label: 'YouTube Channel',
          hint: '@youryoutube',
          controller: _youtubeController,
          prefixIcon: const Icon(Icons.play_circle_outline_rounded, size: 18),
        ),
        const SizedBox(height: AppSpacing.lg),
        CDTextInput(
          label: 'Website URL',
          hint: 'https://yoursite.com',
          controller: _websiteController,
          prefixIcon: const Icon(Icons.language_rounded, size: 18),
        ),
      ],
    );
  }
}
