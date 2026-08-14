import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:mobile_service/features/analytics/analytics_service.dart';
import 'package:mobile_service/features/crashlytics/crashlytics_service.dart';
import 'package:mobile_service/features/remote_config/remote_config_service.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';
import 'package:mobile_service_core/mobile_service_core.dart';

class MobileServiceRepository extends IMobileServiceRepository {
  @override
  Future<void> initialize({required bool enablePerformanceMonitor, dynamic options}) async {
    await Firebase.initializeApp(options: options as FirebaseOptions);
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(enablePerformanceMonitor);
  }

  @override
  MobileServiceType provideMobileServiceType() => MobileServiceType.gms;

  @override
  IAnalyticsService provideAnalyticsService() => GMSAnalyticsService();

  @override
  IRemoteConfigService provideRemoteConfigService() => GMSRemoteConfigService();

  @override
  ICrashlyticsService provideCrashlyticsService() => GMSCrashlyticsService();
}
