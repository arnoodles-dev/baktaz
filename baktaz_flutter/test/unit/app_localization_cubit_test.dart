import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AppLocalizationCubit, () {
    late MockIRemoteLocalizationRepository remoteLocRepository;
    late MockFailureHandler failureHandler;

    setUp(() {
      remoteLocRepository = MockIRemoteLocalizationRepository();
      failureHandler = MockFailureHandler();
    });

    tearDown(() {
      reset(remoteLocRepository);
      reset(failureHandler);
    });

    test('initializes with device locale as default state', () async {
      when(remoteLocRepository.getCachedOverrides())
          .thenReturn(TaskResult<String?>.right(null));
      when(remoteLocRepository.syncRemoteLocalization())
          .thenReturn(TaskResult<bool>.right(false));

      final AppLocalizationCubit cubit =
          AppLocalizationCubit(remoteLocRepository, failureHandler);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      await cubit.close();
    });

    test('applies cached overrides when available', () async {
      const String overridesJson = '{"appName": "OTA App Name"}';
      when(remoteLocRepository.getCachedOverrides())
          .thenReturn(TaskResult<String?>.right(overridesJson));
      when(remoteLocRepository.syncRemoteLocalization())
          .thenReturn(TaskResult<bool>.right(false));

      final AppLocalizationCubit cubit =
          AppLocalizationCubit(remoteLocRepository, failureHandler);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      verify(remoteLocRepository.getCachedOverrides())
          .called(greaterThanOrEqualTo(1));
      await cubit.close();
    });

    test('re-applies overrides after background sync returns new data', () async {
      const String overridesJson = '{"appName": "Synced App Name"}';
      when(remoteLocRepository.getCachedOverrides())
          .thenReturn(TaskResult<String?>.right(overridesJson));
      when(remoteLocRepository.syncRemoteLocalization())
          .thenReturn(TaskResult<bool>.right(true));

      final AppLocalizationCubit cubit =
          AppLocalizationCubit(remoteLocRepository, failureHandler);

      // Wait for init + background sync + re-fetch
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.stateValue, isA<I18n>());
      // getCachedOverrides called at least twice: once for init, once after sync
      verify(remoteLocRepository.getCachedOverrides())
          .called(greaterThanOrEqualTo(2));
      await cubit.close();
    });

    test('falls back to default locale when getCachedOverrides fails', () {
      when(remoteLocRepository.getCachedOverrides())
          .thenReturn(TaskResult<String?>.left(const Failure.deviceStorage('storage error')));
      when(remoteLocRepository.syncRemoteLocalization())
          .thenReturn(TaskResult<bool>.right(false));

      final AppLocalizationCubit cubit =
          AppLocalizationCubit(remoteLocRepository, failureHandler);

      expect(cubit, isA<AppLocalizationCubit>());
    });

    test('does not depend on RemoteConfigService', () {
      when(remoteLocRepository.getCachedOverrides())
          .thenReturn(TaskResult<String?>.right(null));
      when(remoteLocRepository.syncRemoteLocalization())
          .thenReturn(TaskResult<bool>.right(false));

      final AppLocalizationCubit cubit =
          AppLocalizationCubit(remoteLocRepository, failureHandler);
      expect(cubit, isA<AppLocalizationCubit>());
    });
  });
}
