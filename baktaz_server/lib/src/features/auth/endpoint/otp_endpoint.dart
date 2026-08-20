import 'dart:math';

import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/auth/domain/service/development_email_service.dart';
import 'package:baktaz_server/src/features/auth/domain/service/i_email_service.dart';
import 'package:serverpod/serverpod.dart';

final class OtpEndpoint extends Endpoint {
  OtpEndpoint([IEmailService? emailService]) : _emailService = emailService ?? DevelopmentEmailService();
  final IEmailService _emailService;

  @override
  bool get requireLogin => false;

  Future<void> sendOtp(Session session, {required String email}) async {
    final String normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) throw const FormatException('Invalid email');

    // Rolling-window rate limit: timestamps list, drop > 1hr old
    final List<DateTime> pastSends =
        await session.caches.local.get<List<DateTime>>('otp:times:$normalizedEmail') ?? <DateTime>[];
    final DateTime now = DateTime.now();
    final List<DateTime> recent = pastSends
        .where((DateTime t) => now.difference(t) < const Duration(hours: 1))
        .toList();
    if (recent.length >= OtpConfig.maxSendsPerHour) {
      throw StateError('Too many OTP requests. Try again later.');
    }

    // Invalidate any existing OTP for this email before storing new one
    await session.caches.local.invalidateKey('otp:$normalizedEmail');

    final String code = List<int>.generate(OtpConfig.length, (_) => Random.secure().nextInt(10)).join();
    await session.caches.local.put('otp:$normalizedEmail', code, lifetime: OtpConfig.expiry);
    await session.caches.local.put('otp:times:$normalizedEmail', <DateTime>[
      ...recent,
      now,
    ], lifetime: const Duration(hours: 1));
    await _emailService.sendOtp(session, email: normalizedEmail, code: code);
  }

  static bool _isValidEmail(String email) => RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(email);
}
