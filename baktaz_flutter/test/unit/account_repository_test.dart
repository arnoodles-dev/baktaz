import 'package:baktaz_client/baktaz_client.dart' as serverpod_dto;
import 'package:baktaz_flutter/features/account/data/repository/account_repository.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:retry/retry.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AccountRepository, () {
    late MockServerpod serverpod;
    late MockClient client;
    late MockEndpointAccount endpointAccount;
    late MockEndpointProfile endpointProfile;
    late MockTalker talker;
    late AccountRepository accountRepository;

    setUp(() {
      serverpod = MockServerpod();
      client = MockClient();
      endpointAccount = MockEndpointAccount();
      endpointProfile = MockEndpointProfile();
      talker = MockTalker();

      when(serverpod.client).thenReturn(client);
      when(client.account).thenReturn(endpointAccount);
      when(client.profile).thenReturn(endpointProfile);

      accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);
    });

    group('getAccountSummary', () {
      test('should return Right(AccountSummary) when client returns data successfully', () async {
        final serverpod_dto.AccountSummary summaryDto = serverpod_dto.AccountSummary(
          userId: serverpod_dto.UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
          isPremium: true,
          totalSteps: 1000,
          activeChallengeCount: 2,
          fullName: 'John Doe',
          username: 'johndoe',
          challengesJoined: 10,
          challengesWon: 5,
          winRatePercentage: 50,
        );
        when(endpointAccount.getSummary()).thenAnswer((_) async => summaryDto);

        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        result.fold((_) => fail('Expected Right'), (AccountSummary summary) {
          expect(summary.totalSteps, equals(1000));
          expect(summary.activeChallengeCount, equals(2));
          expect(summary.isPremium, isTrue);
        });
      });

      test('should return Left(Failure.server) when network connectivity error occurs', () async {
        final Exception exception = Exception('Network connection failed');
        when(endpointAccount.getSummary()).thenThrow(exception);

        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.server(StatusCode.serverpod, 'Exception: Network connection failed'))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('getProfile', () {
      test('should return Right(Profile) when client returns valid UserInfo', () async {
        when(endpointProfile.getProfile()).thenAnswer((_) async => mockServerProfile);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold((_) => fail('Expected Right'), (Profile profile) {
          expect(profile.fullName.value, equals(const Right<Failure, String>('John Doe')));
        });
      });

      test('should return Left(Failure.server) when profile validation fails', () async {
        final serverpod_dto.UserInfo invalidUserInfo = serverpod_dto.UserInfo(
          userIdentifier: serverpod_dto.UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
          email: 'invalid-email',
          username: '',
          firstName: '',
          lastName: '',
        );
        when(endpointProfile.getProfile()).thenAnswer((_) async => invalidUserInfo);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold(
          (Failure failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('should return Left(Failure.server) when client returns null profile', () async {
        when(endpointProfile.getProfile()).thenAnswer((_) async => null);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.server(StatusCode.serverpod, 'FormatException: Profile is null'))),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('addAddress', () {
      test('should return Left(Failure.unexpected) as unimplemented', () async {
        final Address dummyAddress = Address(id: UniqueId(), street: '123 Main St');

        final Either<Failure, Unit> result = await accountRepository.addAddress(dummyAddress).run();

        result.fold(
          (Failure failure) => expect(failure, equals(const Failure.unexpected('Not implemented'))),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getDefaultAddress', () {
      test('should return Right(null)', () async {
        final Either<Failure, Address?> result = await accountRepository.getDefaultAddress().run();

        result.fold((_) => fail('Expected Right'), (Address? address) => expect(address, isNull));
      });
    });

    group('deleteAccount', () {
      test('should return Right(unit) when deleteAccount endpoint succeeds', () async {
        when(endpointAccount.deleteAccount()).thenAnswer((_) async => true);

        final Either<Failure, Unit> result = await accountRepository.deleteAccount().run();

        result.fold((_) => fail('Expected Right'), (Unit val) => expect(val, equals(unit)));
        verify(endpointAccount.deleteAccount()).called(1);
      });

      test('should return Left(Failure.server) when deleteAccount endpoint throws', () async {
        final Exception exception = Exception('Account deletion failed');
        when(endpointAccount.deleteAccount()).thenThrow(exception);

        final Either<Failure, Unit> result = await accountRepository.deleteAccount().run();

        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.server(StatusCode.serverpod, 'Exception: Account deletion failed'))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(exception, any)).called(1);
      });
    });
  });
}
