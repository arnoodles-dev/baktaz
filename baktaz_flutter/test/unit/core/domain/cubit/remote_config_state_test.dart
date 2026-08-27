import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteConfigState', () {
    test('exposes typed getters from raw values', () {
      const RemoteConfigState state = RemoteConfigState(
        values: <String, dynamic>{
          'is_maintenance': true,
          'min_supported_version': '1.2.0',
          'android_store_url': 'https://play.example',
        },
      );

      expect(state.isMaintenance, isTrue);
      expect(state.minSupportedVersion, '1.2.0');
      expect(state.androidStoreUrl, 'https://play.example');
      expect(state.iosStoreUrl, isNull);
      expect(state.value('terms_condition_url'), isNull);
    });

    test('defaults are safe', () {
      const RemoteConfigState state = RemoteConfigState();

      expect(state.isMaintenance, isFalse);
      expect(state.minSupportedVersion, isNull);
    });
  });
}
