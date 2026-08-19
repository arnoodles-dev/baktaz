import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/content/presentation/widgets/content_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';
import '../../../../utils/test_utils.dart';

void main() {
  group(ContentPageHeader, () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'content_page_header'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'no pending changes',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: ContentPageHeader(onSaveDraft: () {}, onPublish: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'with pending changes',
            child: MockMaterialApp(
              surfaceWidth: 800,
              surfaceHeight: 120,
              child: ContentPageHeader(onSaveDraft: () {}, onPublish: () {}, hasPendingChanges: true),
            ),
          ),
        ],
      ),
    );
  });
}
