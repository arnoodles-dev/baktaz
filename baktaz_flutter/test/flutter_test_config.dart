import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_client/baktaz_client.dart' as sp;
import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';

import 'utils/local_file_comparator_with_threshold.dart';
import 'utils/test_utils.dart';

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
  GoogleFonts.config.allowRuntimeFetching = false;
  provideDummy<AppLocale>(AppLocale.en);
  provideDummy<I18n>(AppLocale.en.buildSync());
  provideDummy<TaskResult<bool?>>(TaskResult<bool?>.right(null));
  provideDummy<TaskResult<Unit>>(TaskResult<Unit>.right(unit));
  provideDummy<TaskResult<Profile>>(
    TaskResult<Profile>.right(Profile(fullName: ValueName('dummy'), gender: sp.Gender.unknown)),
  );
  provideDummy<TaskResult<(String, String)>>(TaskResult<(String, String)>.right(('dummy', 'dummy')));
  provideDummy<Either<Failure, String>>(right<Failure, String>('dummy'));

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
    ByteData? message,
  ) async {
    if (message == null) {
      return null;
    }
    final String key = utf8.decode(message.buffer.asUint8List());
    if (key == 'FontManifest.json' || key == 'FontManifest.bin') {
      return ByteData.sublistView(utf8.encode('[]'));
    }
    if (key == 'AssetManifest.json' || key == 'AssetManifest.bin') {
      return ByteData.sublistView(utf8.encode('{}'));
    }
    File file = File(key);
    if (!file.existsSync()) {
      file = File('baktaz_flutter/$key');
    }
    if (file.existsSync()) {
      final Uint8List bytes = await file.readAsBytes();
      return ByteData.sublistView(bytes);
    }
    return null;
  });

  await Future.wait(<Future<void>>[setupInjection()]);

  if (goldenFileComparator is LocalFileComparator) {
    final Uri testUrl = (goldenFileComparator as LocalFileComparator).basedir;

    goldenFileComparator = LocalFileComparatorWithThreshold(
      // flutter_test's LocalFileComparator expects the test's URI to be passed
      // as an argument, but it only uses it to parse the baseDir in order to
      // obtain the directory where the golden tests will be placed.
      // As such, we use the default `testUrl`, which is only the `baseDir` and
      // append a generically named `test.dart` so that the `baseDir` is
      // properly extracted.
      Uri.parse('$testUrl/test.dart'),
      TestConfig.goldenTestsThreshold,
    );
  } else {
    throw Exception(
      'Expected `goldenFileComparator` to be of type `LocalFileComparator`, '
      'but it is of type `${goldenFileComparator.runtimeType}`',
    );
  }

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      forceUpdateGoldenFiles: true,
      goldenTestTheme: GoldenTestTheme.standard().copyWith(
        backgroundColor: Colors.white,
        borderColor: Colors.black,
        padding: const EdgeInsets.all(16),
        nameTextStyle: AppTextStyle.baseTextStyle,
      ) as GoldenTestTheme,
      theme: AppTheme.light,
      platformGoldensConfig: const PlatformGoldensConfig(enabled: !bool.fromEnvironment('CI', defaultValue: false)),
      ciGoldensConfig: CiGoldensConfig(obscureText: false, renderShadows: false, theme: AppTheme.light),
    ),
    run: testMain,
  );
}
