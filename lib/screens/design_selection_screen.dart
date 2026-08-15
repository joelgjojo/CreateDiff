import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../models/design_template.dart';
import '../services/app_state.dart';
import '../components/cd_design_template_card.dart';
import '../components/cd_primary_button.dart';
import '../components/cd_export_share_sheet.dart';

class DesignSelectionScreen extends StatefulWidget {
  final ContentProject project;

  const DesignSelectionScreen({
    super.key,
    required this.project,
  });

  @override
  State<DesignSelectionScreen> createState() => _DesignSelectionScreenState();
}

class _DesignSelectionScreenState extends State<DesignSelectionScreen> {
  String _selectedStyleFilter = 'All';
  int _selectedIndex = 0;

  final List<DesignTemplate> _templates = const [
    DesignTemplate(
      id: 'clean_type',
      name: 'Clean Type',
      style: 'minimal',
      description: 'High-contrast typography with spacious margins',
    ),
    DesignTemplate(
      id: 'bold_statement',
      name: 'Bold Statement',
      style: 'bold',
      description: 'Full-bleed brand accent with heavy header weight',
    ),
    DesignTemplate(
      id: 'editorial',
      name: 'Editorial',
      style: 'premium',
      description: 'Sophisticated publication-style layout with side rules',
    ),
    DesignTemplate(
      id: 'gradient_type',
      name: 'Gradient Type',
      style: 'minimal',
      description: 'Subtle atmospheric gradient with centered typographic focus',
    ),
    DesignTemplate(
      id: 'impact',
      name: 'Impact Dark',
      style: 'bold',
      description: 'Deep graphite background with glowing neon accent rule',
    ),
    DesignTemplate(
      id: 'luxe',
      name: 'Luxe Minimal',
      style: 'premium',
      description: 'Refined dark tone with gold/amber framing',
    ),
  ];

  final List<String> _filters = ['All', 'Minimal', 'Bold', 'Premium'];

  List<DesignTemplate> get _filteredTemplates {
    if (_selectedStyleFilter == 'All') return _templates;
    return _templates
        .where((t) => t.style.toLowerCase() == _selectedStyleFilter.toLowerCase())
        .toList();
  }

  void _onUseDesign() {
    final chosen = _templates[_selectedIndex];
    AppState.instance.updateCurrentProjectDesign(
      templateName: chosen.name,
      style: chosen.style,
    );

    CDExportShareSheet.show(
      context,
      project: widget.project.copyWith(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final appState = AppState.instance;
    final profile = appState.profile;
    final coverText = widget.project.generatedContent?.coverText ?? widget.project.idea;

    final filtered = _filteredTemplates;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Choose Design Direction',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              CDExportShareSheet.show(
                context,
                project: widget.project,
                onDone: () => Navigator.of(context).popUntil((route) => route.isFirst),
              );
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedStyleFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedStyleFilter = filter),
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? AppColors.darkPrimaryText : AppColors.primaryText),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.cardSurface,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.rPill),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 2-Column Template Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                  onSelect: () => setState(() => _selectedIndex = realIndex),
                );
              },
            ),
          ),
          // Bottom Primary Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceElevated,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkGlassBorder : AppColors.glassBorder,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: CDPrimaryButton(
                label: 'Use ${_templates[_selectedIndex].name} Design ✦',
                isFullWidth: true,
                onPressed: _onUseDesign,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
