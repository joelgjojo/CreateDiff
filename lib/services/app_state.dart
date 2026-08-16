import 'dart:async';
import 'package:flutter/material.dart';
import '../models/creator_profile.dart';
import '../models/content_project.dart';
import '../models/generated_content.dart';
import 'storage_service.dart';
import 'grok_service.dart';
import 'usage_guard.dart';
import 'input_validator.dart';
import 'backup_service.dart';
import '../config/api_config.dart';

typedef AIServiceException = GrokServiceException;

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
  bool _isApiConfigured = false;
  int _currentRetryAttempt = 1;

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
  bool get isApiConfigured => _isApiConfigured;
  int get currentRetryAttempt => _currentRetryAttempt;

  bool get hasCompletedOnboarding => StorageService.hasCompletedOnboarding;
  bool get hasCompletedProfileSetup => StorageService.hasCompletedProfileSetup;

  UsageStatus get usageStatus => UsageGuard.checkUsage();

  /// Load initial persisted state from SharedPreferences and AI config
  Future<void> init() async {
    await ApiConfig.init();
    _isApiConfigured = ApiConfig.hasApiKey;
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

  // --- Backup, Export & Import ---
  String exportProfileBackup() {
    return BackupService.exportProfileJson(_profile);
  }

  Future<ValidationResult> importProfileBackup(String jsonStr) async {
    final validation = BackupService.validateImportJson(jsonStr);
    if (!validation.isValid) return validation;

    final imported = BackupService.importProfileJson(jsonStr);
    if (imported == null) {
      return const ValidationResult.invalid('Failed to parse imported profile.');
    }

    await updateProfile(imported);
    return const ValidationResult.valid();
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

  // --- Content Generation Workflow ---
  Future<ContentProject?> generateContentPack({
    required String platform,
    required String contentType,
    required String idea,
    String? tone,
    String? language,
    String? length,
  }) async {
    if (_isGenerating) return null;

    // Input validation
    final validation = InputValidator.validateIdea(idea);
    if (!validation.isValid) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.unknownError,
        message: validation.errorMessage ?? 'Please enter a valid idea.',
      );
      _generationStatus = AIGenerationStatus.unknownError;
      notifyListeners();
      return null;
    }

    // Cost protection / Daily limit check
    final usage = UsageGuard.checkUsage();
    if (usage.isBlocked) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.rateLimited,
        message: usage.message ?? 'Daily studio limit reached. Resets tomorrow.',
      );
      _generationStatus = AIGenerationStatus.rateLimited;
      notifyListeners();
      return null;
    }

    // API Config check
    if (!_isApiConfigured) {
      _lastError = const AIServiceException(
        status: AIGenerationStatus.apiKeyMissing,
        message: 'AI features unavailable — API not configured.',
      );
      _generationStatus = AIGenerationStatus.apiKeyMissing;
      notifyListeners();
      return null;
    }

    _isGenerating = true;
    _generationStatus = GrokGenerationStatus.loading;
    _lastError = null;
    _generationStep = 'Connecting to Grok AI...';
    _currentRetryAttempt = 1;
    notifyListeners();

    try {
      _loadingTimer?.cancel();
      _loadingTimer = _startLoadingStepTimer(platform);

      final content = await GrokService.generateContent(
        platform: platform,
        contentType: contentType,
        idea: idea,
        profile: _profile,
        overrideTone: tone,
        overrideLanguage: language,
        overrideLength: length,
        onRetry: (attempt, max) {
          _currentRetryAttempt = attempt;
          _generationStep = 'Retrying with Grok AI (Attempt $attempt/$max)...';
          _generationStatus = AIGenerationStatus.retrying;
          notifyListeners();
        },
      );

      final now = DateTime.now();
      final newProject = ContentProject(
        id: now.millisecondsSinceEpoch.toString(),
        platform: platform,
        contentType: contentType,
        idea: idea,
        createdAt: now,
        updatedAt: now,
        status: 'generated',
        generatedContent: content,
        language: language ?? _profile.primaryLanguage,
        tone: tone ?? _profile.tone,
      );

      _currentProject = newProject;
      _currentGeneratedContent = content;
      _generationStatus = AIGenerationStatus.success;

      // Track usage & Persist to history
      await UsageGuard.recordGeneration();
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
      updatedAt: DateTime.now(),
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
      updatedAt: DateTime.now(),
    );
    _currentProject = updated;
    await StorageService.addProjectToHistory(updated);
    _contentHistory = StorageService.getContentHistory();
    notifyListeners();
  }

  Future<void> regenerateHooks() async {
    if (_isGenerating || _currentProject == null || _currentGeneratedContent == null) return;

    // Cost protection check
    final usage = UsageGuard.checkUsage();
    if (usage.isBlocked) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.rateLimited,
        message: usage.message ?? 'Daily studio limit reached. Resets tomorrow.',
      );
      _generationStatus = AIGenerationStatus.rateLimited;
      notifyListeners();
      return;
    }

    _isGenerating = true;
    _generationStatus = GrokGenerationStatus.loading;
    _lastError = null;
    _generationStep = 'Crafting fresh hooks with Grok...';
    _currentRetryAttempt = 1;
    notifyListeners();

    try {
      _loadingTimer?.cancel();
      _loadingTimer = _startLoadingStepTimer(_currentProject!.platform);

      final newContent = await GrokService.generateContent(
        platform: _currentProject!.platform,
        contentType: _currentProject!.contentType,
        idea: _currentProject!.idea,
        profile: _profile,
        overrideTone: _currentProject!.tone,
        overrideLanguage: _currentProject!.language,
        onRetry: (attempt, max) {
          _currentRetryAttempt = attempt;
          _generationStep = 'Retrying with Grok AI (Attempt $attempt/$max)...';
          _generationStatus = AIGenerationStatus.retrying;
          notifyListeners();
        },
      );

      _currentGeneratedContent = _currentGeneratedContent!.copyWith(
        hooks: newContent.hooks,
      );

      final updatedProj = _currentProject!.copyWith(
        generatedContent: _currentGeneratedContent,
        updatedAt: DateTime.now(),
      );
      _currentProject = updatedProj;
      _generationStatus = AIGenerationStatus.success;

      await UsageGuard.recordGeneration(estimatedTokens: 350);
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

  /// Non-destructive soft delete for safe undo
  Future<void> softDeleteProject(String projectId) async {
    await StorageService.softDeleteProject(projectId);
    _contentHistory = StorageService.getContentHistory();
    if (_currentProject?.id == projectId) {
      _currentProject = null;
      _currentGeneratedContent = null;
    }
    notifyListeners();
  }

  /// Restores a soft-deleted project (e.g. from SnackBar Undo)
  Future<void> restoreProject(String projectId) async {
    await StorageService.restoreProject(projectId);
    _contentHistory = StorageService.getContentHistory();
    notifyListeners();
  }

  /// Legacy alias
  Future<void> deleteProject(String projectId) async {
    await softDeleteProject(projectId);
  }

  Future<ContentProject> duplicateProject(ContentProject project) async {
    final now = DateTime.now();
    final duplicated = project.copyWith(
      id: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      deletedAt: null,
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
    await UsageGuard.resetToday();
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
