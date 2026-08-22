import 'package:baktaz_flutter/app/constants/constant.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SyncStepsService {
  Future<int> fetchDailySteps(String syncSource) async {
    await Future<void>.delayed(Constant.debounceDelay);

    // TODO(health-connect): Integrate Android Health Connect SDK (package:health)
    // TODO(healthkit): Integrate iOS Apple HealthKit SDK
    // TODO(strava): Integrate Strava REST API OAuth client
    // TODO(samsung): Integrate Samsung Health SDK

    return 8450;
  }
}
