import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/models/creator_intelligence.dart';
import 'package:creatediff/services/visual_creation_service.dart';

void main() {
  group('VisualCreationService Heuristic Direction', () {
    const profile = CreatorProfile(
      creatorName: 'Alex Creator',
      niche: 'AI & Productivity',
      brandDNA: BrandDNA(
        preferredColors: ['#080A0F', '#4F43F9', '#7066FF'],
      ),
    );

    test('generates Reel Cover direction cleanly', () {
      final res = VisualCreationService.heuristicReelCover('Top AI Tools for Students', 'STOP WASTING HOURS', profile);
      expect(res.formatType, 'reel_cover');
      expect(res.reelCover, isNotNull);
      expect(res.reelCover!.headline, contains('STOP WASTING HOURS'));
      expect(res.reelCover!.typography, isNotEmpty);
      expect(res.reelCover!.visualHierarchy, isNotEmpty);
    });

    test('generates YouTube Thumbnail direction cleanly', () {
      final res = VisualCreationService.heuristicThumbnail('How to Learn Coding in 2026', 'FASTEST WAY', profile);
      expect(res.formatType, 'youtube_thumbnail');
      expect(res.youtubeThumbnail, isNotNull);
      expect(res.youtubeThumbnail!.thumbnailIdea, isNotEmpty);
      expect(res.youtubeThumbnail!.attentionStrategy, isNotEmpty);
    });

    test('generates Carousel Blueprint with 4 structured slides', () {
      final res = VisualCreationService.heuristicCarousel('5 Daily Habits for Creators', 'LEVEL UP', profile);
      expect(res.formatType, 'carousel');
      expect(res.carousel, isNotNull);
      expect(res.carousel!.slides.length, 4);
      expect(res.carousel!.slides.first.slideNumber, 1);
      expect(res.carousel!.slides.first.visualDirection, isNotEmpty);
    });
  });
}
