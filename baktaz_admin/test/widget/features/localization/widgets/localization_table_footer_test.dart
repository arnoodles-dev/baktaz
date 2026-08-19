import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(LocalizationTableFooter, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_table_footer'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'single page',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 60,
              child: LocalizationTableFooter(
                startIndex: 0,
                endIndex: 10,
                totalItems: 10,
                currentPage: 1,
                totalPages: 1,
                onPageChanged: (_) {},
                isNamespacePagination: false,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'multiple pages key pagination',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 60,
              child: LocalizationTableFooter(
                startIndex: 0,
                endIndex: 10,
                totalItems: 35,
                currentPage: 1,
                totalPages: 4,
                onPageChanged: (_) {},
                isNamespacePagination: false,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'namespace pagination',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 60,
              child: LocalizationTableFooter(
                startIndex: 0,
                endIndex: 5,
                totalItems: 12,
                currentPage: 1,
                totalPages: 3,
                onPageChanged: (_) {},
                isNamespacePagination: true,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'empty table',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 60,
              child: LocalizationTableFooter(
                startIndex: 0,
                endIndex: 0,
                totalItems: 0,
                currentPage: 1,
                totalPages: 1,
                onPageChanged: (_) {},
                isNamespacePagination: false,
              ),
            ),
          ),
        ],
      ),
    );
  });
}
