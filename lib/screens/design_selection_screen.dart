import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../models/design_template.dart';
import '../services/app_state.dart';
import '../components/cd_design_template_card.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_export_share_sheet.dart';
import '../components/cd_empty_state.dart';
import '../components/cd_atmospheric_background.dart';

/// The creative design gallery screen displaying visual layouts for the active project.
class DesignSelectionScreen extends StatefulWidget {
  final ContentProject? project;

  const DesignSelectionScreen({
    super.key,
    this.project,
  });

  @override
  State<DesignSelectionScreen> createState() => _DesignSelectionScreenState();
}

class _DesignSelectionScreenState extends State<DesignSelectionScreen> {
  String _selectedStyleFilter = 'All';
  int _selectedIndex = 0;

  final List<DesignTemplate> _templates = const [
    DesignTemplate(
      id: 'clean_editorial',
      name: 'Clean Editorial',
      style: 'editorial',
      description: 'Generous margins and high-contrast editorial typography',
    ),
    DesignTemplate(
      id: 'bold_typography',
      name: 'Bold Typography',
      style: 'bold',
      description: 'Full-bleed brand accent with heavy header weight',
    ),
    DesignTemplate(
      id: 'swiss_grid',
      name: 'Swiss Grid',
      style: 'minimal',
      description: 'Structured asymmetric grid with precise rule lines',
    ),
    DesignTemplate(
      id: 'creator_minimal',
      name: 'Creator Minimal',
      style: 'minimal',
      description: 'Atmospheric neutral background with subtle typography focus',
    ),
    DesignTemplate(
      id: 'dark_impact',
      name: 'Dark Impact',
      style: 'bold',
      description: 'Deep obsidian background with glowing brand accent rule',
    ),
    DesignTemplate(
      id: 'luxury_editorial',
      name: 'Luxury Editorial',
      style: 'premium',
      description: 'Refined dark tone with gold/amber framing',
    ),
    DesignTemplate(
      id: 'soft_modern',
      name: 'Soft Modern',
      style: 'editorial',
      description: 'Soft gradient tone with structured modern hierarchy',
    ),
    DesignTemplate(
      id: 'high_contrast',
      name: 'High Contrast',
      style: 'bold',
      description: 'Stark black and white punchy typographic poster layout',
    ),
  ];

  final List<String> _filters = ['All', 'Minimal', 'Bold', 'Editorial', 'Premium'];

  List<DesignTemplate> get _filteredTemplates {
    if (_selectedStyleFilter == 'All') return _templates;
    return _templates
        .where((t) => t.style.toLowerCase() == _selectedStyleFilter.toLowerCase())
        .toList();
  }

  void _onUseDesign(ContentProject proj) {
    AppHaptics.light();
    final chosen = _templates[_selectedIndex];
    AppState.instance.updateCurrentProjectDesign(
      templateName: chosen.name,
      style: chosen.style,
    );

    CDExportShareSheet.show(
      context,
      project: proj.copyWith(
        selectedDesignTemplate: chosen.name,
        selectedDesignStyle: chosen.style,
        status: 'designed',
      ),
      onDone: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CDColors.isDark(context);
    final activeProject = widget.project ?? AppState.instance.currentProject;

    if (activeProject == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: CDAtmosphericBackground(
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Design Studio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: CDColors.textPrimary(context),
                        ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: CDSpacing.navBarClearance),
                    child: CDEmptyState(
                      icon: Icons.palette_outlined,
                      title: 'No Active Content Project',
                      message: 'Create or select a content project first to explore design templates.',
                      actionLabel: 'Go Back',
                      onAction: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final appState = AppState.instance;
    final profile = appState.profile;
    final coverText = activeProject.generatedContent?.coverText ?? activeProject.idea;
    final filtered = _filteredTemplates;
    final bool isModal = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CDAtmosphericBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: isModal
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: CDColors.textPrimary(context)),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Design Direction',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: CDColors.textPrimary(context),
                          ),
                    ),
                    Text(
                      activeProject.platform,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CDColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      AppHaptics.selection();
                      CDExportShareSheet.show(
                        context,
                        project: activeProject,
                        onDone: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: CDColors.textSecondary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              // Filter Chips Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: CDSpacing.xs),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedStyleFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: CDSpacing.sm),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            AppHaptics.selection();
                            setState(() => _selectedStyleFilter = filter);
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
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // 2-Column Template Grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    left: CDSpacing.lg,
                    right: CDSpacing.lg,
                    top: CDSpacing.md,
                    bottom: !isModal ? CDSpacing.navBarClearance : CDSpacing.lg,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final template = filtered[index];
                    final realIndex = _templates.indexOf(template);
                    final isSelected = _selectedIndex == realIndex;

                    return CDDesignTemplateCard(
                      template: template,
                      coverText: coverText,
                      profile: profile,
                      isSelected: isSelected,
                      onSelect: () {
                        AppHaptics.selection();
                        setState(() => _selectedIndex = realIndex);
                      },
                    );
                  },
                ),
              ),
              // Bottom Action Button
              Container(
                padding: EdgeInsets.only(
                  left: CDSpacing.lg,
                  right: CDSpacing.lg,
                  top: 12,
                  bottom: isModal ? 12 + MediaQuery.of(context).padding.bottom : 12,
                ),
                decoration: BoxDecoration(
                  color: CDColors.surface(context),
                  border: Border(
                    top: BorderSide(
                      color: CDColors.borderSubtle(context),
                      width: 1.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  bottom: isModal,
                  child: CDPrimaryButton(
                    label: 'Use ${_templates[_selectedIndex].name} Layout ✦',
                    height: 48,
                    isFullWidth: true,
                    onPressed: () => _onUseDesign(activeProject),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
