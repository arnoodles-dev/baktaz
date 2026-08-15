// ignore_for_file: prefer-match-file-name, depend_on_referenced_packages

import 'package:baktaz_admin/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/test_utils.dart';

// ponytail: login() delegates entirely to EmailAuthController's onAuthenticated/onError
// callbacks — unit-testable only as integration. Covered by integration tests.

void main() {
  group(AuthRepository, () {
    late MockServerpod serverpod;
    late MockTalker talker;
    late MockClient mockClient;
    late AuthRepository authRepository;
    late MockFlutterAuthSessionManager mockSessionManager;
    late MockEndpointAccount mockAccountEndpoint;
    late MockEndpointEmailIdpBase mockEndpointEmailIdpBase;

    setUp(() {
      serverpod = MockServerpod();
      talker = MockTalker();
      mockClient = MockClient();
      mockSessionManager = MockFlutterAuthSessionManager();
      mockAccountEndpoint = MockEndpointAccount();
      mockEndpointEmailIdpBase = MockEndpointEmailIdpBase();

      when(mockClient.account).thenReturn(mockAccountEndpoint);
      when(serverpod.sessionManager).thenReturn(mockSessionManager);
      when(serverpod.client).thenReturn(mockClient);
      when(mockClient.authKeyProvider).thenReturn(mockSessionManager);

      authRepository = AuthRepository(serverpod, talker);
      provideDummy<Account>(mockAccount);
      provideDummy<EndpointEmailIdpBase>(mockEndpointEmailIdpBase);
    });

    tearDown(() {
      reset(talker);
      reset(mockClient);
      reset(mockSessionManager);
      reset(mockAccountEndpoint);
      reset(mockEndpointEmailIdpBase);
      reset(serverpod);
    });

    group('login', () {
      test('should call onAuthenticated callback when EmailAuthController authentication succeeds', () async {
        final EmailAddress email = EmailAddress('admin@baktaz.com');
        final Password password = Password('validPassword123');
        final AuthSuccess mockAuthSuccess = AuthSuccess(
          authStrategy: 'email',
          token: 'dummy-token',
          authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
          scopeNames: const <String>{'user'},
        );

        when(mockSessionManager.authInfo).thenReturn(mockAuthSuccess);

        when(
          mockEndpointEmailIdpBase.login(email: anyNamed('email'), password: anyNamed('password')),
        ).thenAnswer((_) async => mockAuthSuccess);

        authRepository = AuthRepository(serverpod, talker);

        AuthSuccess? capturedAuthSuccess;
        await authRepository.login(
          email: email,
          password: password,
          onAuthenticated: (AuthSuccess? success) {
            capturedAuthSuccess = success;
          },
          onError: (_) {},
        );

        expect(capturedAuthSuccess, equals(mockAuthSuccess));
      });

      test('should call onError callback when EmailAuthController authentication fails', () async {
        final EmailAddress email = EmailAddress('error@baktaz.com');
        final Password password = Password('validPassword123');

        when(
          mockEndpointEmailIdpBase.login(email: anyNamed('email'), password: anyNamed('password')),
        ).thenThrow(EmailAccountLoginException(reason: EmailAccountLoginExceptionReason.invalidCredentials));

        authRepository = AuthRepository(serverpod, talker);

        Failure? capturedFailure;
        await authRepository.login(
          email: email,
          password: password,
          onAuthenticated: (_) {},
          onError: (Failure failure) {
            capturedFailure = failure;
          },
        );

        expect(capturedFailure, isNotNull);
        expect(capturedFailure!.message, contains('Invalid email'));
      });

      test('should handle exception from getValue and call onError', () async {
        final EmailAddress invalidEmail = EmailAddress('not-an-email');
        final Password password = Password('validPassword123');

        Failure? capturedFailure;
        await authRepository.login(
          email: invalidEmail,
          password: password,
          onAuthenticated: (_) {},
          onError: (Failure f) {
            capturedFailure = f;
          },
        );

        verify(talker.handle(any, any)).called(1);
        expect(capturedFailure, isNotNull);
      });
    });

    group('isAuthenticated', () {
      test('should return sessionManager.isAuthenticated', () {
        when(mockSessionManager.isAuthenticated).thenReturn(true);

        expect(authRepository.isAuthenticated, true);

        when(mockSessionManager.isAuthenticated).thenReturn(false);

        expect(authRepository.isAuthenticated, false);
      });
    });

    group('logout', () {
      test('should return unit when successful', () async {
        when(mockSessionManager.signOutDevice()).thenAnswer((_) async => true);

        final Result<Unit> result = await authRepository.logout().run();

        expect(result, isA<Right<Failure, Unit>>());
        verify(mockSessionManager.signOutDevice()).called(1);
      });

      test('should return failure when sign out throws exception', () async {
        when(mockSessionManager.signOutDevice()).thenThrow(Exception('Sign out failed'));

        final Result<Unit> result = await authRepository.logout().run();

        expect(result, isA<Left<Failure, Unit>>());
        verify(mockSessionManager.signOutDevice()).called(1);
      });

      test('should return Failure as-is when signOutDevice throws Failure', () async {
        when(mockSessionManager.signOutDevice()).thenThrow(const Failure.unexpected('known error'));

        final Result<Unit> result = await authRepository.logout().run();

        expect(result, isA<Left<Failure, Unit>>());
        result.match((Failure l) => expect(l.message, 'known error'), (_) => fail('expected Left'));
      });
    });

    group('getCurrentAccount', () {
      test('should return Account when successful', () async {
        final Account mockAccountResult = Account(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
          authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
          userProfileId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
          userInfoId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
          walletId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
          userProfile: UserProfile(
            authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
            userName: 'admin',
            fullName: 'Admin User',
            email: 'admin@baktaz.com',
          ),
        );

        when(mockAccountEndpoint.getCurrentAccount()).thenAnswer((_) async => mockAccountResult);

        final Result<Account> result = await authRepository.getCurrentAccount().run();

        expect(result, isA<Right<Failure, Account>>());
        final Account currentAccount = result.getOrElse((_) => throw Exception());
        expect(currentAccount.userProfile?.userName, 'admin');
        expect(currentAccount.userProfile?.fullName, 'Admin User');
        expect(currentAccount.userProfile?.email, 'admin@baktaz.com');

        verify(mockAccountEndpoint.getCurrentAccount()).called(1);
      });

      test('should return failure when getCurrentAccount throws exception', () async {
        when(mockAccountEndpoint.getCurrentAccount()).thenThrow(Exception('Network error'));

        final Result<Account> result = await authRepository.getCurrentAccount().run();

        expect(result, isA<Left<Failure, Account>>());
        verify(mockAccountEndpoint.getCurrentAccount()).called(1);
      });

      test('should return Failure as-is when getCurrentAccount throws Failure', () async {
        when(mockAccountEndpoint.getCurrentAccount()).thenThrow(const Failure.unexpected('known error'));

        final Result<Account> result = await authRepository.getCurrentAccount().run();

        expect(result, isA<Left<Failure, Account>>());
        result.match((Failure l) => expect(l.message, 'known error'), (_) => fail('expected Left'));
      });
    });
  });
}
