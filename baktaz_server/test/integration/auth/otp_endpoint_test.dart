// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/app/utils/auth_utils.dart';
import 'package:baktaz_server/src/features/auth/data/repository/otp_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_otp_repository.dart';
import 'package:baktaz_server/src/features/auth/endpoint/otp_endpoint.dart';
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
  if (!GetIt.I.isRegistered<IOtpRepository>()) {
    configureDependencies();
  }

  withServerpod('Given OtpEndpoint', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
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
      test('sendOtp delegates to IOtpRepository', () async {
        final MockIOtpRepository mockOtpRepository = MockIOtpRepository();
        final OtpEndpoint customEndpoint = OtpEndpoint(mockOtpRepository);
        final Session session = sessionBuilder.build();
        const String testEmail = 'delegate@example.com';

        when(mockOtpRepository.sendOtp(session, email: testEmail)).thenAnswer((_) async {});

        await customEndpoint.sendOtp(session, email: testEmail);

        verify(mockOtpRepository.sendOtp(session, email: testEmail)).called(1);
      });

      test('verifyOtp delegates to IOtpRepository', () async {
        final MockIOtpRepository mockOtpRepository = MockIOtpRepository();
        final OtpEndpoint customEndpoint = OtpEndpoint(mockOtpRepository);
        final Session session = sessionBuilder.build();
        const String testEmail = 'delegate@example.com';
        const String testCode = '123456';
        final OtpVerificationResult expectedResult = OtpVerificationResult(
          isNewUser: true,
          registrationToken: 'dummy_token',
        );

        when(mockOtpRepository.verifyOtp(session, email: testEmail, code: testCode))
            .thenAnswer((_) async => expectedResult);

        final OtpVerificationResult result = await customEndpoint.verifyOtp(session, email: testEmail, code: testCode);

        expect(result, equals(expectedResult));
        verify(mockOtpRepository.verifyOtp(session, email: testEmail, code: testCode)).called(1);
      });
    });

    group('OtpRepository Unit Logic', () {
      late MockSession mockSession;
      late MockCaches mockCaches;
      late LocalCache localCache;
      late MockEmailService mockEmailService;
      late MockSecurityLogger mockSecurityLogger;
      late OtpRepository otpRepository;
      late OtpEndpoint customEndpoint;

      setUp(() {
        mockSession = MockSession();
        mockCaches = MockCaches();
        localCache = LocalCache(10000, Protocol());
        mockEmailService = MockEmailService();
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

        otpRepository = OtpRepository(mockEmailService, mockSecurityLogger);
        customEndpoint = OtpEndpoint(otpRepository);
      });

      group('sendOtp', () {
        test('succeeds with valid email and stores OTP in local cache', () async {
          const String testEmail = 'user@example.com';
          when(mockEmailService.sendOtp(mockSession, email: testEmail, code: anyNamed('code')))
              .thenAnswer((Invocation _) async {});

          await customEndpoint.sendOtp(mockSession, email: testEmail);

          final String? code = await localCache.get<String>('otp:$testEmail');
          expect(code, isNotNull);
          expect(code!.length, equals(AppConfig.otpLength));
          verify(mockEmailService.sendOtp(mockSession, email: testEmail, code: code)).called(1);
        });

        test('rejects invalid email format with FormatException', () async {
          await expectLater(
            customEndpoint.sendOtp(mockSession, email: 'invalid-email'),
            throwsA(isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Invalid email'))),
          );
        });

        test('rejects empty email with FormatException', () async {
          await expectLater(
            customEndpoint.sendOtp(mockSession, email: ''),
            throwsA(isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Invalid email'))),
          );
        });

        test('rejects request when maxSendsPerHour rate limit is reached', () async {
          const String testEmail = 'ratelimit@example.com';
          when(mockEmailService.sendOtp(mockSession, email: testEmail, code: anyNamed('code')))
              .thenAnswer((Invocation _) async {});

          for (int i = 0; i < AppConfig.otpMaxSendsPerHour; i++) {
            await customEndpoint.sendOtp(mockSession, email: testEmail);
          }

          await expectLater(
            customEndpoint.sendOtp(mockSession, email: testEmail),
            throwsA(
              isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Too many OTP requests')),
            ),
          );
        });
      });

      group('verifyOtp', () {
        test('fails with wrong code and increments attempt counter', () async {
          const String testEmail = 'user@example.com';
          await localCache.put('otp:$testEmail', '123456');

          await expectLater(
            customEndpoint.verifyOtp(mockSession, email: testEmail, code: '654321'),
            throwsA(
              isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Invalid or expired OTP')),
            ),
          );

          final int? attempts = await localCache.get<int>('otp:attempts:$testEmail');
          expect(attempts, equals(1));
        });

        test('invalidates OTP after max attempts', () async {
          const String testEmail = 'user@example.com';
          await localCache.put('otp:$testEmail', '123456');
          await localCache.put('otp:attempts:$testEmail', AppConfig.otpMaxAttemptsPerOtp);

          await expectLater(
            customEndpoint.verifyOtp(mockSession, email: testEmail, code: '123456'),
            throwsA(
              isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Too many attempts')),
            ),
          );

          final String? code = await localCache.get<String>('otp:$testEmail');
          expect(code, isNull);
        });
      });
    });

    group('Integration via Serverpod Endpoints', () {
      test('sendOtp succeeds with valid email', () async {
        const String testEmail = 'valid@example.com';
        await endpoints.otp.sendOtp(sessionBuilder, email: testEmail);

        final Session session = sessionBuilder.build();
        final String? code = await session.caches.local.get<String>('otp:$testEmail');
        expect(code, isNotNull);
        expect(code!.length, equals(AppConfig.otpLength));
      });

      group('verifyOtp', () {
        test('fails with wrong code', () async {
          const String testEmail = 'verify_wrong@example.com';
          final Session session = sessionBuilder.build();
          await session.caches.local.put('otp:$testEmail', '123456');

          await expectLater(
            endpoints.otp.verifyOtp(sessionBuilder, email: testEmail, code: '000000'),
            throwsA(
              isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Invalid or expired OTP')),
            ),
          );
        });

        test('invalidates OTP after max attempts', () async {
          const String testEmail = 'verify_max@example.com';
          final Session session = sessionBuilder.build();
          await session.caches.local.put('otp:$testEmail', '123456');
          await session.caches.local.put('otp:attempts:$testEmail', AppConfig.otpMaxAttemptsPerOtp);

          await expectLater(
            endpoints.otp.verifyOtp(sessionBuilder, email: testEmail, code: '123456'),
            throwsA(
              isA<OtpException>().having((OtpException e) => e.message, 'message', contains('Too many attempts')),
            ),
          );

          final String? cached = await session.caches.local.get<String>('otp:$testEmail');
          expect(cached, isNull);
        });

        test('returns isNewUser=true and registrationToken for new email', () async {
          const String testEmail = 'new_user_otp@example.com';
          final Session session = sessionBuilder.build();
          await session.caches.local.put('otp:$testEmail', '123456');

          final OtpVerificationResult result = await endpoints.otp.verifyOtp(
            sessionBuilder,
            email: testEmail,
            code: '123456',
          );

          expect(result.isNewUser, isTrue);
          expect(result.registrationToken, isNotNull);
          expect(result.registrationToken, isNotEmpty);
          expect(result.authInfo, isNull);

          final String? storedToken = await session.caches.local.get<String>('otp:token:$testEmail');
          expect(storedToken, equals(result.registrationToken));
        });

        test('returns isNewUser=false and authInfo for existing email with EmailAccount', () async {
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

          const String testEmail = 'existing_user_otp@example.com';
          final Session session = sessionBuilder.build();

          final AuthUserModel authUser = await AuthServices.instance.authUsers.create(session);
          await EmailAccount.db.insertRow(
            session,
            EmailAccount(authUserId: authUser.id, email: testEmail, passwordHash: 'dummy_hash'),
          );

          await session.caches.local.put('otp:$testEmail', '654321');

          final OtpVerificationResult result = await endpoints.otp.verifyOtp(
            sessionBuilder,
            email: testEmail,
            code: '654321',
          );

          expect(result.isNewUser, isFalse);
          expect(result.authInfo, isNotNull);
          expect(result.registrationToken, isNull);
        });

        test(
          'creating user profile for non-admin automatically creates EmailAccount link with placeholder hash',
          () async {
            const String testEmail = 'non_admin_link@example.com';
            final Session session = sessionBuilder.build();

            await session.db.transaction((Transaction transaction) async {
              final AuthUserModel authUser = await AuthServices.instance.authUsers.create(
                session,
                transaction: transaction,
              );
              final UserProfileModel userProfile = UserProfileModel(
                authUserId: authUser.id,
                email: testEmail,
                fullName: 'Non Admin',
                userName: 'nonadmin',
              );

              await UserProfile.db.insertRow(
                session,
                UserProfile(authUserId: authUser.id, email: testEmail, fullName: 'Non Admin', userName: 'nonadmin'),
                transaction: transaction,
              );

              await AuthUtils.onAfterUserProfileCreated(session, userProfile, transaction: transaction);

              final EmailAccount? link = await EmailAccount.db.findFirstRow(
                session,
                where: (EmailAccountTable t) => t.email.equals(testEmail),
                transaction: transaction,
              );

              expect(link, isNotNull);
              expect(link!.authUserId, equals(authUser.id));
              expect(link.passwordHash, equals('placeholder-otp-only-no-password'));
            });
          },
        );

        test('creating user profile for admin skips EmailAccount link creation', () async {
          const String adminEmail = 'admin_nolink@example.com';
          final Session session = sessionBuilder.build();

          await session.db.transaction((Transaction transaction) async {
            final AuthUserModel authUser = await AuthServices.instance.authUsers.create(
              session,
              scopes: <Scope>{Scope.admin},
              transaction: transaction,
            );
            final UserProfileModel userProfile = UserProfileModel(
              authUserId: authUser.id,
              email: adminEmail,
              fullName: 'Admin User',
              userName: 'adminuser',
            );

            await UserProfile.db.insertRow(
              session,
              UserProfile(authUserId: authUser.id, email: adminEmail, fullName: 'Admin User', userName: 'adminuser'),
              transaction: transaction,
            );

            await AuthUtils.onAfterUserProfileCreated(session, userProfile, transaction: transaction);

            final EmailAccount? link = await EmailAccount.db.findFirstRow(
              session,
              where: (EmailAccountTable t) => t.email.equals(adminEmail),
              transaction: transaction,
            );

            expect(link, isNull);
          });
        });
      });
    });
  }, applyMigrations: true);
}
