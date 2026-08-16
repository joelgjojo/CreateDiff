import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../components/cd_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'design_selection_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../components/cd_empty_state.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  void _onTabSelected(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CreateScreen(),
        ),
      );
    } else {
      setState(() => _currentTabIndex = index);
    }
  }

  Widget _buildDesignTab(AppState appState) {
    final latestProject = appState.currentProject ??
        (appState.contentHistory.isNotEmpty
            ? appState.contentHistory.first
            : null);

    if (latestProject == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CDSpacing.lg),
          child: CDEmptyState(
            icon: Icons.design_services_rounded,
            title: 'No Designs Yet',
            message: 'Create some content to view and edit designs.',
            actionLabel: 'Create Content',
            onAction: () => _onTabSelected(1),
          ),
        ),
      );
    }
    return DesignSelectionScreen(project: latestProject);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CDColors.surface(context),
          body: Stack(
            children: [
              IndexedStack(
                index: _currentTabIndex,
                children: [
                  HomeScreen(
                    onNavigateToHistory: () => setState(() => _currentTabIndex = 3),
                  ),
                  const SizedBox.shrink(), // Create tab is just a push
                  _buildDesignTab(appState),
                  const HistoryScreen(),
                  const ProfileScreen(),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CDBottomNavBar(
                  selectedIndex: _currentTabIndex,
                  onTabChanged: _onTabSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
