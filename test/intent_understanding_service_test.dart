import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/creator_intelligence.dart';
import 'package:creatediff/services/intent_understanding_service.dart';

void main() {
  group('IntentUnderstandingService Heuristics', () {
    const profile = CreatorProfile(
      creatorName: 'Alex Creator',
      niche: 'AI & Productivity',
      primaryLanguage: 'English',
      brandDNA: BrandDNA(
        writingStyle: 'Direct and punchy',
        creatorPersonality: 'Tech Educator',
      ),
    );

    test('extracts Instagram Reel with student audience', () {
      final intent = IntentUnderstandingService.heuristicExtract(
        'Make an Instagram reel about top AI tools for college students',
        profile,
      );

      expect(intent.platform, 'Instagram');
      expect(intent.contentType, 'Reel');
      expect(intent.language, 'English');
      expect(intent.audience, contains('student'));
      expect(intent.idea, isNotEmpty);
    });

    test('extracts Malayalam Short on YouTube', () {
      final intent = IntentUnderstandingService.heuristicExtract(
        'Create a Malayalam YouTube short explaining ChatGPT',
        profile,
      );

      expect(intent.platform, 'YouTube');
      expect(intent.contentType, 'Short');
      expect(intent.language, 'Malayalam');
    });

    test('extracts LinkedIn Carousel', () {
      final intent = IntentUnderstandingService.heuristicExtract(
        'Make a LinkedIn carousel on 5 daily habits',
        profile,
      );

      expect(intent.platform, 'LinkedIn');
      expect(intent.contentType, 'Carousel');
    });
  });

  group('BrandDNA Model', () {
    test('serializes and deserializes BrandDNA correctly', () {
      const dna = BrandDNA(
        writingStyle: 'Narrative storytelling',
        visualIdentity: 'Minimal monochrome',
        creatorPersonality: 'Founder & Builder',
        audienceProfile: 'Indie Hackers',
        preferredColors: ['#111111', '#4F43F9'],
        successfulContentPatterns: ['Contrarian take hook'],
        culturalContext: 'Kerala Tech Ecosystem',
      );

      final json = dna.toJson();
      final fromJson = BrandDNA.fromJson(json);

      expect(fromJson.writingStyle, 'Narrative storytelling');
      expect(fromJson.visualIdentity, 'Minimal monochrome');
      expect(fromJson.creatorPersonality, 'Founder & Builder');
      expect(fromJson.preferredColors, ['#111111', '#4F43F9']);
      expect(fromJson.culturalContext, 'Kerala Tech Ecosystem');
    });
  });
}
