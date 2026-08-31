import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/app/utils/seeding_utils.dart';
import 'package:baktaz_server/src/features/remote_localization/endpoint/remote_localization_endpoint.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../test_tools/serverpod_test_tools.dart';

void main() {
  setUpAll(configureDependencies);

  withServerpod('Given RemoteLocalizationEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    test('requireLogin is explicitly false for unauthenticated client access', () {
      final RemoteLocalizationEndpoint endpoint = RemoteLocalizationEndpoint();
      expect(endpoint.requireLogin, isFalse);
    });

    test('get returns seeded payload when client version differs', () async {
      final Session session = sessionBuilder.build();
      await seedRemoteLocalization(session);

      final RemoteLocalizationResponse fetched =
          await endpoints.remoteLocalization.get(sessionBuilder, 0);
      expect(fetched.version, equals(1));
      expect(fetched.updated, isTrue);
      expect(fetched.overridesJson, isNotNull);
      expect(fetched.overridesJson, contains('common.error.generic'));

      final RemoteLocalizationResponse sameVersion =
          await endpoints.remoteLocalization.get(sessionBuilder, 1);
      expect(sameVersion.version, equals(1));
      expect(sameVersion.updated, isFalse);
      expect(sameVersion.overridesJson, isNull);
    });
  });
}
