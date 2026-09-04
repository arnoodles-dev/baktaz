// ignore_for_file: prefer-match-file-name

import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:injectable/injectable.dart';

abstract interface class IStepTelemetryService {
  String get providerName;
  Future<int?> fetchTodaySteps();
  Future<bool> requestPermissions();
  Future<bool> checkPermissionStatus();
}

@LazySingleton(as: IStepTelemetryService)
final class StepTelemetryService implements IStepTelemetryService {
  StepTelemetryService() : _health = Health();

  @visibleForTesting
  StepTelemetryService.withHealth(this._health);

  final Health _health;

  static const List<HealthDataType> _types = <HealthDataType>[HealthDataType.STEPS];

  @override
  String get providerName => io.Platform.isIOS
      ? 'HealthKit'
      : (io.Platform.isAndroid ? 'Health Connect' : 'none');

  @override
  Future<int?> fetchTodaySteps() async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      return null;
    }
    try {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(now.year, now.month, now.day);
      return await _health.getTotalStepsInInterval(startOfDay, now);
    } on Object catch (_) {
      return null;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      return false;
    }
    try {
      return await _health.requestAuthorization(_types);
    } on Object catch (_) {
      return false;
    }
  }

  @override
  Future<bool> checkPermissionStatus() async {
    if (kIsWeb || (!io.Platform.isAndroid && !io.Platform.isIOS)) {
      return false;
    }
    try {
      final bool? hasPermission = await _health.hasPermissions(_types);
      return hasPermission ?? false;
    } on Object catch (_) {
      return false;
    }
  }
}
