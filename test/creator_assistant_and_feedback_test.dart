import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/services/creator_assistant_service.dart';
import 'package:creatediff/services/performance_intelligence_service.dart';
import 'package:creatediff/services/monetization_foundation_service.dart';
import 'package:creatediff/services/trend_intelligence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CreatorAssistantService', () {
    const profile = CreatorProfile(
      creatorName: 'Alex Creator',
      niche: 'AI & Design',
    );

    test('cold start fallback returns profile-based suggestions', () {
      final res = CreatorAssistantService.heuristicSuggestions(profile, isColdStart: true);
      expect(res.isColdStartFallback, isTrue);
      expect(res.sourceLabel, 'Profile-based starting suggestions');
      expect(res.suggestions.length, 3);
      expect(res.suggestions.first.topic, contains('AI & Design'));
    });

    test('tuned suggestion returns personalized AI label', () {
      final res = CreatorAssistantService.heuristicSuggestions(profile, isColdStart: false);
      expect(res.isColdStartFallback, isFalse);
      expect(res.sourceLabel, 'Performance-Tuned AI Partner');
    });
  });

  group('PerformanceIntelligenceService', () {
    test('records feedback locally in mock SharedPreferences', () async {
      await PerformanceIntelligenceService.recordFeedback(
        contentId: 'gen_100',
        platform: 'Instagram',
        contentType: 'Reel',
        feedback: 'worked',
        notes: 'Great hook retention',
      );

      final list = await PerformanceIntelligenceService.getAllFeedback();
      expect(list.length, 1);
      expect(list.first.contentId, 'gen_100');
      expect(list.first.feedback, 'worked');

      final hasHistory = await PerformanceIntelligenceService.hasPerformanceHistory();
      expect(hasHistory, isTrue);
    });
  });

  group('MonetizationFoundationService & TrendRadar', () {
    test('entitlements are properly configured for tiers', () {
      final freeEntitlement = MonetizationFoundationService.getEntitlement(CreatorPlanTier.free);
      expect(freeEntitlement.monthlyGenerationsLimit, 50);

      final proEntitlement = MonetizationFoundationService.getEntitlement(CreatorPlanTier.pro);
      expect(proEntitlement.monthlyGenerationsLimit, 500);
      expect(proEntitlement.hasPriorityAiEngine, isTrue);
    });

    test('trends return curated items for niche', () {
      final trends = TrendIntelligenceService.getTrendsForNiche('Technology & AI');
      expect(trends, isNotEmpty);
      expect(trends.first.velocity, 'Surging');
    });
  });
}
