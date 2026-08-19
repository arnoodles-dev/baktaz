import 'package:alchemist/alchemist.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/shared_fixtures.dart';
import '../utils/test_utils.dart';

void main() {
  group(BaktazTextField, () {
    goldenTest(
      'renders correctly across all text field types and states',
      fileName: 'baktaz_text_field'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'normal text field',
            child: SizedBox(
              width: 300,
              child: BaktazTextField(
                controller: TextEditingController(text: SharedFixtures.sampleText),
                labelText: 'Username',
                hintText: 'Enter username',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'password text field',
            child: SizedBox(
              width: 300,
              child: BaktazTextField(
                controller: TextEditingController(text: 'secret123'),
                textFieldType: TextFieldType.password,
                labelText: 'Password',
                hintText: 'Enter password',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'email text field',
            child: SizedBox(
              width: 300,
              child: BaktazTextField(
                controller: TextEditingController(text: 'user@example.com'),
                textFieldType: TextFieldType.email,
                labelText: 'Email',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'disabled text field',
            child: SizedBox(
              width: 300,
              child: BaktazTextField(
                controller: TextEditingController(text: SharedFixtures.sampleText),
                labelText: 'Disabled',
                isDisabled: true,
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('allows text entry and triggers onChanged', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();
      String changedValue = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazTextField(
              controller: controller,
              labelText: 'Input',
              onChanged: (String val) => changedValue = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pumpAndSettle();

      expect(controller.text, equals('Hello World'));
      expect(changedValue, equals('Hello World'));
    });

    testWidgets('toggles password visibility when icon tapped', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(text: 'password123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaktazTextField(controller: controller, textFieldType: TextFieldType.password, labelText: 'Password'),
          ),
        ),
      );

      final Finder textFieldFinder = find.byType(TextField);
      TextField textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('password_icon')));
      await tester.pumpAndSettle();

      textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.obscureText, isFalse);
    });
  });
}
