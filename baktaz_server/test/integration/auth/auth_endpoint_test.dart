// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/app/utils/auth_utils.dart';
import 'package:baktaz_server/src/features/auth/data/repository/auth_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/auth/endpoint/auth_endpoint.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/cache/local_cache.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:test/test.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  if (!GetIt.I.isRegistered<IAuthRepository>()) {
    configureDependencies();
  }

  withServerpod('Given AuthEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    setUpAll(() {
      try {
        AuthServices.instance;
      } on Object catch (_) {
        AuthServices.set(
          userProfileConfig: const UserProfileConfig(
            onBeforeUserProfileCreated: AuthUtils.onBeforeUserProfileCreated,
            onAfterUserProfileCreated: AuthUtils.onAfterUserProfileCreated,
          ),
          tokenManagerBuilders: <TokenManagerBuilder<TokenManager>>[JwtConfigFromPasswords()],
        );
      }
    });

    group('Endpoint Delegation', () {
      test('completeRegistration delegates to IAuthRepository', () async {
        final MockIAuthRepository mockAuthRepository = MockIAuthRepository();
        final AuthEndpoint customEndpoint = AuthEndpoint(mockAuthRepository);
        final Session session = sessionBuilder.build();
        const String testEmail = 'delegate@example.com';
        final DateTime birthday = DateTime(1995, 5, 20);
        final OtpVerificationResult expectedResult = OtpVerificationResult(
          isNewUser: false,
          authInfo: AuthSuccess(
            token: 'token',
            authUserId: UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
            authStrategy: 'jwt',
            scopeNames: const <String>{},
          ),
        );

        when(
          mockAuthRepository.completeRegistration(
            session,
            email: testEmail,
            name: 'Test Name',
            gender: 'female',
            registrationToken: 'token123',
            birthday: birthday,
          ),
        ).thenAnswer((_) async => expectedResult);

        final OtpVerificationResult result = await customEndpoint.completeRegistration(
          session,
          email: testEmail,
          name: 'Test Name',
          gender: 'female',
          registrationToken: 'token123',
          birthday: birthday,
        );

        expect(result, equals(expectedResult));
        verify(
          mockAuthRepository.completeRegistration(
            session,
            email: testEmail,
            name: 'Test Name',
            gender: 'female',
            registrationToken: 'token123',
            birthday: birthday,
          ),
        ).called(1);
      });
    });

    group('AuthRepository Unit Logic', () {
      late MockSession mockSession;
      late MockCaches mockCaches;
      late LocalCache localCache;
      late MockSecurityLogger mockSecurityLogger;
      late AuthRepository authRepository;
      late AuthEndpoint customEndpoint;

      setUp(() {
        mockSession = MockSession();
        mockCaches = MockCaches();
        localCache = LocalCache(10000, Protocol());
        mockSecurityLogger = MockSecurityLogger();

        when(mockSession.caches).thenReturn(mockCaches);
        when(mockCaches.local).thenReturn(localCache);
        when(
          mockSecurityLogger.log(
            mockSession,
            any,
            authUserId: anyNamed('authUserId'),
            metadata: anyNamed('metadata'),
            transaction: anyNamed('transaction'),
          ),
        ).thenAnswer((Invocation _) async {});

        authRepository = AuthRepository(mockSecurityLogger);
        customEndpoint = AuthEndpoint(authRepository);
      });

      group('completeRegistration', () {
        test('rejects missing or invalid registration token', () async {
          const String testEmail = 'user@example.com';

          await expectLater(
            customEndpoint.completeRegistration(
              mockSession,
              email: testEmail,
              name: 'John Doe',
              gender: 'male',
              registrationToken: 'invalid_token',
            ),
            throwsA(
              isA<OtpException>().having(
                (OtpException e) => e.message,
                'message',
                contains('Invalid or expired registration token'),
              ),
            ),
          );
        });
      });
    });

    group('Integration via Serverpod Endpoints', () {
      group('completeRegistration', () {
        test('rejects missing or invalid registration token', () async {
          const String testEmail = 'missing_token@example.com';
          await expectLater(
            endpoints.auth.completeRegistration(
              sessionBuilder,
              email: testEmail,
              name: 'Jane Doe',
              gender: 'female',
              registrationToken: 'wrong_token',
            ),
            throwsA(
              isA<OtpException>().having(
                (OtpException e) => e.message,
                'message',
                contains('Invalid or expired registration token'),
              ),
            ),
          );
        });

        test('creates account, profile, EmailAccount, UserInfo with gender/birthday, and authInfo for valid registrationToken', () async {
          const String testEmail = 'complete_reg@example.com';
          const String token = 'valid_reg_token_123';
          final DateTime birthday = DateTime.utc(1990, 1, 15);
          final Session session = sessionBuilder.build();

          await session.caches.local.put('otp:token:$testEmail', token);

          final OtpVerificationResult result = await endpoints.auth.completeRegistration(
            sessionBuilder,
            email: testEmail,
            name: 'Alice Wonder',
            gender: 'female',
            registrationToken: token,
            birthday: birthday,
          );

          expect(result.isNewUser, isFalse);
          expect(result.authInfo, isNotNull);
          expect(result.authInfo!.token, isNotEmpty);

          final UuidValue authUserId = result.authInfo!.authUserId;

          // Check EmailAccount created
          final EmailAccount? emailAccount = await EmailAccount.db.findFirstRow(
            session,
            where: (EmailAccountTable t) => t.email.equals(testEmail),
          );
          expect(emailAccount, isNotNull);
          expect(emailAccount!.authUserId, equals(authUserId));

          // Check UserProfile created
          final UserProfile? profile = await UserProfile.db.findFirstRow(
            session,
            where: (UserProfileTable t) => t.authUserId.equals(authUserId),
          );
          expect(profile, isNotNull);
          expect(profile!.fullName, equals('Alice Wonder'));
          expect(profile.email, equals(testEmail));

          // Check Account & UserInfo with gender/birthday
          final Account? account = await Account.db.findFirstRow(
            session,
            where: (AccountTable t) => t.authUserId.equals(authUserId),
            include: Account.include(userInfo: UserInfo.include()),
          );
          expect(account, isNotNull);
          expect(account!.userInfo, isNotNull);
          expect(account.userInfo!.gender, equals(Gender.female));
          expect(account.userInfo!.birthday, equals(birthday));
        });

        test('rejects second use of same registration token (token consumed)', () async {
          const String testEmail = 'reuse_token@example.com';
          const String token = 'one_time_token_456';
          final Session session = sessionBuilder.build();

          await session.caches.local.put('otp:token:$testEmail', token);

          // First call succeeds
          await endpoints.auth.completeRegistration(
            sessionBuilder,
            email: testEmail,
            name: 'Bob Builder',
            gender: 'male',
            registrationToken: token,
          );

          // Second call fails because token is consumed
          await expectLater(
            endpoints.auth.completeRegistration(
              sessionBuilder,
              email: testEmail,
              name: 'Bob Builder',
              gender: 'male',
              registrationToken: token,
            ),
            throwsA(
              isA<OtpException>().having(
                (OtpException e) => e.message,
                'message',
                contains('Invalid or expired registration token'),
              ),
            ),
          );
        });
      });
    });
  }, applyMigrations: true);
}
