import 'dart:async';

import 'package:baktaz_admin/app/app.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies(Env.fromFlavor());
    usePathUrlStrategy();
    _handleErrors();

    if (kDebugMode) {
      BlocSignalObserver.observer = getIt<TalkerBlocSignalObserver>();
    }

    runApp(App());
  }, _catchUnhandledErrors);
}

void _handleErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    _catchUnhandledErrors(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    _catchUnhandledErrors(error, stackTrace);
    return true;
  };
}

void _catchUnhandledErrors(Object error, StackTrace? stack) {
  if (kReleaseMode) {
    //TODO: implement reportCrash crashlytics
  } else {
    getIt<Talker>().handle(error, stack);
  }
}
