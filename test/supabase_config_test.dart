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
      anonKey: '  \'anon-key-12345\'  ',
    );

    expect(SupabaseConfig.url, 'https://example.supabase.co');
    expect(SupabaseConfig.anonKey, 'anon-key-12345');
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

  test('SupabaseConfig init returns false when unconfigured without crashing', () async {
    SupabaseConfig.setOverrides(url: '', anonKey: '');
    final result = await SupabaseConfig.init();
    expect(result, isFalse);
    expect(SupabaseConfig.isInitialized, isFalse);
    SupabaseConfig.resetOverrides();
  });
}
