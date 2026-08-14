import 'package:baktaz_admin/app/config/serverpod_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_settings.dart';
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

  // Logging
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
  TalkerBlocObserver get talkerBlocObserver => TalkerBlocObserver(
    talker: talker,
    settings: const TalkerBlocLoggerSettings(printEventFullData: false, printChanges: true),
  );

  @lazySingleton
  TalkerRouteObserver get talkerRouteObserver => TalkerRouteObserver(talker);

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
