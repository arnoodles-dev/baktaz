import 'package:baktaz_server/src/features/auth/domain/service/i_email_service.dart';
import 'package:serverpod/serverpod.dart';

final class DevelopmentEmailService implements IEmailService {
  @override
  Future<void> sendOtp(Session session, {required String email, required String code}) async {
    session.log('OTP for $email: $code', level: LogLevel.info);
  }
}
