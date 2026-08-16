import 'package:baktaz_flutter/app/config/chopper_config.dart';
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:chopper/chopper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service/mobile_service_repository.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';
import 'package:mobile_service_core/mobile_service_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:retry/retry.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:talker_chopper_logger/talker_chopper_logger.dart';
import 'package:talker_flutter/talker_flutter.dart' hide Talker;

@module
abstract class ServiceModule {
  //Local Storage Service
  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();

  @lazySingleton
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  //Device Service
  @lazySingleton
  @preResolve
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();

  @lazySingleton
  DeviceInfoPlugin get deviceInfo => DeviceInfoPlugin();

  @lazySingleton
  Talker get talker => Talker(
    settings: TalkerSettings(
      colors: <String, AnsiPen>{
        TalkerKey.error: AnsiPen()..red(),
        TalkerKey.exception: AnsiPen()..red(),
        TalkerKey.blocTransition: AnsiPen()..blue(),
        TalkerKey.httpRequest: AnsiPen()..green(),
        TalkerKey.httpResponse: AnsiPen()..yellow(),
        TalkerKey.httpError: AnsiPen()..magenta(),
        TalkerKey.route: AnsiPen()..cyan(),
      },
      titles: <String, String>{
        TalkerKey.blocTransition: 'Cubit',
        TalkerKey.httpRequest: 'HTTP:Request',
        TalkerKey.httpResponse: 'HTTP:Response',
        TalkerKey.httpError: 'HTTP:Error',
        TalkerKey.route: 'GoRoute',
        TalkerKey.exception: 'EXCEPTION',
        TalkerKey.error: 'ERROR',
      },
    ),
  );

  @lazySingleton
  TalkerBlocSignalObserver get talkerBlocSignalObserver => TalkerBlocSignalObserver(talker: talker);

  @lazySingleton
  TalkerRouteObserver get talkerRouteObserver => TalkerRouteObserver(talker);

  @lazySingleton
  TalkerChopperLogger get talkerChopperLogger => TalkerChopperLogger(
    talker: talker,
    settings: const TalkerChopperLoggerSettings(printRequestHeaders: true, printResponseHeaders: true),
  );

  //API Service
  @lazySingleton
  IMobileServiceRepository get mobileServiceRepository => MobileServiceRepository();

  @lazySingleton
  ChopperClient get chopperClient => getIt<ChopperConfig>().client;

  @lazySingleton
  IAnalyticsService get analytics => getIt<IMobileServiceRepository>().analyticsService;

  @lazySingleton
  IRemoteConfigService get remoteConfig => getIt<IMobileServiceRepository>().remoteConfigService;

  @lazySingleton
  ICrashlyticsService get crashlytics => getIt<IMobileServiceRepository>().crashlyticsService;

  @lazySingleton
  RetryOptions get retryOptions => const RetryOptions(maxAttempts: 2);

  //Backend Service
  @Scope('server')
  @lazySingleton
  @preResolve
  Future<Serverpod> get serverpodConfig async {
    final Serverpod serverpodConfig = Serverpod();
    await serverpodConfig.initialize(serverpodUrl: await getServerUrl());

    return serverpodConfig;
  }
}
