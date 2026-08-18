import 'dart:async';
import 'package:flutter/material.dart';
import '../models/creator_profile.dart';
import '../models/content_project.dart';
import '../models/generated_content.dart';
import '../models/campaign_plan.dart';
import '../theme/design_tokens.dart';
import 'storage_service.dart';
import 'grok_service.dart';
import 'usage_guard.dart';
import 'input_validator.dart';
import 'backup_service.dart';
import '../config/api_config.dart';
import 'cloud_sync_service.dart';
import '../models/creator_intelligence.dart';

typedef AIServiceException = GrokServiceException;

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal();

  CreatorProfile _profile = const CreatorProfile();
  List<ContentProject> _contentHistory = [];
  List<CampaignPlan> _campaigns = [];
  ContentProject? _currentProject;
  GeneratedContent? _currentGeneratedContent;
  bool _isGenerating = false;
  bool _isPlanningCampaign = false;
  AIGenerationStatus _generationStatus = AIGenerationStatus.idle;
  AIServiceException? _lastError;
  String _generationStep = 'Understanding your idea...';
  ThemeMode _themeMode = ThemeMode.system;
  Timer? _loadingTimer;
  bool _isApiConfigured = true;
  int _currentRetryAttempt = 1;

  // Getters
  CreatorProfile get profile => _profile;
  List<ContentProject> get contentHistory => _contentHistory;
  List<CampaignPlan> get campaigns => _campaigns;
  List<ContentProject> get favorites =>
      _contentHistory.where((p) => p.isFavorite && !p.isDeleted).toList();
  List<ContentProject> get drafts =>
      _contentHistory.where((p) => p.isDraft && !p.isDeleted).toList();
  ContentProject? get currentProject => _currentProject;
  GeneratedContent? get currentGeneratedContent => _currentGeneratedContent;
  bool get isGenerating => _isGenerating;
  bool get isPlanningCampaign => _isPlanningCampaign;
  AIGenerationStatus get generationStatus => _generationStatus;
  AIServiceException? get lastError => _lastError;
  String get generationStep => _generationStep;
  ThemeMode get themeMode => _themeMode;
  bool get isApiConfigured => ApiConfig.hasApiKey;
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
    _campaigns = StorageService.getCampaigns();

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
    await CloudSyncService.syncLocalData(newProfile);
    notifyListeners();
  }

  Future<void> updateCreatorMemory(CreatorMemory memory) async {
    await updateProfile(_profile.copyWith(creatorMemory: memory));
  }

  Future<void> clearCreatorMemory() => updateCreatorMemory(const CreatorMemory());

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

    final reqId = ++_activeRequestId;
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
          if (_activeRequestId != reqId) return;
          _currentRetryAttempt = attempt;
          _generationStep = CDStrings.retryLoadingMessage;
          _generationStatus = AIGenerationStatus.retrying;
          notifyListeners();
        },
      );

      if (_activeRequestId != reqId) return null;

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
      await CloudSyncService.syncLocalData(_profile);

      return newProject;
    } on AIServiceException catch (e) {
      if (_activeRequestId == reqId) {
        _lastError = e;
        _generationStatus = e.status;
      }
      return null;
    } catch (e) {
      if (_activeRequestId == reqId) {
        _lastError = AIServiceException(
          status: AIGenerationStatus.unknownError,
          message: e.toString(),
        );
        _generationStatus = AIGenerationStatus.unknownError;
      }
      return null;
    } finally {
      if (_activeRequestId == reqId) {
        _loadingTimer?.cancel();
        _loadingTimer = null;
        _isGenerating = false;
        notifyListeners();
      }
    }
  }

  void setCurrentProject(ContentProject project) {
    _currentProject = project;
    _currentGeneratedContent = project.generatedContent;
    notifyListeners();
  }

  /// Toggle bookmark / favorite status on a project
  Future<void> toggleFavorite(String projectId) async {
    final wasFavorite = _contentHistory.where((project) => project.id == projectId).firstOrNull?.isFavorite ?? false;
    await StorageService.toggleFavorite(projectId);
    _contentHistory = StorageService.getContentHistory();
    final project = _contentHistory.where((item) => item.id == projectId).firstOrNull;
    if (!wasFavorite && project != null && project.isFavorite) {
      final hook = project.generatedContent?.hooks.isNotEmpty == true ? project.generatedContent!.hooks.first : '';
      final memory = _profile.creatorMemory;
      await updateCreatorMemory(memory.copyWith(
        successfulPatterns: _appendUnique(memory.successfulPatterns, 'Favorited ${project.contentType}'),
        preferredFormats: _appendUnique(memory.preferredFormats, project.contentType),
        preferredHooks: hook.isEmpty ? memory.preferredHooks : _appendUnique(memory.preferredHooks, hook),
      ));
    }
    if (_currentProject?.id == projectId) {
      _currentProject = _currentProject!.copyWith(
        isFavorite: !_currentProject!.isFavorite,
      );
    }
    notifyListeners();
  }

  /// Save or update a project as draft
  Future<void> saveDraft(ContentProject draftProject) async {
    final updated = draftProject.copyWith(
      isDraft: true,
      status: 'draft',
      updatedAt: DateTime.now(),
    );
    await StorageService.addProjectToHistory(updated);
    _contentHistory = StorageService.getContentHistory();
    if (_currentProject?.id == draftProject.id) {
      _currentProject = updated;
    }
    notifyListeners();
  }

  // --- Campaign Planner Workflow ---
  Future<CampaignPlan?> planCampaign({
    required String goal,
    int durationDays = 7,
    String? platform,
    String? niche,
  }) async {
    if (_isPlanningCampaign) return null;

    final usage = UsageGuard.checkUsage();
    if (usage.isBlocked) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.rateLimited,
        message: usage.message ?? 'Daily studio limit reached. Resets tomorrow.',
      );
      notifyListeners();
      return null;
    }

    _isPlanningCampaign = true;
    _lastError = null;
    notifyListeners();

    try {
      final plan = await GrokService.planCampaign(
        goal: goal,
        durationDays: durationDays,
        platform: platform,
        niche: niche,
        profile: _profile,
      );

      await StorageService.saveCampaign(plan);
      _campaigns = StorageService.getCampaigns();
      await UsageGuard.recordGeneration(estimatedTokens: durationDays * 50);
      await CloudSyncService.syncLocalData(_profile);
      return plan;
    } on AIServiceException catch (e) {
      _lastError = e;
      return null;
    } catch (e) {
      _lastError = AIServiceException(
        status: AIGenerationStatus.unknownError,
        message: e.toString(),
      );
      return null;
    } finally {
      _isPlanningCampaign = false;
      notifyListeners();
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    await StorageService.deleteCampaign(campaignId);
    _campaigns = StorageService.getCampaigns();
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

  int _activeRequestId = 0;

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

    final reqId = ++_activeRequestId;
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
          if (_activeRequestId != reqId) return;
          _currentRetryAttempt = attempt;
          _generationStep = CDStrings.retryLoadingMessage;
          _generationStatus = AIGenerationStatus.retrying;
          notifyListeners();
        },
      );

      if (_activeRequestId != reqId) return;

      // Atomically update hooks only
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
      if (_activeRequestId == reqId) {
        _lastError = e;
        _generationStatus = e.status;
      }
    } catch (e) {
      if (_activeRequestId == reqId) {
        _lastError = AIServiceException(
          status: AIGenerationStatus.unknownError,
          message: e.toString(),
        );
        _generationStatus = AIGenerationStatus.unknownError;
      }
    } finally {
      if (_activeRequestId == reqId) {
        _loadingTimer?.cancel();
        _loadingTimer = null;
        _isGenerating = false;
        notifyListeners();
      }
    }
  }

  /// Non-destructive full content pack regeneration
  Future<ContentProject?> regenerateCurrentProject({
    String? tone,
    String? language,
  }) async {
    if (_isGenerating || _currentProject == null) return null;

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

    if (!_isApiConfigured) {
      _lastError = const AIServiceException(
        status: AIGenerationStatus.apiKeyMissing,
        message: 'AI features unavailable — API not configured.',
      );
      _generationStatus = AIGenerationStatus.apiKeyMissing;
      notifyListeners();
      return null;
    }

    final reqId = ++_activeRequestId;
    _isGenerating = true;
    _generationStatus = GrokGenerationStatus.loading;
    _lastError = null;
    _generationStep = 'Regenerating complete studio pack...';
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
        overrideTone: tone ?? _currentProject!.tone,
        overrideLanguage: language ?? _currentProject!.language,
        onRetry: (attempt, max) {
          if (_activeRequestId != reqId) return;
          _currentRetryAttempt = attempt;
          _generationStep = CDStrings.retryLoadingMessage;
          _generationStatus = AIGenerationStatus.retrying;
          notifyListeners();
        },
      );

      if (_activeRequestId != reqId) return null;

      // Atomically replace on success
      _currentGeneratedContent = newContent;
      final updatedProj = _currentProject!.copyWith(
        generatedContent: newContent,
        tone: tone ?? _currentProject!.tone,
        language: language ?? _currentProject!.language,
        updatedAt: DateTime.now(),
      );
      _currentProject = updatedProj;
      _generationStatus = AIGenerationStatus.success;

      await UsageGuard.recordGeneration();
      await StorageService.addProjectToHistory(updatedProj);
      _contentHistory = StorageService.getContentHistory();

      return updatedProj;
    } on AIServiceException catch (e) {
      if (_activeRequestId == reqId) {
        _lastError = e;
        _generationStatus = e.status;
      }
      return null;
    } catch (e) {
      if (_activeRequestId == reqId) {
        _lastError = AIServiceException(
          status: AIGenerationStatus.unknownError,
          message: e.toString(),
        );
        _generationStatus = AIGenerationStatus.unknownError;
      }
      return null;
    } finally {
      if (_activeRequestId == reqId) {
        _loadingTimer?.cancel();
        _loadingTimer = null;
        _isGenerating = false;
        notifyListeners();
      }
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
    final memory = _profile.creatorMemory;
    await updateCreatorMemory(memory.copyWith(
      preferredFormats: _appendUnique(memory.preferredFormats, project.contentType),
    ));
    notifyListeners();
    return duplicated;
  }

  List<String> _appendUnique(List<String> values, String value) {
    if (value.trim().isEmpty || values.contains(value)) return values;
    return [...values, value].take(12).toList();
  }

  // --- Reset All Data ---
  Future<void> resetAll() async {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    await StorageService.clearAll();
    await UsageGuard.resetToday();
    _profile = const CreatorProfile();
    _contentHistory = [];
    _campaigns = [];
    _currentProject = null;
    _currentGeneratedContent = null;
    _isGenerating = false;
    _isPlanningCampaign = false;
    _generationStatus = AIGenerationStatus.idle;
    _lastError = null;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  Timer _startLoadingStepTimer(String platform) {
    final standardSteps = [
      'Connecting to AI engine...',
      'Finding the strongest angle...',
      'Adapting to your brand voice...',
      'Structuring hooks & caption...',
      'Formatting for $platform...',
      'Polishing your content pack...',
    ];
    int elapsedSeconds = 0;
    int stepIdx = 0;
    return Timer.periodic(const Duration(milliseconds: 1000), (t) {
      elapsedSeconds++;
      if (elapsedSeconds >= 5) {
        _generationStep = 'Waking up the AI engine — this can take up to a minute on first use...';
      } else {
        stepIdx = (stepIdx + 1) % standardSteps.length;
        _generationStep = standardSteps[stepIdx];
      }
      notifyListeners();
    });
  }
}
