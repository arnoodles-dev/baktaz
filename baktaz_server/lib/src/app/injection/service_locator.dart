import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Configured via Injectable generator if required.
  assert(true, 'Injectable initialized');
}
