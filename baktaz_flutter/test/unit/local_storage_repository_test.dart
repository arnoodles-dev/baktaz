import 'package:baktaz_flutter/core/data/repository/local_storage_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(LocalStorageRepository, () {
    late MockFlutterSecureStorage securedStorage;
    late MockSharedPreferences unsecuredStorage;
    late MockTalker talker;
    late LocalStorageRepository localStorageRepository;

    setUp(() {
      securedStorage = MockFlutterSecureStorage();
      unsecuredStorage = MockSharedPreferences();
      talker = MockTalker();
      localStorageRepository = LocalStorageRepository(securedStorage, unsecuredStorage, talker);
    });

    tearDown(() {
      reset(securedStorage);
      reset(unsecuredStorage);
      reset(talker);
    });

    group('getAccessToken', () {
      test('returns Right with token when stored', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenAnswer((_) async => 'token123');

        final Either<Failure, String?> result = await localStorageRepository.getAccessToken().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (String? token) => expect(token, equals('token123')));
        verify(securedStorage.read(key: 'access_token')).called(1);
      });

      test('returns Right with null when no token stored', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);

        final Either<Failure, String?> result = await localStorageRepository.getAccessToken().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (String? token) => expect(token, isNull));
      });

      test('returns Left(Failure.deviceStorage) when read throws', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenThrow(Exception('Storage error'));

        final Either<Failure, String?> result = await localStorageRepository.getAccessToken().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('setAccessToken', () {
      test('writes to secure storage when value is not empty', () async {
        when(securedStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async {});

        final Either<Failure, Unit> result = await localStorageRepository.setAccessToken('new_token').run();

        expect(result.isRight(), isTrue);
        verify(securedStorage.write(key: 'access_token', value: 'new_token')).called(1);
      });

      test('does not write to secure storage when value is empty', () async {
        final Either<Failure, Unit> result = await localStorageRepository.setAccessToken('').run();

        expect(result.isRight(), isTrue);
        verifyNever(securedStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      });

      test('returns Left(Failure.deviceStorage) when write throws', () async {
        when(securedStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setAccessToken('token').run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('deleteAccessToken', () {
      test('deletes from secure storage', () async {
        when(securedStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

        final Either<Failure, Unit> result = await localStorageRepository.deleteAccessToken().run();

        expect(result.isRight(), isTrue);
        verify(securedStorage.delete(key: 'access_token')).called(1);
      });

      test('returns Left(Failure.deviceStorage) when delete throws', () async {
        when(securedStorage.delete(key: anyNamed('key'))).thenThrow(Exception('Delete error'));

        final Either<Failure, Unit> result = await localStorageRepository.deleteAccessToken().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('getRefreshToken', () {
      test('returns Right with refresh token when stored', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenAnswer((_) async => 'refresh123');

        final Either<Failure, String?> result = await localStorageRepository.getRefreshToken().run();

        expect(result.isRight(), isTrue);
        result.fold(
          (Failure failure) => fail('Expected Right'),
          (String? token) => expect(token, equals('refresh123')),
        );
        verify(securedStorage.read(key: 'refresh_token')).called(1);
      });

      test('returns Right with null when no token stored', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);

        final Either<Failure, String?> result = await localStorageRepository.getRefreshToken().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (String? token) => expect(token, isNull));
      });

      test('returns Left(Failure.deviceStorage) when read throws', () async {
        when(securedStorage.read(key: anyNamed('key'))).thenThrow(Exception('Storage error'));

        final Either<Failure, String?> result = await localStorageRepository.getRefreshToken().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('setRefreshToken', () {
      test('writes to secure storage when value is not empty', () async {
        when(securedStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async {});

        final Either<Failure, Unit> result = await localStorageRepository.setRefreshToken('new_refresh').run();

        expect(result.isRight(), isTrue);
        verify(securedStorage.write(key: 'refresh_token', value: 'new_refresh')).called(1);
      });

      test('does not write to secure storage when value is empty', () async {
        final Either<Failure, Unit> result = await localStorageRepository.setRefreshToken('').run();

        expect(result.isRight(), isTrue);
        verifyNever(securedStorage.write(key: anyNamed('key'), value: anyNamed('value')));
      });

      test('returns Left(Failure.deviceStorage) when write throws', () async {
        when(securedStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setRefreshToken('refresh').run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('deleteRefreshToken', () {
      test('deletes from secure storage', () async {
        when(securedStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

        final Either<Failure, Unit> result = await localStorageRepository.deleteRefreshToken().run();

        expect(result.isRight(), isTrue);
        verify(securedStorage.delete(key: 'refresh_token')).called(1);
      });

      test('returns Left(Failure.deviceStorage) when delete throws', () async {
        when(securedStorage.delete(key: anyNamed('key'))).thenThrow(Exception('Delete error'));

        final Either<Failure, Unit> result = await localStorageRepository.deleteRefreshToken().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('getIsOnboardingDone', () {
      test('returns Right with true when onboarding is done', () async {
        when(unsecuredStorage.getBool(any)).thenReturn(true);

        final Either<Failure, bool?> result = await localStorageRepository.getIsOnboardingDone().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (bool? value) => expect(value, isTrue));
        verify(unsecuredStorage.getBool('is_onboarding_done')).called(1);
      });

      test('returns Right with null when onboarding status is not set', () async {
        when(unsecuredStorage.getBool(any)).thenReturn(null);

        final Either<Failure, bool?> result = await localStorageRepository.getIsOnboardingDone().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (bool? value) => expect(value, isNull));
      });

      test('returns Left(Failure.deviceStorage) when getBool throws', () async {
        when(unsecuredStorage.getBool(any)).thenThrow(Exception('Storage error'));

        final Either<Failure, bool?> result = await localStorageRepository.getIsOnboardingDone().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('setIsOnboardingDone', () {
      test('writes true to shared preferences', () async {
        when(unsecuredStorage.setBool(any, any)).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await localStorageRepository.setIsOnboardingDone().run();

        expect(result.isRight(), isTrue);
        verify(unsecuredStorage.setBool('is_onboarding_done', true)).called(1);
      });

      test('returns Left(Failure.deviceStorage) when setBool throws', () async {
        when(unsecuredStorage.setBool(any, any)).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setIsOnboardingDone().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('getIsDarkMode', () {
      test('returns Right with true when dark mode is enabled', () async {
        when(unsecuredStorage.getBool(any)).thenReturn(true);

        final Either<Failure, bool?> result = await localStorageRepository.getIsDarkMode().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (bool? value) => expect(value, isTrue));
      });

      test('returns Right with null when dark mode is not set', () async {
        when(unsecuredStorage.getBool(any)).thenReturn(null);

        final Either<Failure, bool?> result = await localStorageRepository.getIsDarkMode().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (bool? value) => expect(value, isNull));
      });

      test('returns Left(Failure.deviceStorage) when getBool throws', () async {
        when(unsecuredStorage.getBool(any)).thenThrow(Exception('Storage error'));

        final Either<Failure, bool?> result = await localStorageRepository.getIsDarkMode().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('setIsDarkMode', () {
      test('writes dark mode flag to shared preferences', () async {
        when(unsecuredStorage.setBool(any, any)).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await localStorageRepository.setIsDarkMode(isDarkMode: true).run();

        expect(result.isRight(), isTrue);
        verify(unsecuredStorage.setBool('is_dark_mode', true)).called(1);
      });

      test('returns Left(Failure.deviceStorage) when setBool throws', () async {
        when(unsecuredStorage.setBool(any, any)).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setIsDarkMode(isDarkMode: false).run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('getOtaLocalizationVersion', () {
      test('returns Right with version when stored', () async {
        when(unsecuredStorage.getInt(any)).thenReturn(42);

        final Either<Failure, int?> result = await localStorageRepository.getOtaLocalizationVersion().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (int? value) => expect(value, equals(42)));
        verify(unsecuredStorage.getInt('ota_localization_version')).called(1);
      });

      test('returns Right with null when version is not stored', () async {
        when(unsecuredStorage.getInt(any)).thenReturn(null);

        final Either<Failure, int?> result = await localStorageRepository.getOtaLocalizationVersion().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (int? value) => expect(value, isNull));
      });

      test('returns Left(Failure.deviceStorage) when getInt throws', () async {
        when(unsecuredStorage.getInt(any)).thenThrow(Exception('Storage error'));

        final Either<Failure, int?> result = await localStorageRepository.getOtaLocalizationVersion().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('setOtaLocalizationVersion', () {
      test('writes version to shared preferences', () async {
        when(unsecuredStorage.setInt(any, any)).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await localStorageRepository.setOtaLocalizationVersion(42).run();

        expect(result.isRight(), isTrue);
        verify(unsecuredStorage.setInt('ota_localization_version', 42)).called(1);
      });

      test('returns Left(Failure.deviceStorage) when setInt throws', () async {
        when(unsecuredStorage.setInt(any, any)).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setOtaLocalizationVersion(42).run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('getOtaLocalizationOverrides', () {
      test('returns Right with overrides string when stored', () async {
        const String jsonStr = '{"auth.loginButton":"Sign in"}';
        when(unsecuredStorage.getString(any)).thenReturn(jsonStr);

        final Either<Failure, String?> result = await localStorageRepository.getOtaLocalizationOverrides().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (String? value) => expect(value, equals(jsonStr)));
        verify(unsecuredStorage.getString('ota_localization_overrides')).called(1);
      });

      test('returns Right with null when overrides not set', () async {
        when(unsecuredStorage.getString(any)).thenReturn(null);

        final Either<Failure, String?> result = await localStorageRepository.getOtaLocalizationOverrides().run();

        expect(result.isRight(), isTrue);
        result.fold((Failure failure) => fail('Expected Right'), (String? value) => expect(value, isNull));
      });

      test('returns Left(Failure.deviceStorage) when getString throws', () async {
        when(unsecuredStorage.getString(any)).thenThrow(Exception('Storage error'));

        final Either<Failure, String?> result = await localStorageRepository.getOtaLocalizationOverrides().run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });

    group('setOtaLocalizationOverrides', () {
      test('writes overrides JSON string to shared preferences', () async {
        const String jsonStr = '{"auth.loginButton":"Sign in"}';
        when(unsecuredStorage.setString(any, any)).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await localStorageRepository.setOtaLocalizationOverrides(jsonStr).run();

        expect(result.isRight(), isTrue);
        verify(unsecuredStorage.setString('ota_localization_overrides', jsonStr)).called(1);
      });

      test('returns Left(Failure.deviceStorage) when setString throws', () async {
        const String jsonStr = '{"auth.loginButton":"Sign in"}';
        when(unsecuredStorage.setString(any, any)).thenThrow(Exception('Write error'));

        final Either<Failure, Unit> result = await localStorageRepository.setOtaLocalizationOverrides(jsonStr).run();

        expect(result.isLeft(), isTrue);
        result.fold((Failure failure) => expect(failure, isA<DeviceStorageFailure>()), (_) => fail('Expected Left'));
      });
    });
  });
}
