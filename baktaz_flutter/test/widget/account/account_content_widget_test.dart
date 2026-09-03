import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  setUpAll(setupInjection);

  group(AccountContentWidget, () {
    final Map<AccountHeader, List<String>> sampleGroupedOptions = <AccountHeader, List<String>>{
      AccountHeader.accountMonetization: AccountHeader.accountMonetization.options,
      AccountHeader.preferencesSettings: AccountHeader.preferencesSettings.options,
      AccountHeader.supportLegal: AccountHeader.supportLegal.options,
    };

    goldenTest(
      'renders correctly',
      fileName: 'account_content_widget'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default with grouped options',
            child: MockMaterialApp(
              surfaceHeight: 1200,
              child: Scaffold(
                body: AccountContentWidget(
                  groupedOptions: sampleGroupedOptions,
                  isStepsSyncActive: false,
                  onOptionsTap: (_) {},
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'single category options',
            child: MockMaterialApp(
              surfaceHeight: 400,
              child: Scaffold(
                body: AccountContentWidget(
                  groupedOptions: const <AccountHeader, List<String>>{
                    AccountHeader.accountMonetization: <String>['managePayment', 'healthSync'],
                  },
                  isStepsSyncActive: false,
                  onOptionsTap: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('triggers onOptionsTap callback when an option tile is tapped', (WidgetTester tester) async {
      String? tappedOption;

      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: AccountContentWidget(
              groupedOptions: const <AccountHeader, List<String>>{
                AccountHeader.accountMonetization: <String>['managePayment'],
              },
              isStepsSyncActive: false,
              onOptionsTap: (String option) {
                tappedOption = option;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Finder tileFinder = find.text('Manage Payment');
      expect(tileFinder, findsOneWidget);

      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      expect(tappedOption, equals('managePayment'));
    });
  });
}
