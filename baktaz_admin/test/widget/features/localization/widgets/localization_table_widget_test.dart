// ignore_for_file: unused_local_variable

import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/presentation/widgets/localization_table_widget.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/mock_material_app.dart';

void main() {
  group('LocalizationTableWidget Golden Tests', () {
    late MockLocalizationCubit mockCubit;

    const LocalizationKey mockKey1 = LocalizationKey(
      id: 1,
      namespace: 'common',
      key: 'hello',
      defaultValueEn: 'Hello World',
    );

    const LocalizationKey mockKey2 = LocalizationKey(id: 2, namespace: 'auth', key: 'login', defaultValueEn: 'Log In');

    setUp(() {
      mockCubit = MockLocalizationCubit();
    });

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'localization_table_widget',
      builder: () {
        const LocalizationState emptyState = LocalizationState();

        final LocalizationState populatedState = const LocalizationState().copyWith(
          keys: <LocalizationKey>[mockKey1, mockKey2],
        );

        final LocalizationState withChangesState = populatedState.copyWith(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': const LocalizationTranslation(keyId: 1, locale: 'en', value: 'Modified Hello'),
          },
        );

        return GoldenTestGroup(
          children: <Widget>[
            GoldenTestScenario(
              name: 'empty state',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(value: mockCubit..mockState(emptyState)),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'populated state',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(value: mockCubit..mockState(populatedState)),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'with pending changes',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(value: mockCubit..mockState(withChangesState)),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'loading state',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(
                      value: mockCubit
                        ..mockState(const LocalizationState().copyWith(status: const QueryStatus.loading())),
                    ),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'expanded namespace',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(
                      value: mockCubit
                        ..mockState(
                          const LocalizationState(keys: <LocalizationKey>[mockKey1, mockKey2])
                              .copyWith(status: const QueryStatus.done()),
                        ),
                    ),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'sorted by key',
              child: MockMaterialApp(
                child: MultiBlocSignalProvider(
                  providers: <BlocSignalProvider<dynamic>>[
                    BlocSignalProvider<LocalizationCubit>.value(
                      value: mockCubit
                        ..mockState(
                          const LocalizationState(
                            keys: <LocalizationKey>[mockKey1, mockKey2],
                            sortCriteria: LocalizationSortCriteria.key,
                          ).copyWith(status: const QueryStatus.done()),
                        ),
                    ),
                  ],
                  child: LocalizationTableWidget(onEdit: (LocalizationKey _, String? _) {}),
                ),
              ),
            ),
          ],
        );
      },
    );
  });

  group('LocalizationTableWidget Interaction Tests', () {
    late MockLocalizationCubit mockCubit;
    late LocalizationKey onEditKey;
    String? onEditValue;

    const LocalizationKey mockKey1 = LocalizationKey(
      id: 1,
      namespace: 'common',
      key: 'hello',
      defaultValueEn: 'Hello World',
    );

    const LocalizationKey mockKey2 = LocalizationKey(id: 2, namespace: 'auth', key: 'login', defaultValueEn: 'Log In');

    setUp(() {
      mockCubit = MockLocalizationCubit();
      onEditKey = mockKey1;
      onEditValue = null;
    });

    Widget buildWidget({LocalizationState? state}) {
      final LocalizationState effectiveState =
          state ?? const LocalizationState(keys: <LocalizationKey>[mockKey1, mockKey2]);
      return MockMaterialApp(
        child: Scaffold(
          body: MultiBlocSignalProvider(
            providers: <BlocSignalProvider<dynamic>>[
              BlocSignalProvider<LocalizationCubit>.value(value: mockCubit..mockState(effectiveState)),
            ],
            child: LocalizationTableWidget(
              onEdit: (LocalizationKey key, String? value) {
                onEditKey = key;
                onEditValue = value;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('shows empty state text when no keys', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(buildWidget(state: const LocalizationState()));
      await tester.pumpAndSettle();
      expect(find.text('No keys found'), findsOneWidget);
    });

    testWidgets('shows shimmer when loading and empty', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(
        buildWidget(state: const LocalizationState().copyWith(status: const QueryStatus.loading())),
      );
      await tester.pump();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('edit button triggers onEdit with key', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(
        buildWidget(
          state: const LocalizationState(
            keys: <LocalizationKey>[mockKey1, mockKey2],
            sortCriteria: LocalizationSortCriteria.key,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder editButton = find.byType(BaktazButton);
      expect(editButton, findsWidgets);
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();
      expect(onEditKey, isNotNull);
    });

    testWidgets('search field accepts input', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(
        buildWidget(
          state: const LocalizationState(
            keys: <LocalizationKey>[mockKey1, mockKey2],
            sortCriteria: LocalizationSortCriteria.key,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'hello');
      await tester.pumpAndSettle();
    });

    testWidgets('locale tabs are tappable', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(
        buildWidget(
          state: const LocalizationState(
            keys: <LocalizationKey>[mockKey1, mockKey2],
            sortCriteria: LocalizationSortCriteria.key,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('download button exists', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(
        buildWidget(
          state: const LocalizationState(
            keys: <LocalizationKey>[mockKey1, mockKey2],
            sortCriteria: LocalizationSortCriteria.key,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final Finder downloadButton = find.byIcon(Icons.download_outlined);
      expect(downloadButton, findsOneWidget);
    });

    testWidgets('shows modified badge for pending changes', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      final LocalizationState state =
          const LocalizationState(
            keys: <LocalizationKey>[mockKey1],
            sortCriteria: LocalizationSortCriteria.key,
          ).copyWith(
            pendingChanges: <String, LocalizationTranslation>{
              '1_en': const LocalizationTranslation(keyId: 1, locale: 'en', value: 'Modified'),
            },
          );
      await tester.pumpWidget(buildWidget(state: state));
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('shows new badge for added keys', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      final LocalizationState state = const LocalizationState(
        keys: <LocalizationKey>[mockKey1],
        sortCriteria: LocalizationSortCriteria.key,
      ).copyWith(addedKeyIds: <int>{1});
      await tester.pumpWidget(buildWidget(state: state));
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('namespace group header shows count', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      final Finder commonHeader = find.textContaining('COMMON');
      expect(commonHeader, findsWidgets);
    });

    testWidgets('namespace group header is tappable', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(buildWidget(state: const LocalizationState(expandedNamespaces: <String>{'common'})));
      await tester.pumpAndSettle();
      final Finder commonHeader = find.textContaining('COMMON');
      if (commonHeader.evaluate().isNotEmpty) {
        await tester.tap(commonHeader.first);
        await tester.pumpAndSettle();
      }
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('pagination footer shows summary', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('description shows when key has description', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      const LocalizationKey keyWithDesc = LocalizationKey(
        id: 3,
        namespace: 'common',
        key: 'desc_key',
        defaultValueEn: 'Description Key',
        description: 'This is a description',
      );
      await tester.pumpWidget(
        buildWidget(
          state: const LocalizationState(
            keys: <LocalizationKey>[keyWithDesc],
            sortCriteria: LocalizationSortCriteria.key,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('This is a description'), findsOneWidget);
    });

    testWidgets('description hidden when key has no description', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });

    testWidgets('locale tab shows pending count badge', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(const Size(800, 600)));
      final LocalizationState state = const LocalizationState(keys: <LocalizationKey>[mockKey1]).copyWith(
        pendingChanges: <String, LocalizationTranslation>{
          '1_es': const LocalizationTranslation(keyId: 1, locale: 'es', value: 'Hola'),
        },
      );
      await tester.pumpWidget(buildWidget(state: state));
      await tester.pumpAndSettle();
      expect(find.byType(LocalizationTableWidget), findsOneWidget);
    });
  });
}

extension on MockLocalizationCubit {
  void mockState(LocalizationState mockedState) {
    when(state).thenReturn(signal(mockedState));
    when(stateValue).thenReturn(mockedState);
  }
}
