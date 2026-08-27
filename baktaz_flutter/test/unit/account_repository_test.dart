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
    late MockTalker talker;
    late RetryOptions retryOptions;
    late AccountRepository accountRepository;

    setUp(() {
      serverpod = MockServerpod();
      client = MockClient();
      endpointAccount = MockEndpointAccount();
      talker = MockTalker();
      retryOptions = const RetryOptions(maxAttempts: 1);

      when(serverpod.client).thenReturn(client);
      when(client.account).thenReturn(endpointAccount);

      accountRepository = AccountRepository(serverpod, retryOptions, talker);
    });

    tearDown(() {
      reset(serverpod);
      reset(client);
      reset(endpointAccount);
      reset(talker);
    });

    group('getAccountSummary', () {
      test('should return Right(AccountSummary) when client returns valid server model', () async {
        // Arrange
        when(endpointAccount.getAccountSummary()).thenAnswer((_) async => mockServerAccountSummary);

        // Act
        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (AccountSummary summary) {
          expect(summary.name.value, equals(const Right<Failure, String>('John Doe')));
          expect(summary.balance.value, equals(const Right<Failure, double>(250.75)));
          expect(summary.connect.value, equals(const Right<Failure, int>(100)));
        });
        verify(endpointAccount.getAccountSummary()).called(1);
      });

      test('should return Right(AccountSummary) when imageUrl is null', () async {
        // Arrange
        when(endpointAccount.getAccountSummary()).thenAnswer((_) async => mockServerAccountSummaryNullUrl);

        // Act
        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (AccountSummary summary) {
          expect(summary.imageUrl, isNull);
        });
        verify(endpointAccount.getAccountSummary()).called(1);
      });

      test('should return Left(Failure.server) when client returns null', () async {
        // Arrange
        when(endpointAccount.getAccountSummary()).thenAnswer((_) async => null);

        // Act
        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) =>
              expect(failure, equals(const Failure.server(StatusCode.serverpod, 'FormatException: Account summary is null'))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(any, any)).called(1);
      });

      test('should return Left(Failure.server) when network connectivity error occurs', () async {
        // Arrange
        final Exception exception = Exception('Network connection failed');
        when(endpointAccount.getAccountSummary()).thenThrow(exception);

        // Act
        final Either<Failure, AccountSummary> result = await accountRepository.getAccountSummary().run();

        // Assert
        expect(result.isLeft(), isTrue);
        verify(talker.handle(exception, any)).called(1);
      });
    });

    group('getProfile', () {
      test('should return Right(Profile) when client returns valid server profile', () async {
        // Arrange
        when(endpointAccount.getProfile()).thenAnswer((_) async => mockServerProfile);

        // Act
        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (Profile profile) {
          expect(profile.fullName.value, equals(const Right<Failure, String>('John Doe')));
          expect(profile.gender, equals(serverpod_dto.Gender.male));
        });
        verify(endpointAccount.getProfile()).called(1);
      });

      test('should return Left(Failure.server) when client returns null profile', () async {
        // Arrange
        when(endpointAccount.getProfile()).thenAnswer((_) async => null);

        // Act
        final Either<Failure, Profile> result = await accountRepository.getProfile().run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) => expect(failure, equals(const Failure.server(StatusCode.serverpod, 'FormatException: Profile is null'))),
          (_) => fail('Expected Left'),
        );
        verify(talker.handle(any, any)).called(1);
      });
    });

    group('addAddress', () {
      test('should return Left(Failure.unexpected) as unimplemented', () async {
        // Arrange
        final Address dummyAddress = Address(id: UniqueId(), street: '123 Main St');

        // Act
        final Either<Failure, Unit> result = await accountRepository.addAddress(dummyAddress).run();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (Failure failure) => expect(failure, equals(const Failure.unexpected('Not implemented'))),
          (_) => fail('Expected Left'),
        );
      });
    });

    group('getDefaultAddress', () {
      test('should return Right(null)', () async {
        // Act
        final Either<Failure, Address?> result = await accountRepository.getDefaultAddress().run();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((_) => fail('Expected Right'), (Address? address) => expect(address, isNull));
      });
    });
  });
}
