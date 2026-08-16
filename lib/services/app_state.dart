import 'dart:async';
import 'package:flutter/material.dart';
import '../models/creator_profile.dart';
import '../models/content_project.dart';
import '../models/generated_content.dart';
import 'storage_service.dart';
import 'grok_service.dart';
import '../config/api_config.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal();

  CreatorProfile _profile = const CreatorProfile();
  List<ContentProject> _contentHistory = [];
  ContentProject? _currentProject;
  GeneratedContent? _currentGeneratedContent;
  bool _isGenerating = false;
  AIGenerationStatus _generationStatus = AIGenerationStatus.idle;
  AIServiceException? _lastError;
  String _generationStep = 'Understanding your idea...';
  ThemeMode _themeMode = ThemeMode.system;
  Timer? _loadingTimer;

  // Getters
  CreatorProfile get profile => _profile;
  List<ContentProject> get contentHistory => _contentHistory;
  ContentProject? get currentProject => _currentProject;
  GeneratedContent? get currentGeneratedContent => _currentGeneratedContent;
  bool get isGenerating => _isGenerating;
  AIGenerationStatus get generationStatus => _generationStatus;
  AIServiceException? get lastError => _lastError;
  String get generationStep => _generationStep;
  ThemeMode get themeMode => _themeMode;

  bool get hasCompletedOnboarding => StorageService.hasCompletedOnboarding;
  bool get hasCompletedProfileSetup => StorageService.hasCompletedProfileSetup;

  /// Load initial persisted state from SharedPreferences and AI config
  Future<void> init() async {
    await ApiConfig.init();
    await StorageService.init();

    final savedProfile = StorageService.getCreatorProfile();
    if (savedProfile != null) {
      _profile = savedProfile;
    }

    _contentHistory = StorageService.getContentHistory();

    final savedTheme = StorageService.getThemeMode();
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  // --- Profile Actions ---
  Future<void> updateProfile(CreatorProfile newProfile) async {
    _profile = newProfile;
    await StorageService.saveCreatorProfile(newProfile);
    await StorageService.setCompletedProfileSetup(true);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await StorageService.setCompletedOnboarding(true);
    notifyListeners();
  }

  // --- Theme Mode ---
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await StorageService.setThemeMode(str);
    notifyListeners();
  }

  // --- Content Generation Workflow (Real Grok) ---
  Future<ContentProject?> generateContentPack({
    required String platform,
    required String contentType,
    required String idea,
    String? tone,
    String? language,
    String? length,
  }) async {
    if (_isGenerating) return null;
    _isGenerating = true;
    _generationStatus = GrokGenerationStatus.loading;
    _lastError = null;
    _generationStep = 'Connecting to Grok AI...';
    notifyListeners();

    try {
      _loadingTimer?.cancel();
      _loadingTimer = _startLoadingStepTimer(platform);

      final content = await AIService.generateContent(
        platform: platform,
        contentType: contentType,
        idea: idea,
        profile: _profile,
        overrideTone: tone,
        overrideLanguage: language,
        overrideLength: length,
      );

      final newProject = ContentProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        platform: platform,
        contentType: contentType,
        idea: idea,
        createdAt: DateTime.now(),
        status: 'generated',
        generatedContent: content,
        language: language ?? _profile.primaryLanguage,
        tone: tone ?? _profile.tone,
      );

      _currentProject = newProject;
      _currentGeneratedContent = content;
      _generationStatus = AIGenerationStatus.success;

      // Persist to history immediately
      await StorageService.addProjectToHistory(newProject);
      _contentHistory = StorageService.getContentHistory();

      return newProject;
    } on AIServiceException catch (e) {
      _lastError = e;
      _generationStatus = e.status;
      return null;
    } catch (e) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.unknownError,
        message: e.toString(),
      );
      _generationStatus = AIGenerationStatus.unknownError;
      return null;
    } finally {
      _loadingTimer?.cancel();
      _loadingTimer = null;
      _isGenerating = false;
      notifyListeners();
    }
  }

  void setCurrentProject(ContentProject project) {
    _currentProject = project;
    _currentGeneratedContent = project.generatedContent;
    notifyListeners();
  }

  /// Update caption text on the current project and persist
  Future<void> updateCurrentProjectCaption(String newCaption) async {
    if (_currentProject == null || _currentGeneratedContent == null) return;

    _currentGeneratedContent = _currentGeneratedContent!.copyWith(
      caption: newCaption,
    );
    final updated = _currentProject!.copyWith(
      generatedContent: _currentGeneratedContent,
    );
    _currentProject = updated;

    await StorageService.addProjectToHistory(updated);
    _contentHistory = StorageService.getContentHistory();
    notifyListeners();
  }

  Future<void> updateCurrentProjectDesign({
    required String templateName,
    required String style,
  }) async {
    if (_currentProject == null) return;
    final updated = _currentProject!.copyWith(
      selectedDesignTemplate: templateName,
      selectedDesignStyle: style,
      status: 'designed',
    );
    _currentProject = updated;
    await StorageService.addProjectToHistory(updated);
    _contentHistory = StorageService.getContentHistory();
    notifyListeners();
  }

  Future<void> regenerateHooks() async {
    if (_isGenerating || _currentProject == null || _currentGeneratedContent == null) return;
    _isGenerating = true;
    _generationStatus = GrokGenerationStatus.loading;
    _lastError = null;
    _generationStep = 'Crafting fresh hooks with Grok...';
    notifyListeners();

    try {
      _loadingTimer?.cancel();
      _loadingTimer = _startLoadingStepTimer(_currentProject!.platform);

      final newContent = await AIService.generateContent(
        platform: _currentProject!.platform,
        contentType: _currentProject!.contentType,
        idea: _currentProject!.idea,
        profile: _profile,
        overrideTone: _currentProject!.tone,
        overrideLanguage: _currentProject!.language,
      );

      _currentGeneratedContent = _currentGeneratedContent!.copyWith(
        hooks: newContent.hooks,
      );

      final updatedProj = _currentProject!.copyWith(
        generatedContent: _currentGeneratedContent,
      );
      _currentProject = updatedProj;
      _generationStatus = AIGenerationStatus.success;
      await StorageService.addProjectToHistory(updatedProj);
      _contentHistory = StorageService.getContentHistory();
    } on AIServiceException catch (e) {
      _lastError = e;
      _generationStatus = e.status;
    } catch (e) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.unknownError,
        message: e.toString(),
      );
      _generationStatus = AIGenerationStatus.unknownError;
    } finally {
      _loadingTimer?.cancel();
      _loadingTimer = null;
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    await StorageService.removeProjectFromHistory(projectId);
    _contentHistory = StorageService.getContentHistory();
    if (_currentProject?.id == projectId) {
      _currentProject = null;
      _currentGeneratedContent = null;
    }
    notifyListeners();
  }

  Future<ContentProject> duplicateProject(ContentProject project) async {
    final duplicated = project.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      status: 'generated',
    );
    await StorageService.addProjectToHistory(duplicated);
    _contentHistory = StorageService.getContentHistory();
    notifyListeners();
    return duplicated;
  }

  // --- Reset All Data ---
  Future<void> resetAll() async {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    await StorageService.clearAll();
    _profile = const CreatorProfile();
    _contentHistory = [];
    _currentProject = null;
    _currentGeneratedContent = null;
    _isGenerating = false;
    _generationStatus = AIGenerationStatus.idle;
    _lastError = null;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  Timer _startLoadingStepTimer(String platform) {
    final steps = [
      'Sending to Grok AI...',
      'Finding the strongest angle...',
      'Adapting to your brand voice...',
      'Structuring hooks & caption...',
      'Formatting for $platform...',
      'Polishing your content pack...',
    ];
    int stepIdx = 0;
    return Timer.periodic(const Duration(milliseconds: 900), (t) {
      stepIdx = (stepIdx + 1) % steps.length;
      _generationStep = steps[stepIdx];
      notifyListeners();
    });
  }
}
