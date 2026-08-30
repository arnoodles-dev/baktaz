import 'package:baktaz_admin/features/localization/domain/cubit/localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  late MockILocalizationRepository mockRepository;

  setUp(() {
    mockRepository = MockILocalizationRepository();
  });

  setUpAll(() {
    provideDummy<TaskResult<PaginatedResponse<LocalizationKey>>>(
      TaskEither<Failure, PaginatedResponse<LocalizationKey>>.of(
        const PaginatedResponse<LocalizationKey>(data: <LocalizationKey>[], totalCount: 0),
      ),
    );
    provideDummy<TaskResult<Unit>>(TaskEither<Failure, Unit>.of(unit));
  });

  final List<LocalizationKey> mockKeys = <LocalizationKey>[
    const LocalizationKey(id: 1, namespace: 'test', key: 'key1', defaultValueEn: 'Val1'),
    const LocalizationKey(id: 2, namespace: 'test', key: 'key2', defaultValueEn: 'Val2'),
  ];

  group('LocalizationCubit', () {
    blocSignalTest<LocalizationCubit, LocalizationState>(
      'initialize emits loading and done with keys',
      build: () {
        when(mockRepository.getKeys(page: 1, limit: 1000, sortField: 'namespace', ascending: true)).thenReturn(
          TaskEither<Failure, PaginatedResponse<LocalizationKey>>.of(
            PaginatedResponse<LocalizationKey>(data: mockKeys, totalCount: mockKeys.length),
          ),
        );
        return LocalizationCubit(mockRepository);
      },
      act: (LocalizationCubit cubit) => cubit.initialize(),
      expect: () => <LocalizationState>[
        const LocalizationState(status: QueryStatus.loading()),
        LocalizationState(status: const QueryStatus.done(), keys: mockKeys),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'initialize handles failure',
      build: () {
        when(mockRepository.getKeys(page: 1, limit: 1000, sortField: 'namespace', ascending: true))
            .thenReturn(TaskEither<Failure, PaginatedResponse<LocalizationKey>>.left(const Failure.unexpected('err')));
        return LocalizationCubit(mockRepository);
      },
      act: (LocalizationCubit cubit) => cubit.initialize(),
      expect: () => <LocalizationState>[
        const LocalizationState(status: QueryStatus.loading()),
        const LocalizationState(),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'setPage updates state',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.setPage(2),
      expect: () => <LocalizationState>[const LocalizationState(currentPage: 2)],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'selectSortCriteria updates sort criteria',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.selectSortCriteria(LocalizationSortCriteria.key),
      expect: () => <LocalizationState>[const LocalizationState(sortCriteria: LocalizationSortCriteria.key)],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'toggleSortOrder flips ascending',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.toggleSortOrder(),
      expect: () => <LocalizationState>[const LocalizationState(ascending: false)],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'discardChanges clears pending',
      build: () => LocalizationCubit.test(
        mockRepository,
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'test'),
          },
        ),
      ),
      act: (LocalizationCubit cubit) => cubit.discardChanges(),
      expect: () => <LocalizationState>[const LocalizationState()],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'updateTranslation updates pendingChanges',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) {
        cubit.updateTranslation(const LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'));
      },
      expect: () => <LocalizationState>[
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
          },
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'publishChanges clears pending and emits presentation event',
      build: () {
        when(
          mockRepository.publishTranslations(const <LocalizationTranslation>[
            LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
          ]),
        ).thenReturn(TaskEither<Failure, Unit>.of(unit));
        return LocalizationCubit.test(
          mockRepository,
          const LocalizationState(
            pendingChanges: <String, LocalizationTranslation>{
              '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
            },
          ),
        );
      },
      act: (LocalizationCubit cubit) => cubit.publishChanges(),
      expect: () => <LocalizationState>[
        const LocalizationState(
          status: QueryStatus.loading(),
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
          },
        ),
        const LocalizationState(status: QueryStatus.done()),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'toggleNamespace adds and removes namespace path from expandedNamespaces',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) {
        cubit
          ..toggleNamespace('auth.login')
          ..toggleNamespace('auth.login');
      },
      expect: () => <LocalizationState>[
        const LocalizationState(expandedNamespaces: <String>{'auth.login'}),
        const LocalizationState(),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'clearExpanded resets expandedNamespaces to empty set',
      build: () => LocalizationCubit.test(
        mockRepository,
        const LocalizationState(expandedNamespaces: <String>{'auth', 'dashboard'}),
      ),
      act: (LocalizationCubit cubit) => cubit.clearExpanded(),
      expect: () => <LocalizationState>[const LocalizationState()],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'publishChanges handles failure',
      build: () {
        when(mockRepository.publishTranslations(any))
            .thenReturn(TaskEither<Failure, Unit>.left(const Failure.unexpected('err')));
        return LocalizationCubit.test(
          mockRepository,
          const LocalizationState(
            pendingChanges: <String, LocalizationTranslation>{
              '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
            },
          ),
        );
      },
      act: (LocalizationCubit cubit) => cubit.publishChanges(),
      expect: () => <LocalizationState>[
        const LocalizationState(
          status: QueryStatus.loading(),
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
          },
        ),
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'New Val'),
          },
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'selectLocale updates selectedLocale',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.selectLocale('es'),
      expect: () => <LocalizationState>[const LocalizationState(selectedLocale: 'es')],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'setSearchQuery updates searchQuery',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.setSearchQuery('hello'),
      expect: () => <LocalizationState>[const LocalizationState(searchQuery: 'hello')],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'addKey adds key and a pending translation',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.addKey(key: 'hello', namespace: 'common', defaultValueEn: 'Hello World'),
      expect: () => <LocalizationState>[
        const LocalizationState(
          keys: <LocalizationKey>[
            LocalizationKey(id: 1, namespace: 'common', key: 'hello', defaultValueEn: 'Hello World'),
          ],
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'Hello World'),
          },
          addedKeyIds: <int>{1},
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'addKey when keys already exist assigns next id',
      build: () => LocalizationCubit.test(
        mockRepository,
        const LocalizationState(
          keys: <LocalizationKey>[
            LocalizationKey(id: 5, namespace: 'test', key: 'existing', defaultValueEn: 'Existing'),
          ],
        ),
      ),
      act: (LocalizationCubit cubit) => cubit.addKey(key: 'new', namespace: 'common', defaultValueEn: 'New Key'),
      expect: () => <LocalizationState>[
        const LocalizationState(
          keys: <LocalizationKey>[
            LocalizationKey(id: 5, namespace: 'test', key: 'existing', defaultValueEn: 'Existing'),
            LocalizationKey(id: 6, namespace: 'common', key: 'new', defaultValueEn: 'New Key'),
          ],
          pendingChanges: <String, LocalizationTranslation>{
            '6_en': LocalizationTranslation(keyId: 6, locale: 'en', value: 'New Key'),
          },
          addedKeyIds: <int>{6},
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'deleteTranslation adds an empty translation to pendingChanges',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) => cubit.deleteTranslation(1, 'en'),
      expect: () => <LocalizationState>[
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: ''),
          },
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'bulk addKey handles duplicate key names by assigning unique sequential IDs',
      build: () => LocalizationCubit.test(
        mockRepository,
        const LocalizationState(
          keys: <LocalizationKey>[LocalizationKey(id: 1, namespace: 'common', key: 'save', defaultValueEn: 'Save')],
        ),
      ),
      act: (LocalizationCubit cubit) {
        cubit
          ..addKey(key: 'save', namespace: 'common', defaultValueEn: 'Save Duplicate 1')
          ..addKey(key: 'save', namespace: 'common', defaultValueEn: 'Save Duplicate 2');
      },
      expect: () => <LocalizationState>[
        const LocalizationState(
          keys: <LocalizationKey>[
            LocalizationKey(id: 1, namespace: 'common', key: 'save', defaultValueEn: 'Save'),
            LocalizationKey(id: 2, namespace: 'common', key: 'save', defaultValueEn: 'Save Duplicate 1'),
          ],
          pendingChanges: <String, LocalizationTranslation>{
            '2_en': LocalizationTranslation(keyId: 2, locale: 'en', value: 'Save Duplicate 1'),
          },
          addedKeyIds: <int>{2},
        ),
        const LocalizationState(
          keys: <LocalizationKey>[
            LocalizationKey(id: 1, namespace: 'common', key: 'save', defaultValueEn: 'Save'),
            LocalizationKey(id: 2, namespace: 'common', key: 'save', defaultValueEn: 'Save Duplicate 1'),
            LocalizationKey(id: 3, namespace: 'common', key: 'save', defaultValueEn: 'Save Duplicate 2'),
          ],
          pendingChanges: <String, LocalizationTranslation>{
            '2_en': LocalizationTranslation(keyId: 2, locale: 'en', value: 'Save Duplicate 1'),
            '3_en': LocalizationTranslation(keyId: 3, locale: 'en', value: 'Save Duplicate 2'),
          },
          addedKeyIds: <int>{2, 3},
        ),
      ],
    );

    blocSignalTest<LocalizationCubit, LocalizationState>(
      'updateTranslation overrides pending changes for the same keyId and locale',
      build: () => LocalizationCubit(mockRepository),
      act: (LocalizationCubit cubit) {
        cubit
          ..updateTranslation(const LocalizationTranslation(keyId: 1, locale: 'en', value: 'First Update'))
          ..updateTranslation(const LocalizationTranslation(keyId: 1, locale: 'en', value: 'Second Overwrite'));
      },
      expect: () => <LocalizationState>[
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'First Update'),
          },
        ),
        const LocalizationState(
          pendingChanges: <String, LocalizationTranslation>{
            '1_en': LocalizationTranslation(keyId: 1, locale: 'en', value: 'Second Overwrite'),
          },
        ),
      ],
    );
  });
}
