import 'package:serverpod/serverpod.dart';

// ignore: one_member_abstracts
abstract interface class IEmailService {
  Future<void> sendOtp(Session session, {required String email, required String code});
}
