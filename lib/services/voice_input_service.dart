import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// On-device speech recognition service for CreateDiff studio canvas.
/// Strictly uses on-device OS speech engine with zero paid external API dependencies.
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Start listening with device speech recognition.
  /// Resolves the best available locale between English India (en_IN), Malayalam (ml_IN), and Hindi (hi_IN).
  Future<bool> start({
    required void Function(String text) onResult,
    required void Function(String message) onError,
    void Function(String status)? onStatus,
    String localeId = 'en_IN',
  }) async {
    try {
      if (!_isInitialized) {
        _isInitialized = await _speech.initialize(
          onError: (error) {
            if (kDebugMode) {
              debugPrint('[VoiceInputService] Error: ${error.errorMsg} (permanent: ${error.permanent})');
            }
            onError(error.errorMsg.isNotEmpty ? error.errorMsg : 'Speech recognition encountered an issue.');
          },
          onStatus: (status) {
            if (kDebugMode) {
              debugPrint('[VoiceInputService] Status: $status');
            }
            onStatus?.call(status);
          },
        );
      }

      if (!_isInitialized) {
        onError('Microphone or Speech Recognition permission not granted.');
        return false;
      }

      // Check available locales on device and select appropriate match or fallback
      final locales = await _speech.locales();
      String selectedLocaleId = localeId;

      final hasRequestedLocale = locales.any((l) =>
          l.localeId.toLowerCase().replaceAll('_', '-') == localeId.toLowerCase().replaceAll('_', '-'));

      if (!hasRequestedLocale && locales.isNotEmpty) {
        // Fall back to first matching language prefix or default en_IN / first available
        final langPrefix = localeId.split('_').first.toLowerCase();
        final prefixMatch = locales.where((l) => l.localeId.toLowerCase().startsWith(langPrefix)).firstOrNull;
        if (prefixMatch != null) {
          selectedLocaleId = prefixMatch.localeId;
        } else {
          final enMatch = locales.where((l) => l.localeId.toLowerCase().contains('en')).firstOrNull;
          selectedLocaleId = enMatch?.localeId ?? locales.first.localeId;
        }
      }

      await _speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          localeId: selectedLocaleId,
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
        ),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VoiceInputService] Exception during start: $e');
      }
      onError('Unable to start voice dictation: $e');
      return false;
    }
  }

  /// Stop active speech listening
  Future<void> stop() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
  }

  /// Cancel speech recognition immediately
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {}
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized && _speech.isAvailable;
}
