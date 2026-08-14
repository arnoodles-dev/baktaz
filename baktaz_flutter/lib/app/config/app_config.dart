import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

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
  static bool get enableCrashlytics => _envConfig.enableCrashlytics.toBoolean;
  static bool get enablePerformanceMonitor => _envConfig.enablePerformanceMonitor.toBoolean;
  static bool get enableAnalytics => _envConfig.enableAnalytics.toBoolean;
  static String get mobileAuthClientId => switch (defaultTargetPlatform) {
    TargetPlatform.android => _envConfig.androidAuthClientId,
    TargetPlatform.iOS => _envConfig.iosAuthClientId,
    _ => throw UnsupportedError('Platform not supported: $defaultTargetPlatform'),
  };
  static String get webAuthClientId => _envConfig.webAuthClientId;
  static String get serverpodUrl {
    if (environment == Env.development) {
      if (defaultTargetPlatform case TargetPlatform.android) {
        return 'http://10.0.2.2:8080/';
      } else {
        return 'http://localhost:8080/';
      }
    }

    return _envConfig.serverpodUrl;
  }

  static String get googleMapsApiKey {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _envConfig.googleMapAndroidKey;
      case TargetPlatform.iOS:
        return _envConfig.googleMapIosKey;
      default:
        throw UnsupportedError('Platform not supported: $defaultTargetPlatform');
    }
  }

  static String get googleMapIdAndroid => _envConfig.googleMapIdAndroid;
  static String get googleMapIdIos => _envConfig.googleMapIdIos;
  static String get googleMapId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _envConfig.googleMapIdAndroid;
      case TargetPlatform.iOS:
        return _envConfig.googleMapIdIos;
      default:
        throw UnsupportedError('Platform not supported: $defaultTargetPlatform');
    }
  }

  static String get firebaseAndroidApiKey => _envConfig.firebaseAndroidApiKey;
  static String get firebaseIosApiKey => _envConfig.firebaseIosApiKey;
  static String get firebaseAndroidAppId => _envConfig.firebaseAndroidAppId;
  static String get firebaseIosAppId => _envConfig.firebaseIosAppId;
  static String get firebaseMessagingSenderId => _envConfig.firebaseMessagingSenderId;
  static String get firebaseProjectId => _envConfig.firebaseProjectId;
  static String get firebaseStorageBucket => _envConfig.firebaseStorageBucket;
  static String get bundleId => _envConfig.bundleId;
  static String get facebookAppId => _envConfig.facebookAppId;
  static String get facebookClientToken => _envConfig.facebookClientToken;
  static String get fbLoginProtocolScheme => 'fb${_envConfig.facebookAppId}';
}

@Envied(path: 'assets/env/.env.production', name: 'ProductionEnv', useConstantCase: true)
@Envied(path: 'assets/env/.env.development', name: 'DevelopmentEnv', useConstantCase: true)
@Envied(path: 'assets/env/.env.staging', name: 'StagingEnv', useConstantCase: true)
abstract class AppEnv {
  @EnviedField(varName: 'ENV')
  abstract final String env;

  @EnviedField(varName: 'ENABLE_CRASHLYTICS')
  abstract final String enableCrashlytics;

  @EnviedField(varName: 'ENABLE_PERFORMANCE_MONITOR')
  abstract final String enablePerformanceMonitor;

  @EnviedField(varName: 'ENABLE_ANALYTICS')
  abstract final String enableAnalytics;

  @EnviedField(varName: 'ANDROID_AUTH_CLIENT_ID', obfuscate: true)
  abstract final String androidAuthClientId;

  @EnviedField(varName: 'IOS_AUTH_CLIENT_ID', obfuscate: true)
  abstract final String iosAuthClientId;

  @EnviedField(varName: 'WEB_AUTH_CLIENT_ID', obfuscate: true)
  abstract final String webAuthClientId;

  @EnviedField(varName: 'SERVERPOD_URL', obfuscate: true)
  abstract final String serverpodUrl;

  @EnviedField(varName: 'GOOGLE_MAP_ANDROID_KEY', obfuscate: true)
  abstract final String googleMapAndroidKey;

  @EnviedField(varName: 'GOOGLE_MAP_IOS_KEY', obfuscate: true)
  abstract final String googleMapIosKey;

  @EnviedField(varName: 'GOOGLE_MAP_ID_ANDROID', obfuscate: true)
  abstract final String googleMapIdAndroid;

  @EnviedField(varName: 'GOOGLE_MAP_ID_IOS', obfuscate: true)
  abstract final String googleMapIdIos;

  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY', obfuscate: true)
  abstract final String firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_API_KEY', obfuscate: true)
  abstract final String firebaseIosApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID', obfuscate: true)
  abstract final String firebaseAndroidAppId;

  @EnviedField(varName: 'FIREBASE_IOS_APP_ID', obfuscate: true)
  abstract final String firebaseIosAppId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID', obfuscate: true)
  abstract final String firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_PROJECT_ID', obfuscate: true)
  abstract final String firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET', obfuscate: true)
  abstract final String firebaseStorageBucket;

  @EnviedField(varName: 'BUNDLE_ID', obfuscate: true)
  abstract final String bundleId;

  @EnviedField(varName: 'FACEBOOK_APP_ID', obfuscate: true)
  abstract final String facebookAppId;

  @EnviedField(varName: 'FACEBOOK_CLIENT_TOKEN', obfuscate: true)
  abstract final String facebookClientToken;
}
