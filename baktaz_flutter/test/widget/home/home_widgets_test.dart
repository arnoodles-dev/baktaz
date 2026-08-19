import 'package:baktaz_flutter/features/home/presentation/widgets/home_app_bar.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_carousel.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_featured_content.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_search_bar.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_services_grid.dart';
import 'package:baktaz_flutter/features/home/presentation/widgets/home_title_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/mock_material_app.dart';

void main() {
  group(HomeTitleHeader, () {
    testWidgets('renders title without see-all when callback is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(body: HomeTitleHeader(title: 'Featured')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('See All'), findsNothing);
    });

    testWidgets('renders see-all and invokes callback when tapped', (WidgetTester tester) async {
      bool? pressed;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeTitleHeader(
              title: 'Featured',
              onSeeAllPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Featured'), findsOneWidget);
      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });

  group(HomeFeaturedContent, () {
    testWidgets('renders items via itemBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          surfaceHeight: 300,
          child: Scaffold(
            body: HomeFeaturedContent(
              title: 'Featured',
              isLoading: false,
              itemCount: 2,
              height: 200,
              itemBuilder: (BuildContext context, int index) => SizedBox(width: 100, child: Text('Item $index')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('renders skeleton when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          surfaceHeight: 300,
          child: Scaffold(
            body: HomeFeaturedContent(
              title: 'Featured',
              isLoading: true,
              itemCount: 2,
              height: 200,
              itemBuilder: (BuildContext context, int index) => const SizedBox(width: 100),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Featured'), findsOneWidget);
    });
  });

  group(HomeServicesGrid, () {
    testWidgets('renders four service cards', (WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(child: Scaffold(body: HomeServicesGrid())));

      await tester.pumpAndSettle();

      expect(find.text('Shops'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Heroes'), findsOneWidget);
      expect(find.text('Express'), findsOneWidget);
    });
  });

  group(HomeSearchBar, () {
    testWidgets('renders search icon and hint text', (WidgetTester tester) async {
      await tester.pumpWidget(const MockMaterialApp(child: Scaffold(body: HomeSearchBar())));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group(HomeAppBar, () {
    testWidgets('renders greeting fallback and name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeAppBar(isLoading: false, onChangeAddress: () {}, name: 'Jane Doe'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('renders custom greeting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeAppBar(isLoading: false, onChangeAddress: () {}, name: 'Jane Doe', greeting: 'Good morning'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Good morning'), findsOneWidget);
    });

    testWidgets('invokes onChangeAddress when location tapped', (WidgetTester tester) async {
      bool? addressChanged;
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: HomeAppBar(
              isLoading: false,
              onChangeAddress: () {
                addressChanged = true;
              },
              name: 'Jane Doe',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pumpAndSettle();
      expect(addressChanged, isTrue);
    });
  });

  group(HomeCarousel, () {
    testWidgets('renders carousel items and indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          surfaceHeight: 300,
          child: Scaffold(
            body: HomeCarousel(
              itemsCount: 1,
              itemBuilder: (BuildContext context, int index, int pageCount) => Text('Slide $index'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Slide 0'), findsOneWidget);
    });
  });
}
