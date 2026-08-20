import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/config/api_config.dart';
import 'package:creatediff/services/grok_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppConfig.resetOverrides();
  });

  tearDown(() {
    AppConfig.resetOverrides();
  });

  group('AppConfig Production Architecture', () {
    test('Defaults to production HTTPS endpoint without hardcoded local IPs', () {
      expect(AppConfig.defaultProductionUrl, equals('https://creatediff-1.onrender.com'));
      expect(AppConfig.apiBaseUrl, equals('https://creatediff-1.onrender.com'));
      expect(AppConfig.isConfigured, isTrue);
      expect(AppConfig.providerName, equals('CreateDiff Cloud AI'));
      expect(AppConfig.model, equals('openai/gpt-oss-120b'));
    });

    test('Sanitizes URLs with trailing slashes, whitespace, and quotes', () {
      expect(AppConfig.sanitizeUrl('  https://api.creatediff.com/  '), equals('https://api.creatediff.com'));
      expect(AppConfig.sanitizeUrl('"https://custom.backend.com///"'), equals('https://custom.backend.com'));
      expect(AppConfig.sanitizeUrl("'https://dev.backend.com'"), equals('https://dev.backend.com'));
      expect(AppConfig.sanitizeUrl(null), equals(''));
    });

    test('Supports runtime overrides for debug switching and testing', () {
      AppConfig.setConfig(apiBaseUrl: 'https://staging.creatediff.com', model: 'custom-fast-model');
      expect(AppConfig.apiBaseUrl, equals('https://staging.creatediff.com'));
      expect(AppConfig.model, equals('custom-fast-model'));

      AppConfig.resetOverrides();
      expect(AppConfig.apiBaseUrl, equals('https://creatediff-1.onrender.com'));
      expect(AppConfig.model, equals('openai/gpt-oss-120b'));
    });

    test('ApiConfig adapter delegates seamlessly to AppConfig', () {
      expect(ApiConfig.backendBaseUrl, equals(AppConfig.apiBaseUrl));
      expect(ApiConfig.baseUrl, equals(AppConfig.apiBaseUrl));
      expect(ApiConfig.hasBackendConfigured, isTrue);
      expect(ApiConfig.hasApiKey, isTrue);
      expect(ApiConfig.providerName, equals('CreateDiff Cloud AI'));

      ApiConfig.setConfig(baseUrl: 'https://test.api.com');
      expect(ApiConfig.backendBaseUrl, equals('https://test.api.com'));
      expect(AppConfig.apiBaseUrl, equals('https://test.api.com'));

      ApiConfig.resetOverrides();
      expect(ApiConfig.backendBaseUrl, equals('https://creatediff-1.onrender.com'));
    });
  });

  group('Network Error Handling & IP Privacy Protection', () {
    test('Sanitizes host lookup failure without exposing IP', () {
      const socketEx = SocketException(
        'Failed host lookup: 10.0.2.2',
        osError: OSError('nodename nor servname provided, or not known', 8),
      );
      final message = GrokService.sanitizeNetworkErrorMessage(socketEx);
      expect(message.contains('10.0.2.2'), isFalse);
      expect(message, contains('Unable to resolve CreateDiff AI backend'));
    });

    test('Sanitizes connection refused without exposing local LAN IP or port', () {
      const socketEx = SocketException(
        'Connection refused',
        osError: OSError('Connection refused', 61),
      );
      final message = GrokService.sanitizeNetworkErrorMessage(socketEx);
      expect(message.contains('61'), isFalse);
      expect(message, contains('Unable to reach CreateDiff AI Studio server'));
    });

    test('Sanitizes network unreachable without exposing internal details', () {
      const socketEx = SocketException(
        'Network is unreachable',
        osError: OSError('Network is unreachable', 101),
      );
      final message = GrokService.sanitizeNetworkErrorMessage(socketEx);
      expect(message, contains('No active internet connection detected'));
    });

    test('Sanitizes SSL Handshake and Timeout exceptions', () {
      const handshakeEx = HandshakeException('Handshake error in client');
      expect(
        GrokService.sanitizeNetworkErrorMessage(handshakeEx),
        contains('Secure connection could not be established'),
      );

      final timeoutEx = TimeoutException('Request timed out');
      expect(
        GrokService.sanitizeNetworkErrorMessage(timeoutEx),
        contains('request timed out'),
      );
    });

    test('Strips raw IP address occurrences from generic exception strings', () {
      final rawError = Exception('Failed connecting to 192.168.1.105:8000 error code 500');
      final message = GrokService.sanitizeNetworkErrorMessage(rawError);
      expect(message.contains('192.168.1.105'), isFalse);
      expect(message.contains('[server]'), isTrue);
    });
  });
}
