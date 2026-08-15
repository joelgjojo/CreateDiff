import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../components/cd_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'create_screen.dart';
import 'design_selection_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import '../models/content_project.dart';
import '../models/generated_content.dart';

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

  Widget _buildBody(AppState appState) {
    switch (_currentTabIndex) {
      case 0:
        return HomeScreen(
          onNavigateToHistory: () => setState(() => _currentTabIndex = 3),
        );
      case 2:
        final latestProject = appState.currentProject ??
            (appState.contentHistory.isNotEmpty
                ? appState.contentHistory.first
                : ContentProject(
                    id: 'demo',
                    platform: 'Instagram',
                    contentType: 'Reel',
                    idea: '5 AI Tools for Creators',
                    createdAt: DateTime.now(),
                    generatedContent: const GeneratedContent(
                      coverText: '5 AI TOOLS FOR CREATORS',
                      caption: 'Explore these curated creator tools...',
                    ),
                  ));
        return DesignSelectionScreen(project: latestProject);
      case 3:
        return const HistoryScreen();
      case 4:
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              _buildBody(appState),
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
