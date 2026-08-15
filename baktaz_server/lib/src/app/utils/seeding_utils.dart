import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Seeds the default admin user if it does not already exist in development mode.
Future<void> seedAdminUser(Session session) async {
  try {
    final String? adminEmail = session.passwords['adminUser'];
    final String? adminPassword = session.passwords['adminPassword'];
    if (adminEmail == null || adminPassword == null) {
      session.log('adminUser or adminPassword missing in passwords.yaml', level: LogLevel.warning);
      return;
    }
    final UserProfile? existing = await UserProfile.db
        .findFirstRow(session, where: (UserProfileTable t) => t.email.equals(adminEmail))
        .timeout(AppConfig.defaultTimeout);

    if (existing != null) {
      session.log('Super admin user $adminEmail already exists.');
      return;
    }

    session.log('Seeding super admin $adminEmail...');

    // 1. Create the base AuthUser with Scope.admin directly assigned
    final AuthUserModel authUser = await AuthServices.instance.authUsers.create(session, scopes: <Scope>{Scope.admin});
    final UuidValue authUserId = authUser.id;

    // 2. Create the UserProfile
    await AuthServices.instance.userProfiles.createUserProfile(
      session,
      authUserId,
      UserProfileData(email: adminEmail, fullName: 'Admin', userName: 'admin'),
    );

    // 3. Create the email authentication account
    final EmailIdpAdmin emailIdpAdmin = AuthServices.instance.emailIdp.admin;
    await emailIdpAdmin.createEmailAuthentication(
      session,
      authUserId: authUserId,
      email: adminEmail,
      password: adminPassword,
    );

    session.log('Successfully seeded default admin user $adminEmail.');
  } on Exception catch (error, stackTrace) {
    session.log('Failed to seed default admin user: $error', level: LogLevel.error, stackTrace: stackTrace);
  }
}
