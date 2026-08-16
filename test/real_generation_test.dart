import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/services/ai_service.dart';
import 'package:creatediff/services/ai_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null; // Enable live HTTP requests during integration testing

  test('Live AI Generation Pipeline Test (when GROK_API_KEY is supplied)', () async {
    await AIConfig.init();

    if (!AIConfig.hasApiKey) {
      expect(AIConfig.hasApiKey, isFalse);
      return;
    }

    const profile = CreatorProfile(
      creatorName: 'Joel G Jojo',
      username: '@joelgjojo',
      niche: 'Technology',
      targetAudience: 'Content creators and engineers',
      tone: 'Educational',
      primaryLanguage: 'English',
      contentStyle: 'Actionable design tips',
      brandDescription: 'AI content and design studio',
      emojiUsage: 'moderate',
      preferredCTAStyle: 'Direct',
    );

    final content = await AIService.generateContent(
      platform: 'Instagram',
      contentType: 'Reel',
      idea: '5 Essential AI Tools Every Content Creator Needs in 2026',
      profile: profile,
    );

    expect(content.hooks.length, equals(5));
    expect(content.caption.isNotEmpty, isTrue);
    expect(content.ctas.isNotEmpty, isTrue);
    expect(content.coverText.isNotEmpty, isTrue);

    // Verify debug telemetry recorded
    final log = AIService.lastDebugLog;
    expect(log, isNotNull);
    expect(log!.status, equals(AIGenerationStatus.success));
    expect(log.statusCode, equals(200));
  });
}
