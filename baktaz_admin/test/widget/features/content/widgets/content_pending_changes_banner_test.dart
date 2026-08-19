import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_pending_changes_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ContentPendingChangesBanner, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_pending_changes_banner'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'collapsed state',
            child: MockMaterialApp(
              surfaceWidth: 600,
              surfaceHeight: 100,
              child: ContentPendingChangesBanner(changeCount: 3, onPublish: () {}, onDiscard: () {}),
            ),
          ),
        ],
      ),
    );
  });
}
