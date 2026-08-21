import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/local_file_comparator_with_threshold.dart';

// ignore_for_file: avoid_redundant_argument_values,prefer-match-file-name
class TestConfig {
  /// Added a goldens version to know when the golden files were last updated
  /// To update the golden files in the remote repository change goldensVersion
  /// Format: yyyyMMdd
  static String get goldensVersion => '20260821';

  /// Customize your threshold here
  /// For example, the error threshold here is 15%
  /// Golden tests will pass if the pixel difference is equal to or below 15%
  static double get goldenTestsThreshold => 15 / 100;
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  if (goldenFileComparator is LocalFileComparator) {
    final Uri testUrl = (goldenFileComparator as LocalFileComparator).basedir;

    goldenFileComparator = LocalFileComparatorWithThreshold(
      Uri.parse('$testUrl/test.dart'),
      TestConfig.goldenTestsThreshold,
    );
  } else {
    throw Exception(
      'Expected `goldenFileComparator` to be of type `LocalFileComparator`, '
      'but it is of type `${goldenFileComparator.runtimeType}`',
    );
  }

  final ThemeData lightTheme = BaseTheme.buildBaseTheme(AppColors.lightColorScheme);

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      forceUpdateGoldenFiles: true,
      goldenTestTheme: GoldenTestTheme.standard().copyWith(
        backgroundColor: Colors.white,
        borderColor: Colors.black,
        padding: const EdgeInsets.all(16),
        nameTextStyle: AppTextStyle.baseTextStyle,
      ) as GoldenTestTheme,
      theme: lightTheme,
      platformGoldensConfig: const PlatformGoldensConfig(enabled: !bool.fromEnvironment('CI', defaultValue: false)),
      ciGoldensConfig: CiGoldensConfig(obscureText: false, renderShadows: false, theme: lightTheme),
    ),
    run: testMain,
  );
}
