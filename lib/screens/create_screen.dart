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
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  String? _selectedPlatform;
  String? _selectedContentType;
  
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _toneController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  final Map<String, List<Map<String, dynamic>>> _contentTypes = {
    'Instagram': [
      {'type': 'Reel', 'icon': Icons.movie_filter_rounded},
      {'type': 'Post', 'icon': Icons.grid_on_rounded},
      {'type': 'Story', 'icon': Icons.amp_stories_rounded},
      {'type': 'Carousel', 'icon': Icons.view_carousel_rounded},
    ],
    'YouTube': [
      {'type': 'Video', 'icon': Icons.play_circle_fill_rounded},
      {'type': 'Short', 'icon': Icons.bolt_rounded},
    ],
    'LinkedIn': [
      {'type': 'Post', 'icon': Icons.work_rounded},
      {'type': 'Article', 'icon': Icons.article_rounded},
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedPlatform = widget.initialPlatform;
    _selectedContentType = widget.initialContentType;
    if (widget.initialIdea != null) {
      _ideaController.text = widget.initialIdea!;
    }
    
    if (_selectedPlatform != null || widget.initialIdea != null) {
      _selectedPlatform ??= 'Instagram';
      _selectedContentType ??= 'Reel';
      _currentStep = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(1);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ideaController.dispose();
    _toneController.dispose();
    _targetAudienceController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedPlatform == null || _selectedContentType == null) return;
      AppHaptics.light();
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: CDMotion.standard,
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      AppHaptics.light();
      setState(() => _currentStep = 0);
      _pageController.previousPage(
        duration: CDMotion.standard,
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleGenerate() async {
    final idea = _ideaController.text.trim();
    if (idea.isEmpty) return;

    AppHaptics.selection();
    FocusScope.of(context).unfocus();

    final appState = AppState.instance;
    await appState.generateContentPack(
      platform: _selectedPlatform!,
      contentType: _selectedContentType!,
      idea: idea,
      tone: _toneController.text.trim(),
    );

    if (mounted && appState.currentProject != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ContentResultScreen(
            project: appState.currentProject!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isGenerating = appState.isGenerating;

        return Scaffold(
          backgroundColor: CDColors.surface(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: _prevStep,
            ),
            title: Text(
              _currentStep == 0 ? 'Choose Format' : 'Add Detail',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: isDark ? CDColors.darkMuted.withValues(alpha: 0.2) : CDColors.lightMuted.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(CDColors.primary),
                    minHeight: 2,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep0Format(isDark),
                        _buildStep1Idea(isDark),
                      ],
                    ),
                  ),
                ],
              ),
              if (isGenerating)
                const CDLoadingState(currentMessage: 'Generating your content pack...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep0Format(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Platform',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: CDSpacing.md),
          CDPlatformSelector(
            platforms: const ['Instagram', 'YouTube', 'LinkedIn'],
            selectedPlatform: _selectedPlatform ?? '',
            onPlatformSelected: (val) {
              setState(() {
                _selectedPlatform = val;
                _selectedContentType = null;
              });
              AppHaptics.selection();
            },
          ),
          const SizedBox(height: CDSpacing.xl),
          if (_selectedPlatform != null) ...[
            Text(
              'Content Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: CDSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: CDSpacing.md,
                mainAxisSpacing: CDSpacing.md,
                childAspectRatio: 1.2,
              ),
              itemCount: _contentTypes[_selectedPlatform!]!.length,
              itemBuilder: (context, index) {
                final typeData = _contentTypes[_selectedPlatform!]![index];
                return CDContentTypeCard(
                  label: typeData['type'] as String,
                  description: 'Create a ${typeData['type']}',
                  icon: typeData['icon'] as IconData,
                  isSelected: _selectedContentType == typeData['type'],
                  onTap: () {
                    setState(() {
                      _selectedContentType = typeData['type'] as String;
                    });
                    AppHaptics.selection();
                  },
                );
              },
            ),
            const SizedBox(height: CDSpacing.xl),
            CDPrimaryButton(
              label: 'Next Step',
              onPressed: _selectedContentType != null ? _nextStep : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1Idea(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(CDSpacing.md),
            decoration: BoxDecoration(
              color: CDColors.elevated(context),
              borderRadius: BorderRadius.circular(CDRadius.medium),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: CDColors.primary,
                ),
                const SizedBox(width: CDSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedPlatform • $_selectedContentType',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Describe what you want to create.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? CDColors.darkMuted : CDColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: CDSpacing.xl),
          CDTextInput(
            controller: _ideaController,
            label: 'Core Idea',
            hint: 'E.g., 5 AI tools for creators, behind the scenes of my workspace...',
            maxLines: 5,
            minLines: 3,
            
          ),
          const SizedBox(height: CDSpacing.md),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                'Fine-Tune (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: CDSpacing.md),
              onExpansionChanged: (expanded) {
                AppHaptics.selection();
              },
              children: [
                CDTextInput(
                  controller: _toneController,
                  label: 'Tone',
                  hint: 'E.g., Professional, humorous, educational',
                ),
                const SizedBox(height: CDSpacing.md),
                CDTextInput(
                  controller: _targetAudienceController,
                  label: 'Target Audience',
                  hint: 'E.g., Beginners, designers, marketers',
                ),
                const SizedBox(height: CDSpacing.md),
                CDTextInput(
                  controller: _keywordsController,
                  label: 'Keywords',
                  hint: 'E.g., productivity, tips, setup',
                ),
              ],
            ),
          ),
          const SizedBox(height: CDSpacing.xl),
          CDPrimaryButton(
            label: 'Generate Content Pack ✦',
            onPressed: _handleGenerate,
          ),
        ],
      ),
    );
  }
}
