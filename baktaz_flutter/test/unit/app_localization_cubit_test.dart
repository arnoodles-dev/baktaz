import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AppLocalizationCubit, () {
    late MockIRemoteConfigService remoteConfigService;
    late MockFailureHandler failureHandler;

    setUp(() {
      remoteConfigService = MockIRemoteConfigService();
      failureHandler = MockFailureHandler();
    });

    tearDown(() {
      reset(remoteConfigService);
      reset(failureHandler);
    });

    test('initializes with device locale as default state', () async {
      when(remoteConfigService.getString(any)).thenAnswer((_) async => null);
      final AppLocalizationCubit cubit = AppLocalizationCubit(remoteConfigService, failureHandler);

      // Wait for async initialization
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      await cubit.close();
    });

    test('loads localization with remote config when available', () async {
      when(remoteConfigService.getString(any)).thenAnswer((_) async => '{"appName": "Remote App Name"}');
      final AppLocalizationCubit cubit = AppLocalizationCubit(remoteConfigService, failureHandler);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      verify(remoteConfigService.getString(any)).called(greaterThanOrEqualTo(1));
      await cubit.close();
    });

    test('falls back to local locale when getString throws', () async {
      when(remoteConfigService.getString(any)).thenThrow(Exception('Remote config failed'));

      final AppLocalizationCubit cubit = AppLocalizationCubit(remoteConfigService, failureHandler);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // I18nLoader swallows the error internally and falls back to local
      expect(cubit.stateValue, isA<I18n>());
      verifyNever(failureHandler.handleException(any, any));
      await cubit.close();
    });

    test('uses local fallback when remote config returns null', () async {
      when(remoteConfigService.getString(any)).thenAnswer((_) async => null);
      final AppLocalizationCubit cubit = AppLocalizationCubit(remoteConfigService, failureHandler);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      await cubit.close();
    });
  });
}
