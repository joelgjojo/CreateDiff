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

  const CreateScreen({
    super.key,
    this.initialPlatform,
    this.initialContentType,
  });

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int _currentStep = 0;
  late String _selectedPlatform;
  String _selectedContentType = 'Reel';
  final TextEditingController _ideaController = TextEditingController();

  bool _showFineTune = false;
  late String _selectedLanguage;
  late String _selectedTone;
  String _selectedLength = 'Medium';

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

  final List<String> _lengths = ['Short', 'Medium', 'Long'];

  @override
  void initState() {
    super.initState();
    final profile = AppState.instance.profile;
    _selectedPlatform = widget.initialPlatform ?? 'Instagram';
    _selectedContentType = widget.initialContentType ?? _getDefaultTypeForPlatform(_selectedPlatform);
    _selectedLanguage = profile.primaryLanguage.isNotEmpty ? profile.primaryLanguage : 'English';
    _selectedTone = profile.tone.isNotEmpty ? profile.tone : 'Educational';

    if (widget.initialPlatform != null) {
      _currentStep = 1; // Jump directly to idea input if platform was preselected from Home quick action
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
          content: Text('Please describe your content idea first'),
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
      length: _selectedLength,
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
                if (_currentStep > 0 && widget.initialPlatform == null) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              _currentStep == 0 ? 'Choose Format' : 'Describe Idea',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                  ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkAccent3 : AppColors.accent3,
                      borderRadius: AppRadius.rPill,
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of 2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
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
                          label: 'Continue',
                          isFullWidth: true,
                          onPressed: () => setState(() => _currentStep = 1),
                        )
                      : CDPrimaryButton(
                          label: 'Create Content ✦',
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
          'What are you publishing?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Select platform and content format to optimize output structure.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl2),
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
        const SizedBox(height: AppSpacing.xl2),
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.12,
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
          {'type': 'video', 'label': 'Video', 'icon': Icons.play_circle_fill_rounded, 'desc': 'Long-form video script & breakdown'},
          {'type': 'short', 'label': 'Short', 'icon': Icons.short_text_rounded, 'desc': 'High-retention vertical short'},
          {'type': 'community', 'label': 'Community', 'icon': Icons.forum_rounded, 'desc': 'Engaging poll or text post'},
        ];
      case 'linkedin':
        return [
          {'type': 'post', 'label': 'Post', 'icon': Icons.article_rounded, 'desc': 'Actionable professional framework'},
          {'type': 'story', 'label': 'Story', 'icon': Icons.lightbulb_outline_rounded, 'desc': 'Personal founder lesson & story'},
          {'type': 'article', 'label': 'Article', 'icon': Icons.description_outlined, 'desc': 'Deep-dive industry analysis'},
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
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platform & Format Summary Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent1 : AppColors.accent1,
            borderRadius: AppRadius.rPill,
            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 13, color: primaryColor),
              const SizedBox(width: 5),
              Text(
                '$_selectedPlatform $_selectedContentType',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'What\'s your content about?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Just describe your idea in natural words. CreateDiff handles the prompt and formatting.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl2),
        CDTextInput(
          hint: 'e.g., 5 AI tools every college student should know to save 10 hours a week...',
          controller: _ideaController,
          maxLines: 5,
          minLines: 4,
        ),
        const SizedBox(height: AppSpacing.xl2),

        // Collapsible Fine-Tune Section
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _showFineTune = !_showFineTune),
            borderRadius: AppRadius.rMedium,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    _showFineTune ? Icons.tune_rounded : Icons.tune_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Fine-tune controls (optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showFineTune ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 20,
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
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                borderRadius: AppRadius.rLarge,
                border: Border.all(
                  color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkAccent3 : AppColors.accent3,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tone',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
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
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkAccent3 : AppColors.accent3,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Length',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _lengths.map((len) {
                      final isSelected = _selectedLength == len;
                      return ChoiceChip(
                        label: Text(len),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedLength = len),
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        backgroundColor: isDark ? AppColors.darkAccent3 : AppColors.accent3,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: _showFineTune ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}
