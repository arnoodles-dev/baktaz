import 'package:flutter/widgets.dart';

abstract class IAnalyticsService {
  NavigatorObserver get navigatorObserver;

  Future<void> setAnalyticsCollectionEnabled({required bool enabled});

  Future<void> logEvent({
    required String screen,
    required String eventLabel,
    required String eventCategory,
    required bool isLoggedIn,
    String? eventAction,
    String? eventName,
    bool useEventLabel = false,
    Map<String, Object>? payload,
  });

  Future<void> setUserProperties({required String userId, String? userRole});

  Future<void> setCurrentView(String view);

  Future<void> logOnOpenApp();

  Future<void> logLogin(String loginMethod);
}
