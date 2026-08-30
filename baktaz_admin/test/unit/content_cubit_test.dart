import 'package:baktaz_admin/features/content/domain/cubit/content_cubit.dart';
import 'package:baktaz_admin/features/content/domain/cubit/content_state.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../fixtures/admin_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  late MockIContentRepository mockRepository;
  late MockFailureHandler mockFailureHandler;

  setUp(() {
    mockRepository = MockIContentRepository();
    mockFailureHandler = MockFailureHandler();
  });

  setUpAll(() {
    provideDummy<TaskResult<List<ContentAsset>>>(
      TaskEither<Failure, List<ContentAsset>>.of(AdminFixtures.contentAssetList),
    );
    provideDummy<TaskResult<ContentAsset>>(TaskEither<Failure, ContentAsset>.of(AdminFixtures.contentAssetBanner));
    provideDummy<TaskResult<Unit>>(TaskEither<Failure, Unit>.of(unit));
  });

  group('ContentCubit', () {
    blocSignalTest<ContentCubit, ContentState>(
      'loadAssets emits loading and done state with assets when successful',
      build: () {
        when(mockRepository.listAssets())
            .thenReturn(TaskEither<Failure, List<ContentAsset>>.of(AdminFixtures.contentAssetList));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) => cubit.loadAssets(),
      expect: () => <ContentState>[
        const ContentState(status: QueryStatus.loading()),
        ContentState(status: const QueryStatus.done(), assets: AdminFixtures.contentAssetList),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'loadAssets handles repository failure',
      build: () {
        when(mockRepository.listAssets())
            .thenReturn(TaskEither<Failure, List<ContentAsset>>.left(const Failure.unexpected('Failed to load')));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) => cubit.loadAssets(),
      expect: () => <ContentState>[const ContentState(status: QueryStatus.loading())],
      verify: (ContentCubit cubit) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'selectAsset updates selectedAssetId',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.selectAsset('asset_1'),
      expect: () => <ContentState>[const ContentState(selectedAssetId: 'asset_1')],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'updateDraft adds valid asset to pendingChanges',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.updateDraft(AdminFixtures.contentAssetBanner),
      expect: () => <ContentState>[
        ContentState(pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner}),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'updateDraft with invalid asset handles failure',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) {
        final ContentAsset invalidAsset = AdminFixtures.contentAssetBanner.copyWith(
          title: ValueString('', fieldName: 'title'),
        );
        cubit.updateDraft(invalidAsset);
      },
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft returns early when no asset selected',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.submitDraft(),
      expect: () => <ContentState>[],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft handles invalid selected asset',
      build: () {
        final ContentAsset invalidAsset = AdminFixtures.contentAssetBanner.copyWith(
          title: ValueString('', fieldName: 'title'),
        );
        when(mockRepository.listAssets())
            .thenReturn(TaskEither<Failure, List<ContentAsset>>.of(<ContentAsset>[invalidAsset]));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        await cubit.loadAssets();
        cubit
          ..selectAsset('asset_1')
          ..submitDraft();
      },
      skip: 3,
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft saves asset when valid and updates state',
      build: () {
        when(mockRepository.saveAsset(any))
            .thenReturn(TaskEither<Failure, ContentAsset>.of(AdminFixtures.contentAssetBanner));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..selectAsset('asset_1')
          ..submitDraft();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 2,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{},
          selectedAssetId: 'asset_1',
          assets: <ContentAsset>[AdminFixtures.contentAssetBanner],
        ),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft handles saveAsset failure',
      build: () {
        when(mockRepository.saveAsset(any))
            .thenReturn(TaskEither<Failure, ContentAsset>.left(const Failure.unexpected('save error')));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..selectAsset('asset_1')
          ..submitDraft();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 2,
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft handles saveAsset raw exception',
      build: () {
        when(mockRepository.saveAsset(any)).thenThrow(Exception('save crash'));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..selectAsset('asset_1')
          ..submitDraft();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 2,
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleException(any, any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'publishChanges returns early when pendingChanges is empty',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.publishChanges(),
      expect: () => <ContentState>[],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'publishChanges handles invalid asset in pendingChanges',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) {
        final ContentAsset invalidAsset = AdminFixtures.contentAssetBanner.copyWith(
          title: ValueString('', fieldName: 'title'),
        );
        cubit
          ..updateDraft(invalidAsset)
          ..publishChanges();
      },
      skip: 1,
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'publishChanges handles publishAssets failure',
      build: () {
        when(mockRepository.publishAssets(any))
            .thenReturn(TaskEither<Failure, Unit>.left(const Failure.unexpected('publish error')));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..publishChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        ContentState(pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner}),
      ],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'publishChanges handles publishAssets raw exception',
      build: () {
        when(mockRepository.publishAssets(any)).thenThrow(Exception('publish crash'));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..publishChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        ContentState(pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner}),
      ],
      verify: (_) {
        verify(mockFailureHandler.handleException(any, any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'scheduleChanges returns early when pendingChanges is empty',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.scheduleChanges(),
      expect: () => <ContentState>[],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'scheduleChanges handles invalid asset in pendingChanges',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) {
        final ContentAsset invalidAsset = AdminFixtures.contentAssetBanner.copyWith(
          title: ValueString('', fieldName: 'title'),
        );
        cubit
          ..updateDraft(invalidAsset)
          ..scheduleChanges();
      },
      skip: 1,
      expect: () => <ContentState>[],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'scheduleChanges handles scheduleAssets failure',
      build: () {
        when(mockRepository.scheduleAssets(any))
            .thenReturn(TaskEither<Failure, Unit>.left(const Failure.unexpected('schedule error')));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..scheduleChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        ContentState(pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner}),
      ],
      verify: (_) {
        verify(mockFailureHandler.handleFailure(any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'scheduleChanges handles scheduleAssets raw exception',
      build: () {
        when(mockRepository.scheduleAssets(any)).thenThrow(Exception('schedule crash'));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..scheduleChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        ContentState(pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner}),
      ],
      verify: (_) {
        verify(mockFailureHandler.handleException(any, any)).called(1);
      },
    );

    blocSignalTest<ContentCubit, ContentState>(
      'discardChanges returns early when selectedAssetId is null',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) => cubit.discardChanges(),
      expect: () => <ContentState>[],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'discardChanges removes selected asset from pendingChanges',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..selectAsset('asset_1')
          ..discardChanges();
      },
      skip: 2,
      expect: () => <ContentState>[const ContentState(selectedAssetId: 'asset_1')],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'submitDraft updates existing asset in stateValue.assets when index >= 0',
      build: () {
        when(mockRepository.saveAsset(any))
            .thenReturn(TaskEither<Failure, ContentAsset>.of(AdminFixtures.contentAssetBanner));
        when(mockRepository.listAssets())
            .thenReturn(TaskEither<Failure, List<ContentAsset>>.of(<ContentAsset>[AdminFixtures.contentAssetBanner]));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        await cubit.loadAssets();
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..selectAsset('asset_1')
          ..submitDraft();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 4,
      expect: () => <ContentState>[
        ContentState(
          status: const QueryStatus.done(),
          assets: <ContentAsset>[AdminFixtures.contentAssetBanner],
          pendingChanges: <String, ContentAsset>{},
          selectedAssetId: 'asset_1',
        ),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'toggleGroup expands and collapses groups',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) {
        cubit
          ..toggleGroup('Home')
          ..toggleGroup('Home');
      },
      expect: () => <ContentState>[
        const ContentState(expandedGroups: <String>{'Home'}),
        const ContentState(),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'setFilter updates filter criteria',
      build: () => ContentCubit(mockRepository, mockFailureHandler),
      act: (ContentCubit cubit) =>
          cubit.setFilter(type: ContentAssetType.banner, placement: ContentPlacementGroup.home, search: 'Summer'),
      expect: () => <ContentState>[
        const ContentState(
          selectedTypeFilter: ContentAssetType.banner,
          selectedPlacementFilter: ContentPlacementGroup.home,
          searchQuery: 'Summer',
        ),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'publishChanges calls repository publishAssets when pendingChanges exist',
      build: () {
        when(mockRepository.publishAssets(any)).thenReturn(TaskEither<Failure, Unit>.of(unit));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..publishChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        const ContentState(),
      ],
    );

    blocSignalTest<ContentCubit, ContentState>(
      'scheduleChanges calls repository scheduleAssets when pendingChanges exist',
      build: () {
        when(mockRepository.scheduleAssets(any)).thenReturn(TaskEither<Failure, Unit>.of(unit));
        return ContentCubit(mockRepository, mockFailureHandler);
      },
      act: (ContentCubit cubit) async {
        cubit
          ..updateDraft(AdminFixtures.contentAssetBanner)
          ..scheduleChanges();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      skip: 1,
      expect: () => <ContentState>[
        ContentState(
          pendingChanges: <String, ContentAsset>{'asset_1': AdminFixtures.contentAssetBanner},
          isPublishing: true,
        ),
        const ContentState(),
      ],
    );
  });
}
