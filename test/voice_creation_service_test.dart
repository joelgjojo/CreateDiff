import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/models/creator_profile.dart';
import 'package:creatediff/services/voice_creation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceCreationService Fallback & State', () {
    const profile = CreatorProfile(
      creatorName: 'Alex Creator',
      niche: 'Technology',
    );

    test('initial state is idle', () {
      expect(VoiceCreationService.state, VoiceRecordingState.idle);
      expect(VoiceCreationService.isListening, isFalse);
    });

    test('processes transcribed speech to CreatorIntent via IntentUnderstandingService', () async {
      final intent = await VoiceCreationService.processVoiceIntent(
        transcribedText: 'Make an Instagram reel about 5 best productivity apps',
        profile: profile,
      );

      expect(intent.platform, 'Instagram');
      expect(intent.contentType, 'Reel');
      expect(intent.idea, isNotEmpty);
    });
  });
}
