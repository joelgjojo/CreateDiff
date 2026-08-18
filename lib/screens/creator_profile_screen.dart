import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/creator_profile.dart';
import '../models/creator_intelligence.dart';
import '../services/app_state.dart';
import '../components/cd_text_input.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_atmospheric_background.dart';
import '../components/cd_glass_card.dart';
import 'main_shell.dart';

/// Guided 5-step Brand Memory wizard with frosted glass cards and brand color palette picker.
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
  late TextEditingController _regionalContextController;
  late TextEditingController _langAudienceController;

  String _niche = 'Technology';
  final String _category = 'Content Creator';
  String _tone = 'Educational';
  String _primaryLang = 'English';
  String _secondaryLang = 'Manglish';
  String _languageStyle = 'Conversational';
  String _emojiUsage = 'moderate';
  String _ctaStyle = 'Direct';
  Color _primaryColor = CDColors.brand;
  final Color _secondaryColor = CDColors.lavender;
  List<String> _preferredPlatforms = ['Instagram', 'YouTube', 'LinkedIn'];
  List<String> _contentGoals = ['Audience Growth', 'Community Engagement'];

  final List<String> _languageStyles = [
    'Conversational',
    'Technical',
    'Professional',
    'Storytelling',
    'Witty & Energetic',
  ];

  final List<String> _platformOptions = [
    'Instagram',
    'YouTube',
    'LinkedIn',
    'TikTok',
    'Twitter / X',
  ];

  final List<String> _goalOptions = [
    'Audience Growth',
    'Authority Building',
    'Community Engagement',
    'Lead Generation',
    'Brand Awareness',
  ];

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
    CDColors.brand, // Official Blue-Violet (#4F43F9)
    const Color(0xFF7066FF), // Luminous Lavender Blue
    const Color(0xFF00B894), // Mint Green
    const Color(0xFFE4405F), // Crimson
    const Color(0xFF0984E3), // Electric Blue
    const Color(0xFFE84393), // Pink
    const Color(0xFFFFA502), // Amber
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
    if (profile.preferredPlatforms.isNotEmpty) _preferredPlatforms = List.from(profile.preferredPlatforms);
    if (profile.contentGoals.isNotEmpty) _contentGoals = List.from(profile.contentGoals);
    _primaryColor = profile.primaryColor;

    _regionalContextController = TextEditingController(text: profile.languageProfile.regionalContext);
    _langAudienceController = TextEditingController(
      text: profile.languageProfile.audienceType.isNotEmpty
          ? profile.languageProfile.audienceType
          : profile.targetAudience,
    );
    if (profile.languageProfile.preferredStyle.isNotEmpty &&
        _languageStyles.contains(profile.languageProfile.preferredStyle)) {
      _languageStyle = profile.languageProfile.preferredStyle;
    }
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
    _regionalContextController.dispose();
    _langAudienceController.dispose();
    super.dispose();
  }

  Future<void> _saveAndProceed() async {
    AppHaptics.light();
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      final updatedProfile = CreatorProfile(
        id: AppState.instance.profile.id,
        creatorName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        niche: _niche,
        category: _category,
        targetAudience: _audienceController.text.trim(),
        preferredPlatforms: _preferredPlatforms,
        primaryLanguage: _primaryLang,
        secondaryLanguage: _secondaryLang,
        tone: _tone,
        contentGoals: _contentGoals,
        contentStyle: _contentStyleController.text.trim(),
        brandDescription: _brandDescController.text.trim(),
        preferredCTAStyle: _ctaStyle,
        emojiUsage: _emojiUsage,
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        websiteUrl: _websiteController.text.trim(),
        instagramHandle: _instagramController.text.trim(),
        youtubeHandle: _youtubeController.text.trim(),
        languageProfile: LanguageProfile(
          language: _primaryLang,
          preferredStyle: _languageStyle,
          audienceType: _langAudienceController.text.trim().isNotEmpty
              ? _langAudienceController.text.trim()
              : 'General audience',
          regionalContext: _regionalContextController.text.trim(),
          communicationTone: _tone,
        ),
        creatorMemory: AppState.instance.profile.creatorMemory,
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
            transitionDuration: CDMotion.screen,
          ),
        );
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand Memory updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: CDColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0 && !widget.isInitialSetup,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentStep > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: CDColors.textPrimary(context)),
                  onPressed: () {
                    AppHaptics.selection();
                    setState(() => _currentStep--);
                  },
                )
              : (widget.isInitialSetup
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close_rounded, color: CDColors.textPrimary(context)),
                      onPressed: () => Navigator.of(context).pop(),
                    )),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brand Memory Studio',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: CDColors.textPrimary(context),
                    ),
              ),
              Text(
                'Step ${_currentStep + 1} of 5',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: CDColors.textSecondary(context),
                    ),
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
                    color: CDColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CDRadius.pill),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 5,
                  minHeight: 3,
                  backgroundColor: CDColors.borderSubtle(context),
                  valueColor: const AlwaysStoppedAnimation<Color>(CDColors.primary),
                ),
              ),
            ),
          ),
        ),
        body: CDAtmosphericBackground(
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(CDSpacing.lg),
                    child: _buildStepContent(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(CDSpacing.lg),
                  child: CDPrimaryButton(
                    label: _currentStep < 4 ? 'Continue →' : (widget.isInitialSetup ? 'Complete Setup ✦' : 'Save Brand Changes'),
                    isFullWidth: true,
                    height: 50,
                    onPressed: _saveAndProceed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep0Identity();
      case 1:
        return _buildStep1AudienceTone();
      case 2:
        return _buildStep2Language();
      case 3:
        return _buildStep3BrandColors();
      case 4:
      default:
        return _buildStep4Socials();
    }
  }

  Widget _buildStep0Identity() {
    final isDark = CDColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who are you creating for?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'CreateDiff uses this identity to tailor all future content packs.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textSecondary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.xl),
        CDGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CDTextInput(
                label: 'Creator / Business Name',
                hint: 'e.g., TechWithJoel or Artisan Bakery',
                controller: _nameController,
                isRequired: true,
              ),
              const SizedBox(height: CDSpacing.lg),
              CDTextInput(
                label: 'Username / Handle',
                hint: '@yourbrand',
                controller: _usernameController,
              ),
            ],
          ),
        ),
        const SizedBox(height: CDSpacing.xl),
        Text(
          'Select your niche',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
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
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep1AudienceTone() {
    final isDark = CDColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Audience & Voice',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Help CreateDiff match your unique personality, platforms, and audience expectations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textSecondary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.xl),

        // Preferred Platforms Multi-Select
        Text(
          'Preferred Platforms',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _platformOptions.map((p) {
            final isSelected = _preferredPlatforms.contains(p);
            return FilterChip(
              label: Text(p),
              selected: isSelected,
              onSelected: (selected) {
                AppHaptics.selection();
                setState(() {
                  if (selected) {
                    if (!_preferredPlatforms.contains(p)) _preferredPlatforms.add(p);
                  } else {
                    if (_preferredPlatforms.length > 1) _preferredPlatforms.remove(p);
                  }
                });
              },
              selectedColor: CDColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: CDSpacing.lg),

        // Content Goals Multi-Select
        Text(
          'Primary Content Goals',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _goalOptions.map((g) {
            final isSelected = _contentGoals.contains(g);
            return FilterChip(
              label: Text(g),
              selected: isSelected,
              onSelected: (selected) {
                AppHaptics.selection();
                setState(() {
                  if (selected) {
                    if (!_contentGoals.contains(g)) _contentGoals.add(g);
                  } else {
                    if (_contentGoals.length > 1) _contentGoals.remove(g);
                  }
                });
              },
              selectedColor: CDColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: CDSpacing.lg),

        CDGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CDTextInput(
                label: 'Who is your target audience?',
                hint: 'e.g., College students, freelancers, foodies in Kerala...',
                controller: _audienceController,
                maxLines: 2,
              ),
              const SizedBox(height: CDSpacing.lg),
              CDTextInput(
                label: 'Content Style / Description',
                hint: 'e.g., Short-form educational with actionable takeaways',
                controller: _contentStyleController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: CDSpacing.xl),
        Text(
          'Choose your default tone',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
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
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Language() {
    final isDark = CDColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language & Expression',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tailor vernacular intelligence, regional dialects, and delivery style.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textSecondary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.xl),

        // 1. Primary Language
        Text(
          'Primary Content Language',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
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
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: CDSpacing.lg),

        // 2. Language Delivery Style
        Text(
          'Preferred Delivery & Expression Style',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _languageStyles.map((style) {
            final isSelected = _languageStyle == style;
            return ChoiceChip(
              label: Text(style),
              selected: isSelected,
              onSelected: (_) {
                AppHaptics.selection();
                setState(() => _languageStyle = style);
              },
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: CDSpacing.lg),

        // 3. Regional Context & Audience Cards
        CDGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CDTextInput(
                label: 'Regional Context & Local Nuances',
                hint: 'e.g., Kerala tech & startup community, modern Manglish slang, South Asian creator references...',
                controller: _regionalContextController,
                maxLines: 2,
              ),
              const SizedBox(height: CDSpacing.md),
              CDTextInput(
                label: 'Target Regional Audience',
                hint: 'e.g., College students, developers, regional entrepreneurs...',
                controller: _langAudienceController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: CDSpacing.xl),

        // 4. Emoji Usage
        Text(
          'Emoji Usage in Captions',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
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
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3BrandColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand Identity & Aesthetics',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'These colors will be automatically applied to your visual designs.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textSecondary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.xl),
        CDGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CDTextInput(
                label: 'Brand One-Liner Description',
                hint: 'What makes your content or business special?',
                controller: _brandDescController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: CDSpacing.xl),
        Text(
          'Call to Action (CTA) Preference',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
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
              selectedColor: CDColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : CDColors.textPrimary(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
              backgroundColor: CDColors.isDark(context)
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.pill)),
              side: BorderSide(
                color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: CDSpacing.xl),
        Text(
          'Brand Accent Palette',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _brandColors.map((color) {
              final isSelected = _primaryColor.toARGB32() == color.toARGB32();
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _primaryColor = color);
                  },
                  child: AnimatedContainer(
                    duration: CDMotion.micro,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: CDColors.isDark(context) ? Colors.white : Colors.black, width: 2.5)
                          : Border.all(color: CDColors.borderSubtle(context), width: 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.45),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Socials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Channels (Optional)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: CDColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add your handles so they can be embedded in descriptions and visuals.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CDColors.textSecondary(context),
              ),
        ),
        const SizedBox(height: CDSpacing.xl),
        CDGlassCard(
          child: Column(
            children: [
              CDTextInput(
                label: 'Instagram Handle',
                hint: '@yourinstagram',
                controller: _instagramController,
                prefixIcon: Icon(Icons.camera_alt_outlined, size: 18, color: CDColors.textSecondary(context)),
              ),
              const SizedBox(height: CDSpacing.lg),
              CDTextInput(
                label: 'YouTube Channel',
                hint: '@youryoutube',
                controller: _youtubeController,
                prefixIcon: Icon(Icons.play_circle_outline_rounded, size: 18, color: CDColors.textSecondary(context)),
              ),
              const SizedBox(height: CDSpacing.lg),
              CDTextInput(
                label: 'Website URL',
                hint: 'https://yoursite.com',
                controller: _websiteController,
                prefixIcon: Icon(Icons.language_rounded, size: 18, color: CDColors.textSecondary(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
