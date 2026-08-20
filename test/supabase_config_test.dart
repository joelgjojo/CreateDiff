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
      url: '  "https://myproject.supabase.co"  ',
      anonKey: '  \'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.testkey123456\'  ',
    );

    expect(SupabaseConfig.url, 'https://myproject.supabase.co');
    expect(SupabaseConfig.anonKey, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.testkey123456');
    expect(SupabaseConfig.isConfigured, isTrue);

    final diag = SupabaseConfig.diagnosticStatus;
    expect(diag['supabaseConfigured'], isTrue);
    expect(diag['host'], 'myproject.supabase.co');
    // Ensure actual anonKey or secrets are NEVER exposed in diagnostics
    expect(diag.containsKey('anonKey'), isFalse);
    expect(diag.containsKey('key'), isFalse);
    expect(diag.containsKey('jwt'), isFalse);
    expect(diag.containsKey('password'), isFalse);

    SupabaseConfig.resetOverrides();
  });

  test('SupabaseConfig strictly rejects placeholder markers in SUPABASE_URL', () {
    // Tests for: <, >, %3c, %3e, project-ref
    expect(SupabaseConfig.isUrlValid('https://<project-ref>.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://%3Cproject-ref%3E.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://project-ref.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://<my-project>.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://my>project.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://%3cmyproject%3e.supabase.co'), isFalse);
    expect(SupabaseConfig.isUrlValid('https://your_project.supabase.co'), isFalse);

    // Valid HTTPS host
    expect(SupabaseConfig.isUrlValid('https://abcdefghijklmno.supabase.co'), isTrue);

    SupabaseConfig.setOverrides(
      url: 'https://<project-ref>.supabase.co',
      anonKey: '<your_supabase_anon_public_key>',
    );
    expect(SupabaseConfig.isConfigured, isFalse);

    final diag = SupabaseConfig.diagnosticStatus;
    expect(diag['supabaseConfigured'], isFalse);
    expect(diag['host'], 'none');

    SupabaseConfig.resetOverrides();
  });

  test('SupabaseConfig validates URL structure and schemes', () {
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
