import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/dialogs/edit_parameter_dialog.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';

void main() {
  final RemoteConfigValue stringValue = RemoteConfigValue(
    valueType: ConfigValueType.string,
    defaultValue: ConfigDefaultValue(value: ValueString('test', fieldName: 'test')),
  );
  final RemoteConfigValue booleanValue = RemoteConfigValue(
    valueType: ConfigValueType.boolean,
    defaultValue: ConfigDefaultValue(value: ValueString('true', fieldName: 'test')),
  );
  final RemoteConfigValue numberValue = RemoteConfigValue(
    valueType: ConfigValueType.number,
    defaultValue: ConfigDefaultValue(value: ValueString('42', fieldName: 'test')),
  );
  final RemoteConfigValue jsonValue = RemoteConfigValue(
    valueType: ConfigValueType.json,
    defaultValue: ConfigDefaultValue(value: ValueString('{"key":"val"}', fieldName: 'test')),
  );

  group('EditParameterDialog Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'edit_parameter_dialog',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'string type',
            child: MockMaterialApp(
              child: EditParameterDialog(
                parameterKey: 'test_key',
                currentValue: stringValue,
                onSave: (String key, RemoteConfigValue value) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'boolean type',
            child: MockMaterialApp(
              child: EditParameterDialog(
                parameterKey: 'test_key',
                currentValue: booleanValue,
                onSave: (String key, RemoteConfigValue value) {},
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'number type',
            child: MockMaterialApp(
              child: EditParameterDialog(
                parameterKey: 'test_key',
                currentValue: numberValue,
                onSave: (String key, RemoteConfigValue value) {},
              ),
            ),
          ),
        ],
      ),
    );
  });

  group('EditParameterDialog Widget Tests', () {
    testWidgets('renders string type with text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: stringValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('renders boolean type with dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: booleanValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('shows validation error for empty value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: stringValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '');
      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('shows validation error for invalid number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: numberValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'not_a_number');
      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('number'), findsWidgets);
    });

    testWidgets('shows validation error for invalid JSON', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: jsonValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'not json');
      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('JSON'), findsWidgets);
    });

    testWidgets('calls onSave with updated value', (WidgetTester tester) async {
      String? savedKey;
      RemoteConfigValue? savedValue;

      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: stringValue,
            onSave: (String key, RemoteConfigValue value) {
              savedKey = key;
              savedValue = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'new_value');
      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(savedKey, 'my_key');
      expect(savedValue, isNotNull);
    });

    testWidgets('pops dialog on cancel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: stringValue,
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BaktazButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('renders with initial description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: EditParameterDialog(
            parameterKey: 'my_key',
            currentValue: stringValue,
            initialDescription: 'A test description',
            onSave: (String key, RemoteConfigValue value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A test description'), findsOneWidget);
    });
  });
}
