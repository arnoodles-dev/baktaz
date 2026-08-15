import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/dialogs/add_parameter_dialog.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../utils/mock_material_app.dart';

void main() {
  group('AddParameterDialog Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'add_parameter_dialog',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default state',
            child: MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
          ),
        ],
      ),
    );
  });

  group('AddParameterDialog Widget Tests', () {
    testWidgets('renders all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(DropdownButtonFormField<ConfigValueType>), findsOneWidget);
    });

    testWidgets('shows validation error when key is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
      );
      await tester.pumpAndSettle();

      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('shows validation error for invalid key format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalid key!');
      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('letters'), findsWidgets);
    });

    testWidgets('calls onSave with correct values when form is valid', (WidgetTester tester) async {
      String? savedKey;
      RemoteConfigValue? savedValue;

      await tester.pumpWidget(
        MockMaterialApp(
          child: AddParameterDialog(
            onSave: (String key, RemoteConfigValue value) {
              savedKey = key;
              savedValue = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final List<TextFormField> fields = tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
      await tester.enterText(find.byWidget(fields[0]), 'test_key');
      await tester.enterText(find.byWidget(fields[1]), 'test_value');
      await tester.pumpAndSettle();

      final Finder saveButton = find.byType(BaktazButton).last;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(savedKey, 'test_key');
      expect(savedValue, isNotNull);
      expect(savedValue!.valueType, ConfigValueType.string);
    });

    testWidgets('switches to boolean dropdown when type is boolean', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<ConfigValueType>));
      await tester.pumpAndSettle();

      final Finder booleanOption = find.byWidgetPredicate(
        (Widget widget) => widget is DropdownMenuItem<ConfigValueType> && widget.value == ConfigValueType.boolean,
      );
      await tester.tap(booleanOption);
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('pops dialog on cancel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(child: AddParameterDialog(onSave: (String key, RemoteConfigValue value) {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BaktazButton).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
