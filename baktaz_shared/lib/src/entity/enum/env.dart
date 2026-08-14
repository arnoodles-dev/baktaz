import 'dart:io' show Platform;

import 'package:dartx/dartx.dart';
import 'package:flutter/services.dart';

enum Env {
  development('development'),
  staging('staging'),
  production('production'),
  test('test');

  const Env(this.value);

  factory Env.fromFlavor() {
    const String? flavor = bool.hasEnvironment('ENV') ? String.fromEnvironment('ENV') : appFlavor;

    if (flavor.isNullOrBlank) {
      final bool isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (isTest) return Env.development;
    }

    return switch (flavor?.toLowerCase()) {
      'production' => Env.production,
      'development' => Env.development,
      'staging' => Env.staging,
      _ => throw UnsupportedError('Not supported flavor: $flavor'),
    };
  }

  final String value;
}
