import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ContentStatsSection, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_stats_section'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default stats',
            child: const MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: ContentStatsSection(activeCount: 12, scheduledCount: 4, draftCount: 2),
            ),
          ),
        ],
      ),
    );
  });
}
