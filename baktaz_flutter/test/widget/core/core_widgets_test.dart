import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_bottom_sheet.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_nav_bar.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../utils/generated_mocks.mocks.dart';
import '../../utils/mock_material_app.dart';

void main() {
  group(BaktazAppBar, () {
    testWidgets('renders title and actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: BaktazAppBar(title: 'Test Title', actions: <Widget>[Icon(Icons.settings)]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('hides title when showTitle is false', (WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(child: Scaffold(body: BaktazAppBar(showTitle: false))));

      await tester.pumpAndSettle();

      expect(find.text('Baktaz'), findsNothing);
    });

    testWidgets('shows default app name when no title provided', (WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(child: Scaffold(body: BaktazAppBar())));

      await tester.pumpAndSettle();

      expect(find.text('Baktaz'), findsOneWidget);
      expect((tester.widget<BaktazAppBar>(find.byType(BaktazAppBar)) as PreferredSizeWidget).preferredSize, isNotNull);
    });

    testWidgets('renders bottom widget and custom size', (WidgetTester tester) async {
      const Size customSize = Size.fromHeight(80);
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: BaktazAppBar(
              title: 'With Bottom',
              size: customSize,
              bottom: PreferredSize(preferredSize: customSize, child: SizedBox.shrink()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('With Bottom'), findsOneWidget);
      final BaktazAppBar appBar = tester.widget<BaktazAppBar>(find.byType(BaktazAppBar));
      expect(appBar.preferredSize, equals(customSize));
    });
  });

  group(BaktazBottomSheet, () {
    testWidgets('renders children with trailing gap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(body: BaktazBottomSheet(children: <Widget>[Text('Child One'), Text('Child Two')])),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Child One'), findsOneWidget);
      expect(find.text('Child Two'), findsOneWidget);
    });
  });

  group(BaktazNavBar, () {
    late MockStatefulNavigationShell navigationShell;
    late ValueNotifier<int> selectedIndex;

    setUp(() {
      navigationShell = MockStatefulNavigationShell();
      selectedIndex = ValueNotifier<int>(0);
      when(navigationShell.currentIndex).thenReturn(0);
    });

    tearDown(() {
      reset(navigationShell);
    });

    Future<void> pumpNavBar(WidgetTester tester) async {
      final HidableCubit hidableCubit = HidableCubit();
      addTearDown(hidableCubit.close);
      await tester.pumpWidget(
        BlocSignalProvider<HidableCubit>.value(
          value: hidableCubit,
          child: MockMaterialApp(
            surfaceHeight: 600,
            child: Scaffold(
              body: BaktazNavBar(navigationShell: navigationShell, selectedIndex: selectedIndex),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders four navigation items', (WidgetTester tester) async {
      await pumpNavBar(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('has expected preferredSize height', (WidgetTester tester) async {
      final BaktazNavBar navBar = BaktazNavBar(navigationShell: navigationShell, selectedIndex: selectedIndex);
      expect(navBar.preferredSize, equals(const Size.fromHeight(AppTheme.defaultNavBarHeight)));
    });

    testWidgets('goBranch called when item tapped', (WidgetTester tester) async {
      await pumpNavBar(tester);

      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      expect(selectedIndex.value, equals(1));
      verify(navigationShell.goBranch(1)).called(1);
    });

    testWidgets('custom size overrides preferredSize', (WidgetTester tester) async {
      const Size custom = Size.fromHeight(50);
      final BaktazNavBar navBar = BaktazNavBar(
        navigationShell: navigationShell,
        selectedIndex: selectedIndex,
        size: custom,
      );
      expect(navBar.preferredSize, equals(custom));
    });
  });
}
