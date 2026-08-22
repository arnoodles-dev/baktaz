// ignore_for_file: prefer-match-file-name, depend_on_referenced_packages

import 'dart:async';

import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_test_config.dart';
import 'generated_mocks.dart';
import 'mock_path_provider_platform.dart';

class FakeRemoteConfigService implements IRemoteConfigService {
  @override
  Future<StreamSubscription<dynamic>> initializeConfig(void Function(dynamic)? onData) async =>
      const Stream<dynamic>.empty().listen(null);

  @override
  Future<Map<String, dynamic>> get remoteConfig async => <String, dynamic>{};

  @override
  Future<String?> getString(String key) async => null;
}

Future<void> setupInjection() async {
  await getIt.reset();
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = MockPathProviderPlatform();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  _mockPackageInfo();
  await Future.wait(<Future<void>>[configureDependencies(Env.test)]);
  if (getIt.isRegistered<IRemoteConfigService>()) {
    await getIt.unregister<IRemoteConfigService>();
  }
  getIt.registerLazySingleton<IRemoteConfigService>(FakeRemoteConfigService.new);
  if (getIt.isRegistered<IAnalyticsService>()) {
    await getIt.unregister<IAnalyticsService>();
  }
  getIt.registerLazySingleton<IAnalyticsService>(MockIAnalyticsService.new);
  if (getIt.isRegistered<ICrashlyticsService>()) {
    await getIt.unregister<ICrashlyticsService>();
  }
  getIt.registerLazySingleton<ICrashlyticsService>(MockICrashlyticsService.new);
}

void _mockPackageInfo() {
  PackageInfo.setMockInitialValues(
    appName: Constant.appName,
    packageName: 'com.baktaz.app',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: 'buildSignature',
  );
}

extension FileNameX on String {
  String get goldensVersion => '${this}_${TestConfig.goldensVersion}';
}
