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
    expect(SupabaseConfig.isConfigured, isFalse);

    SupabaseConfig.setOverrides(
      url: '  "https://example.supabase.co"  ',
      anonKey: '  \'anon-key-12345\'  ',
    );

    expect(SupabaseConfig.url, 'https://example.supabase.co');
    expect(SupabaseConfig.anonKey, 'anon-key-12345');
    expect(SupabaseConfig.isConfigured, isTrue);

    SupabaseConfig.resetOverrides();
    expect(SupabaseConfig.isConfigured, isFalse);
  });

  test('SupabaseConfig init returns false when unconfigured without crashing', () async {
    SupabaseConfig.resetOverrides();
    final result = await SupabaseConfig.init();
    expect(result, isFalse);
    expect(SupabaseConfig.isInitialized, isFalse);
  });
}
