// ignore_for_file: one_member_abstracts

import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

abstract interface class IAuthRepository {
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  );
}
