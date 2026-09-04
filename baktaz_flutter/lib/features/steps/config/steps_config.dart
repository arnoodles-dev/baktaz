/// Default constants for the Steps feature.
library;

import 'dart:io' as io;

abstract final class StepsConfig {
  /// Default daily step goal when no server value is available.
  static const int defaultGoalSteps = 10000;

  /// Default sync provider name when no server value is available.
  static const String defaultProvider = 'Health Connect';

  /// Returns the default health provider name for the current platform.
  static String defaultProviderForPlatform() =>
      io.Platform.isIOS ? 'HealthKit' : 'Health Connect';
}
