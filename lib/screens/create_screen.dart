import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_platform_selector.dart';
import '../components/cd_content_type_card.dart';
import '../components/cd_text_input.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_loading_state.dart';
import 'content_result_screen.dart';

class CreateScreen extends StatefulWidget {
  final String? initialPlatform;
  final String? initialContentType;
  final String? initialIdea;

  const CreateScreen({
    super.key,
    this.initialPlatform,
    this.initialContentType,
    this.initialIdea,
  });

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int _currentStep = 0;
  late String _selectedPlatform;
  String _selectedContentType = 'Reel';
  late TextEditingController _ideaController;

  bool _showFineTune = false;
  late String _selectedLanguage;
  late String _selectedTone;
  late String _selectedCTAStyle;
  late String _selectedEmojiUsage;

  final List<String> _platforms = ['Instagram', 'YouTube', 'LinkedIn'];

  final List<String> _tones = [
    'Educational',
    'Friendly',
    'Bold',
    'Casual',
    'Professional',
    'Funny',
    'Minimal',
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

  final List<String> _emojiLevels = [
    'none',
    'minimal',
    'moderate',
    'heavy',
  ];

  final List<String> _suggestionChips = [
    '5 AI tools students should know',
    'Launch announcement for our cafe',
    '3 productivity tips for creators',
    'Mistakes I made in my 20s',
    'Step-by-step workflow breakdown',
    'Behind the scenes of our project',
  ];

  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.profile;
    _selectedPlatform = widget.initialPlatform ?? 'Instagram';
    _selectedContentType = widget.initialContentType ?? _getDefaultTypeForPlatform(_selectedPlatform);
    _ideaController = TextEditingController(text: widget.initialIdea ?? '');

    _selectedLanguage = profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English';
    _selectedTone = profile.tone.isNotEmpty ? profile.tone : 'Educational';
    _selectedCTAStyle = profile.preferredCTAStyle.isNotEmpty ? profile.preferredCTAStyle : 'Direct';
    _selectedEmojiUsage = profile.emojiUsage.isNotEmpty ? profile.emojiUsage : 'moderate';

    if (widget.initialPlatform != null || (widget.initialIdea != null && widget.initialIdea!.isNotEmpty)) {
      _currentStep = 1;
    }
  }

  String _getDefaultTypeForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return 'Video';
      case 'linkedin':
        return 'Post';
      case 'instagram':
      default:
        return 'Reel';
    }
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final idea = _ideaController.text.trim();
    if (idea.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe what you want to create'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final appState = AppState.instance;
    final project = await appState.generateContentPack(
      platform: _selectedPlatform,
      contentType: _selectedContentType,
      idea: idea,
      tone: _selectedTone,
      language: _selectedLanguage,
    );

    if (!mounted) return;

    if (project != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ContentResultScreen(project: project),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not generate content pack. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = AppState.instance;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (_currentStep > 0 && widget.initialPlatform == null && widget.initialIdea == null) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              _currentStep == 0 ? 'Choose Platform & Format' : 'What\'s the idea?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of 2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _currentStep == 0
                        ? _buildStep0FormatSelection(isDark)
                        : _buildStep1IdeaInput(isDark),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: _currentStep == 0
                      ? CDPrimaryButton(
                          label: 'Continue to Idea →',
                          isFullWidth: true,
                          onPressed: () => setState(() => _currentStep = 1),
                        )
                      : CDPrimaryButton(
                          label: 'Create Content Pack ✦',
                          isFullWidth: true,
                          onPressed: _handleGenerate,
                        ),
                ),
              ],
            ),
          ),
        ),
        // Generation loading overlay
        if (appState.isGenerating)
          CDLoadingState(
            currentMessage: appState.generationStep,
          ),
      ],
    );
  }

  Widget _buildStep0FormatSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select platform & format',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'CreateDiff structures your hook, caption length, and layout specifically for each format.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        CDPlatformSelector(
          platforms: _platforms,
          selectedPlatform: _selectedPlatform,
          onPlatformSelected: (p) {
            setState(() {
              _selectedPlatform = p;
              _selectedContentType = _getDefaultTypeForPlatform(p);
            });
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildContentTypeGrid(),
      ],
    );
  }

  Widget _buildContentTypeGrid() {
    final List<Map<String, dynamic>> types = _getContentTypesForPlatform(_selectedPlatform);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final t = types[index];
        final isSelected = _selectedContentType.toLowerCase() == (t['type'] as String).toLowerCase();
        return CDContentTypeCard(
          icon: t['icon'] as IconData,
          label: t['label'] as String,
          description: t['desc'] as String,
          isSelected: isSelected,
          onTap: () {
            setState(() => _selectedContentType = t['label'] as String);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getContentTypesForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return [
          {'type': 'video', 'label': 'Video', 'icon': Icons.play_circle_fill_rounded, 'desc': 'Long-form breakdown & timestamps'},
          {'type': 'short', 'label': 'Short', 'icon': Icons.short_text_rounded, 'desc': 'Fast vertical short hook & script'},
          {'type': 'community', 'label': 'Community', 'icon': Icons.forum_rounded, 'desc': 'Engaging subscriber post'},
        ];
      case 'linkedin':
        return [
          {'type': 'post', 'label': 'Post', 'icon': Icons.article_rounded, 'desc': 'Actionable professional framework'},
          {'type': 'story', 'label': 'Story', 'icon': Icons.lightbulb_outline_rounded, 'desc': 'Personal founder lesson & story'},
          {'type': 'article', 'label': 'Article', 'icon': Icons.description_outlined, 'desc': 'In-depth industry analysis'},
        ];
      case 'instagram':
      default:
        return [
          {'type': 'reel', 'label': 'Reel', 'icon': Icons.movie_filter_rounded, 'desc': 'Viral hook & short-form pacing'},
          {'type': 'post', 'label': 'Post', 'icon': Icons.grid_on_rounded, 'desc': 'Clean visual post & deep caption'},
          {'type': 'story', 'label': 'Story', 'icon': Icons.amp_stories_rounded, 'desc': 'Conversational 24-hr sequence'},
          {'type': 'carousel', 'label': 'Carousel', 'icon': Icons.view_carousel_rounded, 'desc': 'Multi-slide educational swipe'},
        ];
    }
  }

  Widget _buildStep1IdeaInput(bool isDark) {
    final primaryColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target format badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                borderRadius: AppRadius.rPill,
                border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 12, color: primaryColor),
                  const SizedBox(width: 5),
                  Text(
                    '$_selectedPlatform $_selectedContentType',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Change Format', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'What do you want to create?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Describe your idea naturally. CreateDiff turns it into structured, ready-to-post content.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        CDTextInput(
          hint: 'e.g. 5 AI tools every college student should know to save 10 hours a week...',
          controller: _ideaController,
          maxLines: 4,
          minLines: 3,
        ),
        const SizedBox(height: AppSpacing.md),

        // Idea inspiration chips
        Text(
          'Quick idea starters',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _suggestionChips.map((chip) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  setState(() => _ideaController.text = chip);
                },
                borderRadius: AppRadius.rPill,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
                    borderRadius: AppRadius.rPill,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '+ $chip',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Collapsible Fine-Tune Section
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              AppHaptics.selection();
              setState(() => _showFineTune = !_showFineTune);
            },
            borderRadius: AppRadius.rMedium,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Fine-tune parameters (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showFineTune ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface1 : AppColors.lightSurface,
                borderRadius: AppRadius.rMedium,
                border: Border.all(
                  color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _languages.map((l) {
                      final isSelected = _selectedLanguage == l;
                      return ChoiceChip(
                        label: Text(l),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLanguage = l),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tone of voice',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tones.map((t) {
                      final isSelected = _selectedTone == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedTone = t),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Call to Action (CTA) Style',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _ctaStyles.map((cta) {
                      final isSelected = _selectedCTAStyle == cta;
                      return ChoiceChip(
                        label: Text(cta),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedCTAStyle = cta),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Emoji Density',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _emojiLevels.map((lvl) {
                      final isSelected = _selectedEmojiUsage == lvl;
                      return ChoiceChip(
                        label: Text(lvl.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedEmojiUsage = lvl),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkSurface2 : AppColors.lightSecondarySurface,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: _showFineTune ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
