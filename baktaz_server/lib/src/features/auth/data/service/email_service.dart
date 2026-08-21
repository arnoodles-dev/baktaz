import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

@lazySingleton
class EmailService {
  Future<void> sendOtp(Session session, {required String email, required String code}) async {
    session
      ..log('OTP dispatched for $email', level: LogLevel.info)
      ..log('OTP code for $email: [DEBUG ONLY] $code', level: LogLevel.debug);
  }
}
