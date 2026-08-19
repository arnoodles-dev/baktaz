import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazDivider, () {
    goldenTest(
      'renders correctly with and without label text',
      fileName: 'baktaz_divider'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'plain divider',
            child: const SizedBox(width: 300, child: BaktazDivider()),
          ),
          GoldenTestScenario(
            name: 'divider with text',
            child: const SizedBox(width: 300, child: BaktazDivider(text: 'OR')),
          ),
        ],
      ),
    );

    testWidgets('displays label text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BaktazDivider(text: 'SECTION BREAK')),
        ),
      );

      expect(find.text('SECTION BREAK'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
