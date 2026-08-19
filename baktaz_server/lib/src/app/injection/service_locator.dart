import 'package:baktaz_server/src/app/injection/service_locator.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  getIt.init();
}
