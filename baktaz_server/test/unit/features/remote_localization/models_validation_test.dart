import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteLocalization Models Validation', () {
    test('instantiates RemoteLocalizationRelease with snapshot payload', () {
      final RemoteLocalizationRelease release = RemoteLocalizationRelease(
        version: 1,
        publishedBy: 'admin@baktaz.com',
        publishedAt: DateTime.utc(2026, 8, 30),
        active: true,
        notes: 'Initial release',
        payloadJson: '{"auth.loginButton":"Sign in"}',
        checksum: 'sha256:abc123hash',
      );

      expect(release.version, equals(1));
      expect(release.active, isTrue);
      expect(release.checksum, equals('sha256:abc123hash'));
    });

    test('instantiates RemoteLocalizationAuditLog with action details', () {
      final RemoteLocalizationAuditLog audit = RemoteLocalizationAuditLog(
        timestamp: DateTime.utc(2026, 8, 30),
        author: 'admin@baktaz.com',
        action: 'PUBLISH_RELEASE',
        details: 'Published version 1',
      );

      expect(audit.action, equals('PUBLISH_RELEASE'));
      expect(audit.author, equals('admin@baktaz.com'));
    });

    test('instantiates RemoteLocalizationResponse payload for RPC', () {
      final RemoteLocalizationResponse response = RemoteLocalizationResponse(
        version: 1,
        updated: true,
        checksum: 'sha256:abc123hash',
        overridesJson: '{"auth.loginButton":"Sign in"}',
      );

      expect(response.version, equals(1));
      expect(response.updated, isTrue);
      expect(response.overridesJson, isNotNull);
    });
  });
}
