import 'package:baktaz_server/src/features/auth/domain/interface/i_otp_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:get_it/get_it.dart';
import 'package:serverpod/serverpod.dart';

final class OtpEndpoint extends Endpoint {
  OtpEndpoint([IOtpRepository? otpRepository])
    : _otpRepository =
          otpRepository ??
          (GetIt.I.isRegistered<IOtpRepository>()
              ? GetIt.I<IOtpRepository>()
              : throw StateError('IOtpRepository not registered'));

  final IOtpRepository _otpRepository;

  @override
  bool get requireLogin => false;

  Future<void> sendOtp(Session session, {required String email}) async => _otpRepository.sendOtp(session, email: email);

  Future<OtpVerificationResult> verifyOtp(Session session, {required String email, required String code}) async =>
      _otpRepository.verifyOtp(session, email: email, code: code);
}
