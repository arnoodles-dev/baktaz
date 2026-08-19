import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_container.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(AccountDetailsContainer, () {
    goldenTest(
      'renders correctly',
      fileName: 'account_details_container'.goldensVersion,
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default with child content',
            child: const MockMaterialApp(
              surfaceHeight: 200,
              child: Scaffold(
                body: AccountDetailsContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      BaktazText(text: 'Account Details'),
                      Gap(8),
                      BaktazText(text: r'Balance: $100.00'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'loading state with skeletonizer',
            child: const MockMaterialApp(
              surfaceHeight: 200,
              child: Scaffold(
                body: AccountDetailsContainer(
                  isLoading: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      BaktazText(text: 'Loading Account'),
                      Gap(8),
                      BaktazText(text: r'Balance: $0.00'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('renders child widget inside container', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(body: AccountDetailsContainer(child: Text('Test Child Text'))),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Child Text'), findsOneWidget);
    });
  });
}
