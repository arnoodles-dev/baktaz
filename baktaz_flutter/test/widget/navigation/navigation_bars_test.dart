import 'package:baktaz_flutter/features/challenge/presentation/widgets/challenge_app_bar.dart';
import 'package:baktaz_flutter/features/message/presentation/widgets/message_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../../utils/mock_go_router_provider.dart';
import '../../utils/mock_material_app.dart';

void main() {
  group(ChallengeAppBar, () {
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    tearDown(() {
      reset(mockGoRouter);
    });

    testWidgets('renders challenge title and history button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(router: mockGoRouter, child: const ChallengeAppBar()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Challenge'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });

  group(MessageAppBar, () {
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    tearDown(() {
      reset(mockGoRouter);
    });

    Future<void> pumpMessageAppBar(WidgetTester tester, {int initialIndex = 0}) async {
      final ValueNotifier<int> selectedIndex = ValueNotifier<int>(initialIndex);
      await tester.pumpWidget(
        MockMaterialApp(
          child: MockGoRouterProvider(
            router: mockGoRouter,
            child: MessageAppBar(selectedIndex: selectedIndex),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders Messages title and Chats/Notifications tabs', (WidgetTester tester) async {
      await pumpMessageAppBar(tester);

      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('switches to Notifications tab when tapped and navigates', (WidgetTester tester) async {
      await pumpMessageAppBar(tester);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go(any)).called(1);
    });

    testWidgets('navigates to Chats when Chats tab tapped while on notifications', (WidgetTester tester) async {
      await pumpMessageAppBar(tester, initialIndex: 1);

      await tester.tap(find.text('Chats'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go(any)).called(1);
    });
  });
}
