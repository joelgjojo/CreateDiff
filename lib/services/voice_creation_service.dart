import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/creator_profile.dart';
import 'intent_understanding_service.dart';

enum VoiceRecordingState {
  idle,
  initializing,
  listening,
  processing,
  success,
  permissionDenied,
  unavailable,
  error,
}

/// Voice-First Creator System: listens to creator speech, transcribes in real-time,
/// extracts structured intent, and triggers creation workflows with graceful fallback.
class VoiceCreationService {
  VoiceCreationService._();

  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;
  static VoiceRecordingState _state = VoiceRecordingState.idle;

  static VoiceRecordingState get state => _state;
  static bool get isListening => _speech.isListening;

  /// Initializes the speech recognition engine safely.
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (err) {
          if (kDebugMode) {
            debugPrint('[VoiceCreationService] Speech error: ${err.errorMsg}');
          }
          _state = VoiceRecordingState.error;
        },
        onStatus: (status) {
          if (kDebugMode) {
            debugPrint('[VoiceCreationService] Speech status: $status');
          }
          if (status == 'notListening' && _state == VoiceRecordingState.listening) {
            _state = VoiceRecordingState.idle;
          }
        },
      );
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VoiceCreationService] Initialization exception: $e');
      }
      _isInitialized = false;
      return false;
    }
  }

  /// Starts listening to creator speech.
  /// If permissions are denied or speech engine is unavailable, invokes fallback gracefully.
  static Future<void> startListening({
    required Function(String liveTranscription) onTranscription,
    required Function(VoiceRecordingState state) onStateChanged,
    required Function(String fallbackMessage) onFallbackToText,
  }) async {
    _state = VoiceRecordingState.initializing;
    onStateChanged(_state);

    final available = await initialize();
    if (!available) {
      _state = VoiceRecordingState.unavailable;
      onStateChanged(_state);
      onFallbackToText('Voice recognition is unavailable on this device. Switched to text input.');
      _state = VoiceRecordingState.idle;
      onStateChanged(_state);
      return;
    }

    final hasPerm = await _speech.hasPermission;
    if (!hasPerm) {
      _state = VoiceRecordingState.permissionDenied;
      onStateChanged(_state);
      onFallbackToText('Microphone permission not granted. Switched to text input.');
      _state = VoiceRecordingState.idle;
      onStateChanged(_state);
      return;
    }

    _state = VoiceRecordingState.listening;
    onStateChanged(_state);

    try {
      await _speech.listen(
        onResult: (result) {
          onTranscription(result.recognizedWords);
          if (result.finalResult) {
            _state = VoiceRecordingState.success;
            onStateChanged(_state);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
        ),
      );
    } catch (e) {
      _state = VoiceRecordingState.error;
      onStateChanged(_state);
      onFallbackToText('Voice capture interrupted. Switched to text input.');
      _state = VoiceRecordingState.idle;
      onStateChanged(_state);
    }
  }

  /// Stops speech listening cleanly.
  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    _state = VoiceRecordingState.idle;
  }

  /// Cancels speech session.
  static Future<void> cancel() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
    _state = VoiceRecordingState.idle;
  }

  /// Process transcribed voice text into structured CreatorIntent.
  static Future<CreatorIntent> processVoiceIntent({
    required String transcribedText,
    required CreatorProfile profile,
  }) async {
    return IntentUnderstandingService.extractIntent(
      rawPrompt: transcribedText,
      profile: profile,
    );
  }
}
