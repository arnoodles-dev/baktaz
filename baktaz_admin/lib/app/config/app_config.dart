import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:envied/envied.dart';

part 'app_config.g.dart';

final class AppConfig {
  static final AppEnv _envConfig = switch (Env.fromFlavor()) {
    Env.development => _DevelopmentEnv(),
    Env.staging => _StagingEnv(),
    Env.production => _ProductionEnv(),
    _ => throw Exception('Unknown environment'),
  };

  static Env get environment => switch (_envConfig.env.toLowerCase()) {
    'development' => Env.development,
    'staging' => Env.staging,
    'production' => Env.production,
    _ => throw Exception('Unknown environment'),
  };

  static String get webAuthClientId => _envConfig.webAuthClientId;
  static String get serverpodUrl => _envConfig.serverpodUrl;
}

@Envied(path: 'assets/env/.env.production', name: 'ProductionEnv', useConstantCase: true)
@Envied(path: 'assets/env/.env.development', name: 'DevelopmentEnv', useConstantCase: true)
@Envied(path: 'assets/env/.env.staging', name: 'StagingEnv', useConstantCase: true)
abstract class AppEnv {
  @EnviedField(varName: 'ENV')
  abstract final String env;

  @EnviedField(varName: 'WEB_AUTH_CLIENT_ID', obfuscate: true)
  abstract final String webAuthClientId;

  @EnviedField(varName: 'SERVERPOD_URL', obfuscate: true)
  abstract final String serverpodUrl;
}
