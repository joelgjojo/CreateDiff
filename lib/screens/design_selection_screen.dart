import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../models/design_template.dart';
import '../services/app_state.dart';
import '../components/cd_design_template_card.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_export_share_sheet.dart';
import '../components/cd_empty_state.dart';

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
    final activeProject = widget.project ?? AppState.instance.currentProject;

    if (activeProject == null) {
      return Scaffold(
        backgroundColor: CDColors.background(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Design Selection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: CDColors.textPrimary(context),
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: CDSpacing.navBarClearance),
          child: CDEmptyState(
            icon: Icons.palette_outlined,
            title: 'No Project Selected',
            message: 'Create or select a content project first to explore design templates.',
            actionLabel: 'Go Back',
            onAction: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
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
      backgroundColor: CDColors.background(context),
      appBar: AppBar(
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
                    fontWeight: FontWeight.w700,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            Text(
              activeProject.platform, // Match project platform visually
              style: TextStyle(
                fontSize: 12,
                color: CDColors.primary,
                fontWeight: FontWeight.w600,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl, vertical: CDSpacing.xs),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      backgroundColor: CDColors.surface(context),
                      shape: RoundedRectangleBorder(borderRadius: CDRadius.rPill),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : CDColors.borderSubtle(context),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 2-Column Premium Template Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.only(
                left: CDSpacing.lg,
                right: CDSpacing.lg,
                top: CDSpacing.lg,
                bottom: !isModal ? CDSpacing.navBarClearance : CDSpacing.lg,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
          // Bottom Primary Button
          Container(
            padding: EdgeInsets.only(
              left: CDSpacing.xl,
              right: CDSpacing.xl,
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
            ),
            child: SafeArea(
              top: false,
              bottom: isModal, // Only apply safe area bottom if modal
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
    );
  }
}
