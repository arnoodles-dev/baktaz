import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/home/presentation/home_dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(HomeDashboardView, () {
    goldenTest(
      'renders correctly',
      fileName: 'home_dashboard_view'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'dashboard content',
            child: const MockMaterialApp(surfaceWidth: 600, child: HomeDashboardView()),
          ),
        ],
      ),
    );

    testWidgets('renders steps, wallet balance and top up button', (WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(surfaceWidth: 600, child: HomeDashboardView()));

      await tester.pumpAndSettle();

      expect(find.text("Today's Activity"), findsOneWidget);
      expect(find.text('8,450 steps'), findsOneWidget);
      expect(find.textContaining('Goal:'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
