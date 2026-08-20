import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/auth/endpoint/otp_endpoint.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/cache/local_cache.dart';
import 'package:test/test.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  group('Given OtpEndpoint', () {
    late MockSession mockSession;
    late MockCaches mockCaches;
    late LocalCache localCache;
    late MockIEmailService mockEmailService;
    late OtpEndpoint endpoint;

    setUp(() {
      mockSession = MockSession();
      mockCaches = MockCaches();
      localCache = LocalCache(10000, Protocol());
      mockEmailService = MockIEmailService();

      when(mockSession.caches).thenReturn(mockCaches);
      when(mockCaches.local).thenReturn(localCache);

      endpoint = OtpEndpoint(mockEmailService);
    });

    group('sendOtp', () {
      test('succeeds with valid email and stores OTP in local cache', () async {
        const String testEmail = 'user@example.com';
        when(mockEmailService.sendOtp(mockSession, email: testEmail, code: anyNamed('code')))
            .thenAnswer((Invocation _) async {});

        await endpoint.sendOtp(mockSession, email: testEmail);

        final String? code = await localCache.get<String>('otp:$testEmail');
        expect(code, isNotNull);
        expect(code!.length, equals(OtpConfig.length));
        verify(mockEmailService.sendOtp(mockSession, email: testEmail, code: code)).called(1);
      });

      test('rejects invalid email format with FormatException', () async {
        await expectLater(
          endpoint.sendOtp(mockSession, email: 'invalid-email'),
          throwsA(
            isA<FormatException>().having((FormatException e) => e.message, 'message', contains('Invalid email')),
          ),
        );
      });

      test('rejects empty email with FormatException', () async {
        await expectLater(
          endpoint.sendOtp(mockSession, email: ''),
          throwsA(
            isA<FormatException>().having((FormatException e) => e.message, 'message', contains('Invalid email')),
          ),
        );
      });

      test('rejects request when maxSendsPerHour rate limit is reached', () async {
        const String testEmail = 'ratelimit@example.com';
        when(mockEmailService.sendOtp(mockSession, email: testEmail, code: anyNamed('code')))
            .thenAnswer((Invocation _) async {});

        for (int i = 0; i < OtpConfig.maxSendsPerHour; i++) {
          await endpoint.sendOtp(mockSession, email: testEmail);
        }

        await expectLater(
          endpoint.sendOtp(mockSession, email: testEmail),
          throwsA(isA<StateError>().having((StateError e) => e.message, 'message', contains('Too many OTP requests'))),
        );
      });
    });
  });

  withServerpod('Given OtpEndpoint integration', (TestSessionBuilder sessionBuilder, TestEndpoints endpoints) {
    test('sendOtp succeeds with valid email', () async {
      const String testEmail = 'valid@example.com';
      await endpoints.otp.sendOtp(sessionBuilder, email: testEmail);

      final Session session = sessionBuilder.build();
      final String? code = await session.caches.local.get<String>('otp:$testEmail');
      expect(code, isNotNull);
      expect(code!.length, equals(OtpConfig.length));
    });
  }, applyMigrations: false);
}
