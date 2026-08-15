import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../components/cd_platform_selector.dart';
import '../components/cd_recent_content_card.dart';
import '../components/cd_empty_state.dart';
import 'content_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onOpenCreate;

  const HistoryScreen({
    super.key,
    this.onOpenCreate,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPlatform = 'All';
  final List<String> _platforms = ['All', 'Instagram', 'YouTube', 'LinkedIn'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final allProjects = appState.contentHistory;
        final filteredProjects = _selectedPlatform == 'All'
            ? allProjects
            : allProjects
                .where((p) => p.platform.toLowerCase() == _selectedPlatform.toLowerCase())
                .toList();

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: 100, // Clearance for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content History',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All your generated content packs & visual templates.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Platform Filter
                  CDPlatformSelector(
                    platforms: _platforms,
                    selectedPlatform: _selectedPlatform,
                    onPlatformSelected: (p) => setState(() => _selectedPlatform = p),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // History Project List
                  Expanded(
                    child: filteredProjects.isEmpty
                        ? CDEmptyState(
                            icon: Icons.history_rounded,
                            title: 'No saved content yet',
                            message: _selectedPlatform == 'All'
                                ? 'Your generated content packs will be archived here automatically.'
                                : 'No content packs found for $_selectedPlatform.',
                            actionLabel: 'Create New Content ✦',
                            onAction: widget.onOpenCreate,
                          )
                        : ListView.separated(
                            itemCount: filteredProjects.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final project = filteredProjects[index];
                              return CDRecentContentCard(
                                project: project,
                                onTap: () {
                                  appState.setCurrentProject(project);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ContentResultScreen(project: project),
                                    ),
                                  );
                                },
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
