import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(LocalizationTableShimmer, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_table_shimmer'.goldensVersion,
      pumpBeforeTest: (WidgetTester tester) async {
        await tester.pump(const Duration(milliseconds: 100));
      },
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default shimmer',
            child: const MockMaterialApp(surfaceWidth: 900, surfaceHeight: 600, child: LocalizationTableShimmer()),
          ),
        ],
      ),
    );
  });
}
