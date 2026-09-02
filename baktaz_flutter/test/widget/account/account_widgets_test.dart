import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_content.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_tile.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/challenge_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  setUpAll(setupInjection);

  group(AccountDetailsTile, () {
    testWidgets('renders label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsTile(label: 'Name', value: 'John Doe'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders label only when value is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsTile(label: 'Name', value: null),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);
    });
  });

  group(AccountDetailsContent, () {
    testWidgets('renders title and children', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsContent(
              title: 'Contact Details',
              children: <Widget>[Text('Child Content')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Child Content'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
    });
    testWidgets('renders edit icon when onEdit provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsContent(
              title: 'Contact Details',
              onEdit: () {},
              children: const <Widget>[Text('Child')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group(ChallengeStatsGrid, () {
    testWidgets('renders stat cards correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: ChallengeStatsGrid(
              isLoading: false,
              totalSteps: 12500,
              challengesJoined: 10,
              challengesWon: 5,
              winRatePercentage: 50,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('12500'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget);
    });
  });
}
