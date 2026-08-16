import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/content_project.dart';
import '../services/app_state.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_empty_state.dart';
import 'content_result_screen.dart';
import 'create_screen.dart';

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
          title: Text(
            'Delete Content Pack',
            style: TextStyle(color: CDColors.textPrimary(context)),
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
                style: TextStyle(color: CDColors.textPrimary(context)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: CDColors.error),
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

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allHistory = appState.contentHistory;
        final filtered = _getFilteredHistory(allHistory);

        return Scaffold(
          backgroundColor: CDColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Content History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: CDColors.textPrimary(context),
                  ),
            ),
            actions: [
              if (allHistory.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: CDSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CDColors.elevated(context),
                        borderRadius: CDRadius.rPill,
                      ),
                      child: Text(
                        '${allHistory.length} creations',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CDColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              if (allHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CDSpacing.xl, vertical: CDSpacing.xs),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          left: CDSpacing.xl,
                          right: CDSpacing.xl,
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
        );
      },
    );
  }
}
