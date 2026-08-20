import 'package:flutter_test/flutter_test.dart';
import 'package:creatediff/services/admin_service.dart';

void main() {
  group('AdminService Models', () {
    test('AdminStats fromJson correctly parses all fields', () {
      final json = {
        'total_users': 42,
        'total_generations': 150,
        'total_campaigns': 12,
        'failed_generations': 0,
        'app_version': '3.5.0',
        'backend_status': 'operational',
      };

      final stats = AdminStats.fromJson(json);
      expect(stats.totalUsers, 42);
      expect(stats.totalGenerations, 150);
      expect(stats.totalCampaigns, 12);
      expect(stats.failedGenerations, 0);
      expect(stats.appVersion, '3.5.0');
      expect(stats.backendStatus, 'operational');
    });

    test('AdminStats fromJson gracefully handles missing fields with defaults', () {
      final stats = AdminStats.fromJson({});
      expect(stats.totalUsers, 0);
      expect(stats.totalGenerations, 0);
      expect(stats.totalCampaigns, 0);
      expect(stats.failedGenerations, 0);
      expect(stats.appVersion, '3.5.0');
      expect(stats.backendStatus, 'operational');
    });

    test('AdminUserItem fromJson parses valid user and timestamps', () {
      final json = {
        'id': 'usr-12345',
        'auth_subject': 'sub-67890',
        'email': 'admin@creatediff.com',
        'display_name': 'Super Admin',
        'role': 'admin',
        'plan': 'pro',
        'created_at': '2026-08-20T10:00:00Z',
      };

      final user = AdminUserItem.fromJson(json);
      expect(user.id, 'usr-12345');
      expect(user.authSubject, 'sub-67890');
      expect(user.email, 'admin@creatediff.com');
      expect(user.displayName, 'Super Admin');
      expect(user.role, 'admin');
      expect(user.plan, 'pro');
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.year, 2026);
    });

    test('AdminUserItem defaults role to user when missing', () {
      final user = AdminUserItem.fromJson({'id': 'u1'});
      expect(user.role, 'user');
      expect(user.plan, 'free');
    });
  });
}
