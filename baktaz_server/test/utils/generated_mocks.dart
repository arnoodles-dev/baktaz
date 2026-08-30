// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/features/auth/data/service/email_service.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_admin_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_otp_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/cache/caches.dart';
import 'package:serverpod/src/cache/local_cache.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IAdminRepository>(),
  MockSpec<IAuthRepository>(),
  MockSpec<EmailService>(),
  MockSpec<IOtpRepository>(),
  MockSpec<SecurityLogger>(),
  MockSpec<http.Client>(),
  MockSpec<Session>(),
  MockSpec<Caches>(),
  MockSpec<LocalCache>(),
])
void main() {
  provideDummy<OtpVerificationResult>(OtpVerificationResult(isNewUser: false));
  provideDummy<RegistrationForm>(RegistrationForm(email: '', name: '', gender: '', registrationToken: ''));
}
