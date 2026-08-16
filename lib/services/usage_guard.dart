import 'package:shared_preferences/shared_preferences.dart';

enum UsageLimitLevel {
  allowed,
  warning,
  blocked,
}

class UsageStatus {
  final UsageLimitLevel level;
  final int todayCount;
  final int dailyLimit;
  final int remainingCount;
  final String? message;

  const UsageStatus({
    required this.level,
    required this.todayCount,
    required this.dailyLimit,
    required this.remainingCount,
    this.message,
  });

  bool get isBlocked => level == UsageLimitLevel.blocked;
  bool get isWarning => level == UsageLimitLevel.warning;
  bool get isAllowed => level != UsageLimitLevel.blocked;
}

/// Cost protection and daily rate limiting guard
class UsageGuard {
  static const int defaultDailyLimit = 50;
  static const int defaultWarningThreshold = 40;
  static const String _keyPrefix = 'creatediff_usage_';
  static const String _keyTotalTokens = 'creatediff_total_est_tokens';

  static SharedPreferences? _prefs;

  static Future<void> init([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$_keyPrefix${now.year}-$month-$day';
  }

  /// Get current count of generations completed today
  static int getTodayGenerationCount() {
    return _prefs?.getInt(_todayKey()) ?? 0;
  }

  /// Estimated total tokens generated across app lifetime
  static int getEstimatedTotalTokens() {
    return _prefs?.getInt(_keyTotalTokens) ?? 0;
  }

  /// Evaluates current usage status against daily limit
  static UsageStatus checkUsage({
    int dailyLimit = defaultDailyLimit,
    int warningThreshold = defaultWarningThreshold,
  }) {
    final today = getTodayGenerationCount();
    final remaining = (dailyLimit - today).clamp(0, dailyLimit);

    if (today >= dailyLimit) {
      return UsageStatus(
        level: UsageLimitLevel.blocked,
        todayCount: today,
        dailyLimit: dailyLimit,
        remainingCount: 0,
        message: 'Daily studio generation limit reached ($dailyLimit/$dailyLimit). Resets tomorrow.',
      );
    }

    if (today >= warningThreshold) {
      return UsageStatus(
        level: UsageLimitLevel.warning,
        todayCount: today,
        dailyLimit: dailyLimit,
        remainingCount: remaining,
        message: 'Approaching daily limit: $today/$dailyLimit generations used today ($remaining left).',
      );
    }

    return UsageStatus(
      level: UsageLimitLevel.allowed,
      todayCount: today,
      dailyLimit: dailyLimit,
      remainingCount: remaining,
    );
  }

  /// Records a successful generation and updates token telemetry
  static Future<void> recordGeneration({int estimatedTokens = 1100}) async {
    final current = getTodayGenerationCount();
    await _prefs?.setInt(_todayKey(), current + 1);

    final totalTokens = getEstimatedTotalTokens();
    await _prefs?.setInt(_keyTotalTokens, totalTokens + estimatedTokens);
  }

  /// Resets today's usage count (useful for testing or overrides)
  static Future<void> resetToday() async {
    await _prefs?.remove(_todayKey());
  }
}
