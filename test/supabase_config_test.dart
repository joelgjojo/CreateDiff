import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/config/supabase_config.dart';

void main() {
  setUp(() {
    SupabaseConfig.resetOverrides();
  });

  tearDown(() {
    SupabaseConfig.resetOverrides();
  });

  test('SupabaseConfig sanitizes and holds override credentials', () {
    SupabaseConfig.setOverrides(
      url: '  "https://example.supabase.co"  ',
      anonKey: '  \'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.testkey123456\'  ',
    );

    expect(SupabaseConfig.url, 'https://example.supabase.co');
    expect(SupabaseConfig.anonKey, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.testkey123456');
    expect(SupabaseConfig.isConfigured, isTrue);

    final diag = SupabaseConfig.diagnosticStatus;
    expect(diag['supabaseUrlConfigured'], isTrue);
    expect(diag['supabasePublicKeyConfigured'], isTrue);
    expect(diag['supabaseIsConfigured'], isTrue);
    expect(diag['supabaseHost'], 'example.supabase.co');
    // Ensure actual anonKey is never exposed in diagnostics
    expect(diag.containsKey('anonKey'), isFalse);
    expect(diag.containsKey('key'), isFalse);

    SupabaseConfig.resetOverrides();
  });

  test('SupabaseConfig rejects placeholder URLs and keys', () {
    expect(SupabaseConfig.isPlaceholder('https://<project-ref>.supabase.co'), isTrue);
    expect(SupabaseConfig.isPlaceholder('<your_supabase_anon_public_key>'), isTrue);
    expect(SupabaseConfig.isPlaceholder('YOUR_ANON_KEY'), isTrue);
    expect(SupabaseConfig.isPlaceholder('https://xyz.supabase.co'), isFalse);
    expect(SupabaseConfig.isPlaceholder('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy'), isFalse);

    SupabaseConfig.setOverrides(
      url: 'https://<project-ref>.supabase.co',
      anonKey: '<your_supabase_anon_public_key>',
    );
    expect(SupabaseConfig.isConfigured, isFalse);

    final diag = SupabaseConfig.diagnosticStatus;
    expect(diag['supabasePlaceholderDetected'], isTrue);
    expect(diag['supabaseUrlValid'], isFalse);
    expect(diag['supabaseIsConfigured'], isFalse);
    expect(diag['supabaseHost'], 'invalid_or_placeholder');

    SupabaseConfig.resetOverrides();
  });

  test('SupabaseConfig validates URL structure', () {
    expect(SupabaseConfig.isUrlValid(''), isFalse);
    expect(SupabaseConfig.isUrlValid('not-a-url'), isFalse);
    expect(SupabaseConfig.isUrlValid('ftp://example.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://%3Cproject-ref%3E.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://projectref123.supabase.co'), isTrue);
  });

  test('SupabaseConfig init returns false when unconfigured without crashing', () async {
    SupabaseConfig.setOverrides(url: '', anonKey: '');
    final result = await SupabaseConfig.init();
    expect(result, isFalse);
    expect(SupabaseConfig.isInitialized, isFalse);
    SupabaseConfig.resetOverrides();
  });
}
