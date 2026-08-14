import 'package:baktaz_flutter/app/helpers/injection/service_locator.config.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(Env env) async {
  await getIt.init(environment: env.name);
  // Don't initialize serverpod on test so that MockServerpod can be registered
  if (env != Env.test) {
    await getIt.initServerScope();
  }
}
