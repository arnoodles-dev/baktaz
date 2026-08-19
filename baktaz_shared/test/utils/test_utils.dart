// ignore_for_file: prefer-match-file-name

import '../flutter_test_config.dart';

extension FileNameX on String {
  String get goldensVersion => '${this}_${TestConfig.goldensVersion}';
}
