import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import '../utils/test_utils.dart';

final Either<String, IconData> _starIcon = Either<String, IconData>.right(Icons.star);

void main() {
  group(BaktazIcon, () {
    goldenTest(
      'renders correctly across different variants',
      fileName: 'baktaz_icon'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default icon',
            child: BaktazIcon(icon: _starIcon),
          ),
          GoldenTestScenario(
            name: 'custom size and color',
            child: BaktazIcon(icon: _starIcon, size: 48, color: Colors.red),
          ),
          GoldenTestScenario(
            name: 'copyWith color',
            child: BaktazIcon(icon: _starIcon, size: 24).copyWith(copyColor: Colors.blue),
          ),
          GoldenTestScenario(
            name: 'with child',
            child: BaktazIcon(icon: _starIcon, child: const Text('Label')),
          ),
        ],
      ),
    );
  });
}
