import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazSectionHeader, () {
    goldenTest(
      'renders section header with and without link',
      fileName: 'baktaz_section_header'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'header only',
            child: const SizedBox(width: 350, child: BaktazSectionHeader(title: 'Recent Activity')),
          ),
          GoldenTestScenario(
            name: 'header with action link',
            child: SizedBox(
              width: 350,
              child: BaktazSectionHeader(title: 'Featured Items', linkLabel: 'See All', onLinkPressed: () {}),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onLinkPressed when action link is tapped', (WidgetTester tester) async {
      bool linkTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazSectionHeader(
              title: 'Categories',
              linkLabel: 'View All',
              onLinkPressed: () => linkTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(linkTapped, isTrue);
    });
  });
}
