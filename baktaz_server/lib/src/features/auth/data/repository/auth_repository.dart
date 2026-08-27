import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_server/src/features/security/data/service/security_logger.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:injectable/injectable.dart' hide Scope;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

@LazySingleton(as: IAuthRepository)
final class AuthRepository implements IAuthRepository {
  AuthRepository(this._securityLogger);

  final SecurityLogger _securityLogger;

  @override
  Future<OtpVerificationResult> completeRegistration(
    Session session,
    RegistrationForm form,
  ) async {
    try {
      final String normalizedEmail = form.email.trim().toLowerCase();

      final String? expectedToken = await session.caches.local.get<String>('otp:token:$normalizedEmail');
      if (expectedToken == null || expectedToken != form.registrationToken) {
        throw OtpException(message: 'Invalid or expired registration token');
      }
      await session.caches.local.invalidateKey('otp:token:$normalizedEmail');

      return await session.db.transaction((Transaction transaction) async {
        final UserProfile? existingProfile = await UserProfile.db.findFirstRow(
          session,
          where: (UserProfileTable t) => t.email.equals(normalizedEmail),
          transaction: transaction,
        );
        if (existingProfile != null) {
          final AuthUserModel authUser = await AuthServices.instance.authUsers.get(
            session,
            authUserId: existingProfile.authUserId,
            transaction: transaction,
          );
          if (authUser.scopes.contains(Scope.admin)) {
            throw OtpException(message: 'Admin accounts cannot use OTP login');
          }
        }

        final AuthUserModel authUser = await AuthServices.instance.authUsers.create(session, transaction: transaction);

        await AuthServices.instance.userProfiles.createUserProfile(
          session,
          authUser.id,
          UserProfileData(fullName: form.name, email: normalizedEmail),
          transaction: transaction,
        );

        final Account? account = await Account.db.findFirstRow(
          session,
          where: (AccountTable t) => t.authUserId.equals(authUser.id),
          include: Account.include(userInfo: UserInfo.include()),
          transaction: transaction,
        );
        final UserInfo? userInfo = account?.userInfo;
        if (userInfo != null) {
          await UserInfo.db.updateRow(
            session,
            userInfo.copyWith(gender: Gender.values.asNameMap()[form.gender] ?? Gender.unknown, birthday: form.birthday),
            transaction: transaction,
          );
        }

        final AuthSuccess authInfo = await AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: authUser.id,
          method: AppConfig.otpMethod,
          transaction: transaction,
        );

        await _securityLogger.log(
          session,
          'otp_complete_registration',
          authUserId: authUser.id,
          metadata: '{"email":"$normalizedEmail"}',
          transaction: transaction,
        );

        return OtpVerificationResult(isNewUser: false, authInfo: authInfo);
      });
    } on OtpException {
      rethrow;
    } on Object catch (e, st) {
      session.log(
        'Unexpected error during completeRegistration: $e',
        level: LogLevel.error,
        exception: e,
        stackTrace: st,
      );
      Error.throwWithStackTrace(OtpException(message: 'Failed to complete registration. Please try again.'), st);
    }
  }
}
