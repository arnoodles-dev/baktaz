import 'dart:async';

import 'package:baktaz_flutter/app/app.dart';
import 'package:baktaz_flutter/app/config/app_config.dart';
import 'package:baktaz_flutter/app/config/firebase_config.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/mobile_service_core.dart';
import 'package:talker/talker.dart';

void main() {
  bootstrap(App.new, Env.fromFlavor());
}

Future<void> bootstrap(FutureOr<Widget> Function() builder, Env env) async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies(env);
  await _initializeBackendServices();

  if (kDebugMode) {
    BlocSignalObserver.observer = getIt<TalkerBlocSignalObserver>();
  }

  _handleErrors();

  runApp(await builder());
}

Future<void> _initializeBackendServices() async {
  await getIt<IMobileServiceRepository>().initializeServices(
    enablePerformanceMonitor: AppConfig.enablePerformanceMonitor,
    options: DefaultFirebaseOptions.getCurrentPlatform(),
  );
  await getIt<IAnalyticsService>().setAnalyticsCollectionEnabled(enabled: AppConfig.enableAnalytics);
  await getIt<ICrashlyticsService>().setCrashlyticsCollectionEnabled(enabled: AppConfig.enableCrashlytics);
}

void _handleErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      getIt<ICrashlyticsService>().recordFlutterFatalError(details);
    } else {
      getIt<Talker>().error(details.exceptionAsString(), details.exception, details.stack);
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    if (kReleaseMode) {
      getIt<ICrashlyticsService>().reportCrash(error, stackTrace);
    } else {
      getIt<Talker>().error(error.toString(), error, stackTrace);
    }

    return true;
  };
}
