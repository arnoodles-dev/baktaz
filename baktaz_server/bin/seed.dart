// ignore_for_file: no-empty-block

import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/app/utils/auth_utils.dart';
import 'package:baktaz_server/src/app/utils/seeding_utils.dart';
import 'package:baktaz_server/src/generated/endpoints.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Database seeding entry point script.
Future<void> main(List<String> args) async {
  configureDependencies();

  final Serverpod pod = Serverpod(args, Protocol(), Endpoints())
    ..initializeAuthServices(
      userProfileConfig: const UserProfileConfig(
        onBeforeUserProfileCreated: AuthUtils.onBeforeUserProfileCreated,
        onAfterUserProfileCreated: AuthUtils.onAfterUserProfileCreated,
      ),
      tokenManagerBuilders: <TokenManagerBuilder<TokenManager>>[JwtConfigFromPasswords()],
      identityProviderBuilders: <IdentityProviderBuilder<IdentityProvider>>[
        EmailIdpConfigFromPasswords(
          sendRegistrationVerificationCode: (
            Session session, {
            required UuidValue accountRequestId,
            required String email,
            required Transaction? transaction,
            required String verificationCode,
          }) async {},
          sendPasswordResetVerificationCode: (
            Session session, {
            required String email,
            required UuidValue passwordResetRequestId,
            required Transaction? transaction,
            required String verificationCode,
          }) async {},
        ),
      ],
    );

  await pod.start();

  final Session session = await pod.createSession();
  try {
    await seedAdminUser(session);
  } finally {
    await session.close();
    await pod.shutdown();
  }
}
