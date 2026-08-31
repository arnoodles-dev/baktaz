import 'package:baktaz_server/src/app/utils/seeding_utils.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RemoteConfigEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    test('getRemoteConfig returns valid default values when seeded', () async {
      final Session session = sessionBuilder.build();
      await seedRemoteConfig(session);

      final RemoteConfig config = await endpoints.remoteConfig.getRemoteConfig(
        sessionBuilder,
        appVersion: '1.0.0',
        platform: 'android',
      );

      expect(config, isNotNull);
      expect(config.config.containsKey('is_maintenance'), isTrue);
      expect(config.config['is_maintenance']?.value, equals('false'));
      expect(config.config['min_supported_version']?.value, equals('1.0.0'));
      expect(config.config['enable_chat']?.value, equals('true'));
      expect(config.version, isNotNull);
      expect(config.version.versionNumber, equals('1.0.0'));
    });
  });
}
