import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../services/app_state.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_empty_state.dart';
import '../components/cd_atmospheric_background.dart';
import 'content_result_screen.dart';
import 'create_screen.dart';

/// The creative archive screen for managing, duplicating, and viewing past creations.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPlatformFilter = 'All';
  final List<String> _filters = ['All', 'Instagram', 'YouTube', 'LinkedIn'];

  List<ContentProject> _getFilteredHistory(List<ContentProject> all) {
    if (_selectedPlatformFilter == 'All') return all;
    return all
        .where((p) => p.platform.toLowerCase() == _selectedPlatformFilter.toLowerCase())
        .toList();
  }

  void _openProject(ContentProject project) {
    AppState.instance.setCurrentProject(project);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContentResultScreen(project: project),
      ),
    );
  }

  Future<void> _duplicateProject(ContentProject project) async {
    AppHaptics.light();
    final dup = await AppState.instance.duplicateProject(project);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Content pack duplicated!'),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _openProject(dup),
          ),
        ),
      );
    }
  }

  Future<void> _deleteProject(ContentProject project) async {
    AppHaptics.light();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CDColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CDRadius.large)),
          title: Text(
            'Delete Content Pack',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: CDColors.textPrimary(context),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this content pack? This action cannot be undone.',
            style: TextStyle(color: CDColors.textSecondary(context)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: CDColors.textPrimary(context), fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: CDColors.error, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AppState.instance.deleteProject(project.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Content pack deleted'),
          duration: const Duration(milliseconds: 1400),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CDColors.textPrimary(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final isDark = CDColors.isDark(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allHistory = appState.contentHistory;
        final filtered = _getFilteredHistory(allHistory);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Content Archive',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            actions: [
              if (allHistory.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: CDSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? CDColors.accentSubdued
                            : CDColors.lightAccentSubtle,
                        borderRadius: BorderRadius.circular(CDRadius.pill),
                        border: Border.all(
                          color: isDark
                              ? CDColors.darkBorderSubtle
                              : CDColors.lightBorderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${allHistory.length} creations',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CDColors.primaryColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: CDAtmosphericBackground(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  if (allHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg, vertical: CDSpacing.xs),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _filters.map((f) {
                            final isSelected = _selectedPlatformFilter == f;
                            return Padding(
                              padding: const EdgeInsets.only(right: CDSpacing.sm),
                              child: ChoiceChip(
                                label: Text(f),
                                selected: isSelected,
                                onSelected: (_) {
                                  AppHaptics.selection();
                                  setState(() => _selectedPlatformFilter = f);
                                },
                                selectedColor: CDColors.primaryColor(context),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : CDColors.textPrimary(context),
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
                  // Content List
                  Expanded(
                    child: filtered.isEmpty
                        ? CDEmptyState(
                            icon: Icons.history_rounded,
                            title: _selectedPlatformFilter == 'All'
                                ? 'No creations yet'
                                : 'No $_selectedPlatformFilter creations',
                            message: 'Start with an idea and CreateDiff will build and store your personalized content packs here.',
                            actionLabel: 'Create a pack ✦',
                            onAction: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateScreen(),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: CDSpacing.lg,
                              right: CDSpacing.lg,
                              top: CDSpacing.md,
                              bottom: CDSpacing.navBarClearance,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final project = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: CDSpacing.sm),
                                child: CDRecentContentCard(
                                  project: project,
                                  onTap: () => _openProject(project),
                                  onDuplicate: () => _duplicateProject(project),
                                  onDelete: () => _deleteProject(project),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
