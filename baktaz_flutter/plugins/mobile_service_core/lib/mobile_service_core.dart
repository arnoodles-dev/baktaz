import 'package:flutter/widgets.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

enum MobileServiceType { gms, hms }

abstract class IMobileServiceRepository {
  // Services
  late IAnalyticsService _analyticsService;
  late IRemoteConfigService _remoteConfigService;
  late ICrashlyticsService _crashlyticsService;

  IAnalyticsService get analyticsService => _analyticsService;
  IRemoteConfigService get remoteConfigService => _remoteConfigService;
  ICrashlyticsService get crashlyticsService => _crashlyticsService;

  Future<void> initializeServices({required bool enablePerformanceMonitor, dynamic options}) async {
    await initialize(enablePerformanceMonitor: enablePerformanceMonitor, options: options);
    _analyticsService = provideAnalyticsService();
    _remoteConfigService = provideRemoteConfigService();
    _crashlyticsService = provideCrashlyticsService();
  }

  Future<void> initialize({required bool enablePerformanceMonitor, dynamic options});

  @protected
  IAnalyticsService provideAnalyticsService();

  @protected
  ICrashlyticsService provideCrashlyticsService();

  @protected
  IRemoteConfigService provideRemoteConfigService();

  MobileServiceType provideMobileServiceType();
}
