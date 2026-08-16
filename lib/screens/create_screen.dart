import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_platform_selector.dart';
import '../components/cd_content_type_card.dart';
import '../components/cd_text_input.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_loading_state.dart';
import '../components/cd_atmospheric_background.dart';
import 'content_result_screen.dart';
import 'debug_panel_screen.dart';

/// Guided 2-step studio creation flow with frosted glass cards and generation overlay.
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
        duration: CDMotion.screen,
        curve: CDMotion.defaultCurve,
      );
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      AppHaptics.light();
      setState(() => _currentStep = 0);
      _pageController.previousPage(
        duration: CDMotion.screen,
        curve: CDMotion.defaultCurve,
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
    final project = await appState.generateContentPack(
      platform: _selectedPlatform!,
      contentType: _selectedContentType!,
      idea: idea,
      tone: _toneController.text.trim(),
    );

    if (mounted) {
      if (project != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ContentResultScreen(
              project: project,
            ),
          ),
        );
      } else if (appState.lastError != null) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.lastError!.message),
            backgroundColor: CDColors.error,
            action: SnackBarAction(
              label: 'Debug',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DebugPanelScreen()),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isGenerating = appState.isGenerating;
        final error = appState.lastError;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: CDColors.textPrimary(context),
              ),
              onPressed: _prevStep,
            ),
            title: Text(
              _currentStep == 0 ? 'Choose Format' : 'Studio Canvas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report_outlined, size: 20),
                tooltip: 'Debug Panel',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DebugPanelScreen()),
                  );
                },
              ),
            ],
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(CDRadius.pill),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: CDColors.borderSubtle(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(CDColors.brand),
                    minHeight: 3,
                  ),
                ),
              ),
            ),
          ),
          body: CDAtmosphericBackground(
            child: Stack(
              children: [
                SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      // Error Banner if generation failed
                      if (error != null && !isGenerating)
                        Container(
                          margin: const EdgeInsets.fromLTRB(CDSpacing.lg, CDSpacing.sm, CDSpacing.lg, 0),
                          padding: const EdgeInsets.all(CDSpacing.md),
                          decoration: BoxDecoration(
                            color: CDColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(CDRadius.medium),
                            border: Border.all(
                              color: CDColors.error.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: CDColors.error, size: 20),
                              const SizedBox(width: CDSpacing.sm),
                              Expanded(
                                child: Text(
                                  error.message,
                                  style: const TextStyle(
                                    color: CDColors.error,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStep0Format(),
                            _buildStep1Idea(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isGenerating)
                  CDLoadingState(currentMessage: appState.generationStep),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep0Format() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Platform',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: CDColors.textPrimary(context),
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
          const SizedBox(height: CDSpacing.xxl),
          if (_selectedPlatform != null) ...[
            Text(
              'Content Format',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: CDColors.textPrimary(context),
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
                childAspectRatio: 1.25,
              ),
              itemCount: _contentTypes[_selectedPlatform!]!.length,
              itemBuilder: (context, index) {
                final typeData = _contentTypes[_selectedPlatform!]![index];
                return CDContentTypeCard(
                  label: typeData['type'] as String,
                  description: 'Personalized ${typeData['type']}',
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
            const SizedBox(height: CDSpacing.xxl),
            CDPrimaryButton(
              label: 'Continue to Canvas →',
              isFullWidth: true,
              height: 50,
              onPressed: _selectedContentType != null ? _nextStep : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1Idea() {
    final isDark = CDColors.isDark(context);

    final glassGradient = isDark
        ? CDColors.darkGlassGradient
        : CDColors.lightGlassGradient;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(CDSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format pill indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: glassGradient,
              borderRadius: BorderRadius.circular(CDRadius.medium),
              border: Border.all(
                color: isDark ? CDColors.darkBorderSubtle : CDColors.lightBorderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CDColors.brand.withValues(alpha: isDark ? 0.20 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: CDColors.brand,
                    size: 16,
                  ),
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
                          fontWeight: FontWeight.w700,
                          color: CDColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        'Describe what you want to create.',
                        style: TextStyle(
                          fontSize: 12,
                          color: CDColors.textSecondary(context),
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
            label: 'Core Idea or Topic',
            hint: 'E.g., 5 AI tools for creators, behind the scenes of my workspace, mindset shift for 2026...',
            maxLines: 5,
            minLines: 3,
          ),
          const SizedBox(height: CDSpacing.md),

          // Collapsible Fine-Tune wrapped in Material
          Material(
            color: Colors.transparent,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  'Fine-Tune Parameters (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CDColors.textPrimary(context),
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: CDSpacing.sm),
                onExpansionChanged: (expanded) {
                  AppHaptics.selection();
                },
                children: [
                  CDTextInput(
                    controller: _toneController,
                    label: 'Tone of Voice',
                    hint: 'E.g., Punchy, professional, humorous, educational',
                  ),
                  const SizedBox(height: CDSpacing.md),
                  CDTextInput(
                    controller: _targetAudienceController,
                    label: 'Target Audience',
                    hint: 'E.g., Beginners, senior designers, marketers',
                  ),
                  const SizedBox(height: CDSpacing.md),
                  CDTextInput(
                    controller: _keywordsController,
                    label: 'Key Focus Keywords',
                    hint: 'E.g., productivity, revenue, creator economy',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: CDSpacing.xxl),

          CDPrimaryButton(
            label: 'Generate Studio Content Pack ✦',
            isFullWidth: true,
            height: 52,
            onPressed: _handleGenerate,
          ),
        ],
      ),
    );
  }
}
