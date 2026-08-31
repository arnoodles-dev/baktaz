import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/core/data/repository/remote_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.dart';

void main() {
  late MockILocalStorageRepository localStorageRepository;
  late MockClient client;
  late MockEndpointRemoteLocalization remoteLocEndpoint;
  late MockFailureHandler failureHandler;
  late RemoteLocalizationRepository repository;

  setUp(() {
    localStorageRepository = MockILocalStorageRepository();
    client = MockClient();
    remoteLocEndpoint = MockEndpointRemoteLocalization();
    failureHandler = MockFailureHandler();
    when(client.remoteLocalization).thenReturn(remoteLocEndpoint);
    repository = RemoteLocalizationRepository(client, localStorageRepository, failureHandler);
  });

  group('RemoteLocalizationRepository Tests', () {
    test('getCachedOverrides reads from LocalStorageRepository', () async {
      const String jsonStr = '{"auth.loginButton":"Sign in"}';
      when(localStorageRepository.getOtaLocalizationOverrides())
          .thenReturn(TaskResult<String?>.of(jsonStr));

      final Either<Failure, String?> result = await repository.getCachedOverrides().run();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (String? r) => expect(r, equals(jsonStr)));
    });

    test('syncRemoteLocalization fetches payload and updates storage when release updated', () async {
      when(localStorageRepository.getOtaLocalizationVersion())
          .thenReturn(TaskResult<int?>.of(1));
      when(remoteLocEndpoint.get(1)).thenAnswer(
        (_) async => RemoteLocalizationResponse(
          version: 2,
          updated: true,
          checksum: 'sha256:123',
          overridesJson: '{"auth.loginButton":"Sign In Now"}',
        ),
      );
      when(localStorageRepository.setOtaLocalizationVersion(2))
          .thenReturn(TaskResult<Unit>.of(unit));
      when(localStorageRepository.setOtaLocalizationOverrides('{"auth.loginButton":"Sign In Now"}'))
          .thenReturn(TaskResult<Unit>.of(unit));

      final Either<Failure, bool> result = await repository.syncRemoteLocalization().run();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (bool r) => expect(r, isTrue));
      verify(localStorageRepository.setOtaLocalizationVersion(2)).called(1);
      verify(localStorageRepository.setOtaLocalizationOverrides('{"auth.loginButton":"Sign In Now"}')).called(1);
    });

    test('syncRemoteLocalization returns false when release is not updated', () async {
      when(localStorageRepository.getOtaLocalizationVersion())
          .thenReturn(TaskResult<int?>.of(2));
      when(remoteLocEndpoint.get(2)).thenAnswer(
        (_) async => RemoteLocalizationResponse(
          version: 2,
          updated: false,
          checksum: 'sha256:123',
        ),
      );

      final Either<Failure, bool> result = await repository.syncRemoteLocalization().run();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('Should succeed'), (bool r) => expect(r, isFalse));
      verifyNever(localStorageRepository.setOtaLocalizationVersion(any));
    });

    test('syncRemoteLocalization catches network errors and reports via FailureHandler', () async {
      when(localStorageRepository.getOtaLocalizationVersion())
          .thenReturn(TaskResult<int?>.of(1));
      when(remoteLocEndpoint.get(1)).thenThrow(Exception('Network Error'));

      final Either<Failure, bool> result = await repository.syncRemoteLocalization().run();

      expect(result.isLeft(), isTrue);
      result.fold((Failure l) => expect(l, isA<Failure>()), (_) => fail('Should fail'));
      verify(failureHandler.handleException(any, any)).called(1);
    });

    test('clearCachedOverrides resets version to 0 and overrides to empty string', () async {
      when(localStorageRepository.setOtaLocalizationVersion(0))
          .thenReturn(TaskResult<Unit>.of(unit));
      when(localStorageRepository.setOtaLocalizationOverrides(''))
          .thenReturn(TaskResult<Unit>.of(unit));

      final Either<Failure, Unit> result = await repository.clearCachedOverrides().run();

      expect(result.isRight(), isTrue);
      verify(localStorageRepository.setOtaLocalizationVersion(0)).called(1);
      verify(localStorageRepository.setOtaLocalizationOverrides('')).called(1);
    });
  });
}
