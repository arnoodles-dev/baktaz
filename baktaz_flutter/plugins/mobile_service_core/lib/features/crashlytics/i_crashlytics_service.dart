import 'package:flutter/material.dart';

abstract class ICrashlyticsService {
  Future<void> setCrashlyticsCollectionEnabled({required bool enabled});

  Future<void> reportCrash(Object error, StackTrace? stackTrace);

  Future<void> recordFlutterFatalError(FlutterErrorDetails details);

  Future<void> setUserId(String userId);
}
