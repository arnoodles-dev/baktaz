import 'package:baktaz_server/src/app/config/app_config.dart';
import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_localization/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
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

/// Seeds default remote config keys and initial snapshot version if missing.
Future<void> seedRemoteConfig(Session session) async {
  try {
    final List<(String, RemoteConfigValueType, String, String)> defaultKeys =
        <(String, RemoteConfigValueType, String, String)>[
      ('is_maintenance', RemoteConfigValueType.boolean, 'false', 'Enable maintenance mode'),
      ('min_supported_version', RemoteConfigValueType.string, '1.0.0', 'Minimum supported app version'),
      (
        'android_store_url',
        RemoteConfigValueType.string,
        'https://play.google.com/store/apps/details?id=com.baktaz.app',
        'Android Store URL'
      ),
      ('ios_store_url', RemoteConfigValueType.string, 'https://apps.apple.com/app/baktaz/id123456789', 'iOS Store URL'),
      ('help_center_url', RemoteConfigValueType.string, 'https://help.baktaz.com', 'Help center URL'),
      ('about_us_url', RemoteConfigValueType.string, 'https://baktaz.com/about', 'About us URL'),
      ('privacy_policy_url', RemoteConfigValueType.string, 'https://baktaz.com/privacy', 'Privacy policy URL'),
      ('enable_chat', RemoteConfigValueType.boolean, 'true', 'Enable chat feature'),
      ('enable_payout', RemoteConfigValueType.boolean, 'true', 'Enable payout feature'),
      ('enable_challenges', RemoteConfigValueType.boolean, 'true', 'Enable challenges feature'),
    ];

    for (final (String key, RemoteConfigValueType type, String defVal, String desc) in defaultKeys) {
      final ConfigKey? existing = await ConfigKey.db.findFirstRow(session, where: (ConfigKeyTable t) => t.key.equals(key));
      if (existing == null) {
        await ConfigKey.db.insertRow(
          session,
          ConfigKey(
            key: key,
            valueType: type,
            defaultValue: defVal,
            description: desc,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    final int versionCount = await ConfigSnapshotVersion.db.count(session);
    if (versionCount == 0) {
      await ConfigSnapshotVersion.db.insertRow(
        session,
        ConfigSnapshotVersion(
          versionNumber: '1.0.0',
          updateTime: DateTime.now(),
          updateOrigin: 'seeder',
          updateType: 'initial',
        ),
      );
    }

    session.log('Successfully seeded remote config defaults.');
  } on Exception catch (error, stackTrace) {
    session.log('Failed to seed remote config: $error', level: LogLevel.error, stackTrace: stackTrace);
  }
}

/// Seeds the initial remote localization release if none exists.
Future<void> seedRemoteLocalization(Session session) async {
  try {
    final IRemoteLocalizationRepository repository = getIt<IRemoteLocalizationRepository>();
    await repository.seedInitialRelease(session);
    session.log('Successfully seeded remote localization release.');
  } on Exception catch (error, stackTrace) {
    session.log('Failed to seed remote localization: $error', level: LogLevel.error, stackTrace: stackTrace);
  }
}
