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

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AccountRepository, () {
    late MockServerpod serverpod;
    late MockClient client;
    late MockEndpointAccount endpointAccount;
    late MockEndpointProfile endpointProfile;
    late MockTalker talker;

    final serverpod_dto.UuidValue userId = serverpod_dto.UuidValue.fromString('123e4567-e89b-12d3-a456-426614174000');
    final serverpod_dto.AccountSummary serverpodAccountSummary = serverpod_dto.AccountSummary(
      userId: userId,
      isPremium: true,
      totalSteps: 100000,
      activeChallengeCount: 2,
      fullName: 'John Doe',
      username: 'johndoe',
      avatarUrl: 'https://example.com/avatar.png',
      challengesJoined: 10,
      challengesWon: 3,
      winRatePercentage: 30,
      isHostTier: true,
      isStepsSyncActive: false,
      memberSince: DateTime(2024, 1, 15),
      avgStepsPerDay: 3333,
      rank: serverpod_dto.Rank.gold,
    );

    setUp(() {
      serverpod = MockServerpod();
      client = MockClient();
      endpointAccount = MockEndpointAccount();
      endpointProfile = MockEndpointProfile();
      talker = MockTalker();

      when(serverpod.client).thenReturn(client);
      when(client.account).thenReturn(endpointAccount);
      when(client.profile).thenReturn(endpointProfile);
    });

    tearDown(() {
      reset(serverpod);
      reset(client);
      reset(endpointAccount);
      reset(endpointProfile);
      reset(talker);
    });

    group('getAccountSummary', () {
      test('should return Right(AccountSummary) when successful', () async {
        when(endpointAccount.getSummary()).thenAnswer((_) async => serverpodAccountSummary);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        result.fold((_) => fail('Expected Right'), (AccountSummary summary) {
          expect(summary.userId, equals(userId));
          expect(summary.isPremium, equals(true));
          expect(summary.totalSteps, equals(100000));
          expect(summary.challengesJoined, equals(10));
          expect(summary.challengesWon, equals(3));
        });

        verify(endpointAccount.getSummary()).called(1);
      });

      test('should return Left(Failure.server) when network connectivity error occurs', () async {
        final Exception exception = Exception('Network connection failed');
        when(endpointAccount.getSummary()).thenThrow(exception);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

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
      test('should return Right(Profile) when successful', () async {
        final serverpod_dto.UserInfo serverpodUserInfo = serverpod_dto.UserInfo(
          userIdentifier: userId,
          email: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          username: 'johndoe',
          gender: serverpod_dto.Gender.male,
          mobileNumber: '+1234567890',
        );

        when(endpointProfile.getProfile()).thenAnswer((_) async => serverpodUserInfo);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold((_) => fail('Expected Right'), (Profile profile) {
          expect(profile.fullName.value, equals(const Right<Failure, String>('John Doe')));
        });

        verify(endpointProfile.getProfile()).called(1);
      });

      test('should return Left(Failure.server) when profile validation fails', () async {
        final serverpod_dto.UserInfo serverpodUserInfo = serverpod_dto.UserInfo(
          userIdentifier: userId,
          email: 'invalid-email',
          firstName: 'John',
          lastName: 'Doe',
          username: 'johndoe',
          gender: serverpod_dto.Gender.male,
          mobileNumber: '+1234567890',
        );

        when(endpointProfile.getProfile()).thenAnswer((_) async => serverpodUserInfo);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold(
          (Failure failure) => expect(failure, isA<Failure>()),
          (_) => fail('Expected Left'),
        );

        verify(endpointProfile.getProfile()).called(1);
      });

      test('should return Left(Failure.server) when client returns null profile', () async {
        when(endpointProfile.getProfile()).thenAnswer((_) async => null);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.server(StatusCode.serverpod, 'FormatException: Profile is null'))),
          (_) => fail('Expected Left'),
        );

        verify(endpointProfile.getProfile()).called(1);
      });
    });

    group('addAddress', () {
      test('should return Left(Failure.unexpected) as unimplemented', () async {
        final Address dummyAddress = Address(
          id: UniqueId.fromUniqueString('1'),
          label: ValueName('Home'),
          street: '123 Main St',
          locality: 'New York',
          administrativeArea: 'NY',
          postalCode: '10001',
          country: 'USA',
        );

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Unit> result = await accountRepository.addAddress(dummyAddress).run();

        result.fold(
          (Failure failure) => expect(failure, equals(const Failure.unexpected('Not implemented'))),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getDefaultAddress', () {
      test('should return Right(null) as unimplemented', () async {
        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Address?> result = await accountRepository.getDefaultAddress().run();

        result.fold((_) => fail('Expected Right'), (Address? address) => expect(address, isNull));
      });
    });

    group('deleteAccount', () {
      test('should return Right(unit) when successful', () async {
        when(endpointAccount.deleteAccount()).thenAnswer((_) async => unit);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

        final Either<Failure, Unit> result = await accountRepository.deleteAccount().run();

        result.fold((_) => fail('Expected Right'), (Unit val) => expect(val, equals(unit)));

        verify(endpointAccount.deleteAccount()).called(1);
      });

      test('should return Left(Failure.server) when deleteAccount endpoint throws', () async {
        final Exception exception = Exception('Account deletion failed');
        when(endpointAccount.deleteAccount()).thenThrow(exception);

        final AccountRepository accountRepository = AccountRepository(serverpod, const RetryOptions(maxAttempts: 1), talker);

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
