import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/core/presentation/widgets/app_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(AppTitle, () {
    goldenTest(
      'renders correctly',
      fileName: 'app_title'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'renders app name',
            child: const MockMaterialApp(surfaceHeight: 200, child: AppTitle()),
          ),
        ],
      ),
    );
  });
}
