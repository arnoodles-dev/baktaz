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
            name: 'divider with height',
            child: const SizedBox(width: 300, child: BaktazDivider(height: 2)),
          ),
        ],
      ),
    );

    testWidgets('renders with given height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BaktazDivider(height: 2)),
        ),
      );

      final Container divider = tester.widget<Container>(find.byType(Container));
      expect(divider.constraints?.maxHeight, equals(2.0));
    });
  });
}
