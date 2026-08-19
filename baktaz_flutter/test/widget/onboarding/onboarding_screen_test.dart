import 'package:alchemist/alchemist.dart';
import 'package:baktaz_flutter/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../../utils/mock_go_router_provider.dart';
import '../../utils/mock_material_app.dart';
import '../../utils/test_utils.dart';

void main() {
  group(OnboardingScreen, () {
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    tearDown(() {
      reset(mockGoRouter);
    });

    goldenTest(
      'renders correctly',
      fileName: 'onboarding_screen'.goldensVersion,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'initial page 1',
            child: MockMaterialApp(
              child: MockGoRouterProvider(router: mockGoRouter, child: const OnboardingScreen()),
            ),
          ),
        ],
      ),
    );

    testWidgets('renders first page content initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(router: mockGoRouter, child: const OnboardingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Turn Steps Into Real Rewards'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates through pages when Next button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(router: mockGoRouter, child: const OnboardingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Page 1 -> Page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Compete & Connect'), findsOneWidget);

      // Page 2 -> Page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Fair & Verified'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('navigates to /login when Skip is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(router: mockGoRouter, child: const OnboardingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/login')).called(1);
    });

    testWidgets('navigates to /login when Get Started is tapped on last page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(router: mockGoRouter, child: const OnboardingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Go to page 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Go to page 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/login')).called(1);
    });
  });
}
