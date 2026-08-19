import 'dart:async';

import 'package:baktaz_flutter/core/presentation/widgets/dialogs/country_selector_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';

void main() {
  group(CountrySelectorBottomSheet, () {
    Future<void> showSheet(WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(child: Scaffold(body: SizedBox.shrink())));
      final BuildContext context = tester.element(find.byType(Scaffold));
      // Show as bottom sheet so Navigator/DraggableScrollableSheet work.
      unawaited(showModalBottomSheet<void>(context: context, builder: (_) => const CountrySelectorBottomSheet()));
      await tester.pumpAndSettle();
    }

    test('sorts Philippines first in phone country data list', () {
      final List<PhoneCountryData> list = const CountrySelectorBottomSheet().phoneCountryDataList;
      expect(list.first, equals(CountrySelectorBottomSheet.defaultCountry));
    });

    test('removeParentheses strips parenthesized text', () {
      const CountrySelectorBottomSheet sheet = CountrySelectorBottomSheet();
      expect(sheet.removeParentheses('United States (+1)'), equals('United States'));
      expect(sheet.removeParentheses(null), equals(''));
    });

    testWidgets('renders select country title and search field', (WidgetTester tester) async {
      await showSheet(tester);

      expect(find.text('Select a country'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('tapping backdrop closes the sheet', (WidgetTester tester) async {
      await showSheet(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Select a country'), findsNothing);
    });
  });
}
