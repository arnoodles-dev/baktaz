import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IOtpRepository {
  Future<void> sendOtp(Session session, {required String email});
  Future<OtpVerificationResult> verifyOtp(Session session, {required String email, required String code});
}
