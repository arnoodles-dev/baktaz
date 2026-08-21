import 'dart:convert';
import 'dart:math';

import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/auth/data/service/email_service.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_otp_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:email_validator/email_validator.dart';
import 'package:injectable/injectable.dart' hide Scope;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IOtpRepository)
final class OtpRepository implements IOtpRepository {
  OtpRepository(this._emailService, this._securityLogger);

  final EmailService _emailService;
  final SecurityLogger _securityLogger;

  @override
  Future<void> sendOtp(Session session, {required String email}) async {
    try {
      final String normalizedEmail = email.trim().toLowerCase();
      if (!EmailValidator.validate(normalizedEmail)) {
        throw OtpException(message: 'Invalid email');
      }

      // Rolling-window rate limit: timestamps list, drop > 1hr old
      final String? rawTimes = await session.caches.local.get<String>('otp:times:$normalizedEmail');
      final List<DateTime> pastSends = rawTimes == null || rawTimes.isEmpty
          ? <DateTime>[]
          : (jsonDecode(rawTimes) as List<dynamic>).map((dynamic e) => DateTime.parse(e as String)).toList();
      final DateTime now = DateTime.now();
      final List<DateTime> recent = pastSends
          .where((DateTime t) => now.difference(t) < const Duration(hours: 1))
          .toList();
      if (recent.length >= AppConfig.otpMaxSendsPerHour) {
        throw OtpException(message: 'Too many OTP requests. Try again later.');
      }

      // Invalidate any existing OTP for this email before storing new one
      await session.caches.local.invalidateKey('otp:$normalizedEmail');

      final String code = List<int>.generate(AppConfig.otpLength, (_) => Random.secure().nextInt(10)).join();
      await session.caches.local.put('otp:$normalizedEmail', code, lifetime: AppConfig.otpExpiry);
      final String encodedTimes = jsonEncode(
        <DateTime>[...recent, now].map((DateTime t) => t.toIso8601String()).toList(),
      );
      await session.caches.local.put('otp:times:$normalizedEmail', encodedTimes, lifetime: const Duration(hours: 1));
      await _emailService.sendOtp(session, email: normalizedEmail, code: code);
      await _securityLogger.log(session, 'otp_send', metadata: '{"email":"$normalizedEmail"}');
    } on OtpException {
      rethrow;
    } on Object catch (e, st) {
      session.log('Unexpected error during sendOtp: $e', level: LogLevel.error, exception: e, stackTrace: st);
      Error.throwWithStackTrace(OtpException(message: 'Failed to send OTP. Please try again.'), st);
    }
  }

  @override
  Future<OtpVerificationResult> verifyOtp(Session session, {required String email, required String code}) async {
    try {
      final String normalizedEmail = email.trim().toLowerCase();

      // Attempt throttling
      final String attemptsKey = 'otp:attempts:$normalizedEmail';
      final int attempts = await session.caches.local.get<int>(attemptsKey) ?? 0;
      if (attempts >= AppConfig.otpMaxAttemptsPerOtp) {
        await session.caches.local.invalidateKey('otp:$normalizedEmail');
        await _securityLogger.log(session, 'otp_verify_fail', metadata: '{"email":"$normalizedEmail"}');
        throw OtpException(message: 'Too many attempts. Request a new code.');
      }

      final String? cached = await session.caches.local.get<String>('otp:$normalizedEmail');
      if (cached == null || cached != code) {
        await session.caches.local.put(attemptsKey, attempts + 1, lifetime: AppConfig.otpExpiry);
        await _securityLogger.log(session, 'otp_verify_fail', metadata: '{"email":"$normalizedEmail"}');
        throw OtpException(message: 'Invalid or expired OTP');
      }

      // One-time use
      await session.caches.local.invalidateKey('otp:$normalizedEmail');
      await session.caches.local.invalidateKey(attemptsKey);

      final UserProfile? existingProfile = await UserProfile.db.findFirstRow(
        session,
        where: (UserProfileTable t) => t.email.equals(normalizedEmail),
      );
      if (existingProfile != null) {
        final AuthUserModel authUser = await AuthServices.instance.authUsers.get(
          session,
          authUserId: existingProfile.authUserId,
        );
        if (authUser.scopes.contains(Scope.admin)) {
          throw OtpException(message: 'Admin accounts cannot use OTP login');
        }
      }

      // Existing-user detection via EmailAccount (unique source of truth)
      final EmailAccount? link = await EmailAccount.db.findFirstRow(
        session,
        where: (EmailAccountTable t) => t.email.equals(normalizedEmail),
      );
      if (link != null) {
        final AuthUserModel authUser = await AuthServices.instance.authUsers.get(session, authUserId: link.authUserId);
        if (authUser.blocked) throw AuthUserBlockedException();
        final AuthSuccess authInfo = await AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: link.authUserId,
          method: AppConfig.otpMethod,
        );
        await _securityLogger.log(
          session,
          'otp_verify_success',
          authUserId: link.authUserId,
          metadata: '{"email":"$normalizedEmail"}',
        );
        return OtpVerificationResult(isNewUser: false, authInfo: authInfo);
      }

      // New user: registration token
      final String token = const Uuid().v4();
      await session.caches.local.put(
        'otp:token:$normalizedEmail',
        token,
        lifetime: AppConfig.otpRegistrationTokenLifetime,
      );
      await _securityLogger.log(session, 'otp_verify_success', metadata: '{"email":"$normalizedEmail"}');
      return OtpVerificationResult(isNewUser: true, registrationToken: token);
    } on OtpException {
      rethrow;
    } on AuthUserBlockedException {
      rethrow;
    } on Object catch (e, st) {
      session.log('Unexpected error during verifyOtp: $e', level: LogLevel.error, exception: e, stackTrace: st);
      Error.throwWithStackTrace(OtpException(message: 'Failed to verify OTP. Please try again.'), st);
    }
  }
}
