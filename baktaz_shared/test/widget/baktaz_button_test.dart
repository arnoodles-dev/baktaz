import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(BaktazButton, () {
    goldenTest(
      'renders correctly across all button types and states',
      pumpBeforeTest: (WidgetTester tester) async => tester.pump(const Duration(milliseconds: 100)),
      fileName: 'baktaz_button'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'filled button',
            child: BaktazButton(text: SharedFixtures.sampleText, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'destructive button',
            child: BaktazButton(text: SharedFixtures.sampleText, buttonType: ButtonType.destructive, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'outlined button',
            child: BaktazButton(text: SharedFixtures.sampleText, buttonType: ButtonType.outlined, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'tonal button',
            child: BaktazButton(text: SharedFixtures.sampleText, buttonType: ButtonType.tonal, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'text button',
            child: BaktazButton(text: SharedFixtures.sampleText, buttonType: ButtonType.text, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'elevated button',
            child: BaktazButton(text: SharedFixtures.sampleText, buttonType: ButtonType.elevated, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'disabled button',
            child: BaktazButton(text: SharedFixtures.sampleText, isEnabled: false, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'loading button',
            child: BaktazButton(text: SharedFixtures.sampleText, isLoading: true, onPressed: () {}),
          ),
          GoldenTestScenario(
            name: 'button with icon',
            child: BaktazButton(text: SharedFixtures.sampleText, icon: const Icon(Icons.add), onPressed: () {}),
          ),
        ],
      ),
    );

    testWidgets('triggers onPressed when tapped and enabled', (WidgetTester tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazButton(text: 'Click Me', onPressed: () => wasPressed = true),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('does not trigger onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazButton(text: 'Click Me', isEnabled: false, onPressed: () => wasPressed = true),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(wasPressed, isFalse);
    });
  });
}
