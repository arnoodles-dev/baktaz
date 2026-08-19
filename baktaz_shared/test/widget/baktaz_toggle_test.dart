import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_utils.dart';

void main() {
  group(BaktazToggle, () {
    goldenTest(
      'renders toggle switch in off and on states',
      fileName: 'baktaz_toggle'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'toggle off',
            child: BaktazToggle(value: false, onChanged: (_) {}),
          ),
          GoldenTestScenario(
            name: 'toggle on',
            child: BaktazToggle(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );

    testWidgets('triggers onChanged when tapped', (WidgetTester tester) async {
      bool? newValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: BaktazToggle(value: false, onChanged: (bool val) => newValue = val)),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(newValue, isTrue);
    });
  });
}
