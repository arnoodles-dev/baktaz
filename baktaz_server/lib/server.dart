import 'dart:io';

import 'package:baktaz_server/src/cache_busting.dart';
import 'package:baktaz_server/src/generated/endpoints.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:baktaz_server/src/web/routes/app_config_route.dart';
import 'package:baktaz_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// The starting point of the Serverpod server.
Future<void> run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final Serverpod pod = Serverpod(args, Protocol(), Endpoints())
    // Initialize authentication services for the server.
    // Token managers will be used to validate and issue authentication keys,
    // and the identity providers will be the authentication options available for users.
    ..initializeAuthServices(
      tokenManagerBuilders: <TokenManagerBuilder<TokenManager>>[
        // Use JWT for authentication keys towards the server.
        JwtConfigFromPasswords(),
      ],
      identityProviderBuilders: <IdentityProviderBuilder<IdentityProvider>>[
        // Configure the email identity provider for email/password authentication.
        // The default setup works with Serverpod Cloud without configuration. In
        // development the verification codes are logged to the console, and in
        // staging and production they are sent through the Serverpod Cloud email
        // service. If you want to use a custom provider for sending emails, use
        // `EmailIdpConfigFromPasswords`.
        ServerpodCloudEmailIdpConfig(appDisplayName: 'baktaz'),
      ],
    );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute());
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(StaticRoute.withCacheBusting(cacheBustingConfig), cacheBustingConfig.mountPrefix);

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(AppConfigRoute(apiConfig: pod.config.apiServer), '/app/assets/assets/config.json');

  // Checks if the flutter web app has been built and serves it if it has.
  final Directory appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final StaticRoute defaultRoute = StaticRoute.file(File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath()));

    pod.webServer.addRoute(defaultRoute, '/app/**');
  }

  // Start the server.
  await pod.start();
}
