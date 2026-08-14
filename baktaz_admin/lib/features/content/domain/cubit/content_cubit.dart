import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/content/domain/cubit/content_state.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/interface/i_content_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ContentCubit extends Cubit<ContentState> with BlocPresentationMixin<ContentState, ContentPresentationEvent> {
  ContentCubit(this._repository, this._failureHandler) : super(const ContentState());

  final IContentRepository _repository;
  final FailureHandler _failureHandler;

  Future<void> loadAssets() async {
    await safeRun(
      action: () async {
        final Result<List<ContentAsset>> result = await _repository.listAssets().run();
        result.fold(
          _failureHandler.handleFailure,
          (List<ContentAsset> assets) => safeEmit(state.copyWith(assets: assets, status: const QueryStatus.done())),
        );
      },
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(state.copyWith(status: const QueryStatus.loading()));
        }
      },
    );
  }

  void selectAsset(String? id) {
    safeEmit(state.copyWith(selectedAssetId: id));
  }

  void updateDraft(ContentAsset asset) {
    final String key = asset.id.getValue();
    final Map<String, ContentAsset> newPending = Map<String, ContentAsset>.of(state.pendingChanges);
    newPending[key] = asset;
    safeEmit(state.copyWith(pendingChanges: newPending));
  }

  void submitDraft() {
    final String? selectedId = state.selectedAssetId;
    if (selectedId == null) return;

    final ContentAsset? asset = state.pendingChanges[selectedId];
    if (asset == null) return;

    final Option<Failure> validation = asset.validate;
    if (validation.isSome()) {
      validation.map(_failureHandler.handleFailure);
      return;
    }

    safeEmit(state.copyWith(isPublishing: true));
    safeEmitPresentation(const ContentPresentationEvent.showLoader());

    unawaited(
      safeRun(
        action: () async {
          final Result<ContentAsset> result = await _repository.saveAsset(asset).run();
          result.fold(_failureHandler.handleFailure, (ContentAsset saved) {
            safeEmit(
              state.copyWith(
                pendingChanges: Map<String, ContentAsset>.of(state.pendingChanges)..remove(selectedId),
                isPublishing: false,
              ),
            );
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
            safeEmitPresentation(const ContentPresentationEvent.onPublishSuccess());
          });
        },
        onException: _failureHandler.handleException,
        onLoading: (bool isLoading) {
          safeEmit(state.copyWith(isPublishing: isLoading));
          if (!isLoading) {
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
          }
        },
      ),
    );
  }

  void discardChanges() {
    final String? selectedId = state.selectedAssetId;
    if (selectedId == null) return;

    final Map<String, ContentAsset> newPending = Map<String, ContentAsset>.of(state.pendingChanges)..remove(selectedId);
    safeEmit(state.copyWith(pendingChanges: newPending));
  }

  void publishChanges() {
    final Map<String, ContentAsset> pending = state.pendingChanges;
    if (pending.isEmpty) return;

    for (final ContentAsset asset in pending.values) {
      final Option<Failure> validation = asset.validate;
      if (validation.isSome()) {
        validation.map(_failureHandler.handleFailure);
        return;
      }
    }

    safeEmit(state.copyWith(isPublishing: true));
    safeEmitPresentation(const ContentPresentationEvent.showLoader());

    unawaited(
      safeRun(
        action: () async {
          final List<ContentAsset> assets = pending.values.toList();
          final Result<Unit> result = await _repository.publishAssets(assets).run();
          result.fold(_failureHandler.handleFailure, (Unit _) {
            safeEmit(state.copyWith(pendingChanges: const <String, ContentAsset>{}, isPublishing: false));
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
            safeEmitPresentation(const ContentPresentationEvent.onPublishSuccess());
          });
        },
        onException: _failureHandler.handleException,
        onLoading: (bool isLoading) {
          safeEmit(state.copyWith(isPublishing: isLoading));
          if (!isLoading) {
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
          }
        },
      ),
    );
  }

  void scheduleChanges() {
    final Map<String, ContentAsset> pending = state.pendingChanges;
    if (pending.isEmpty) return;

    for (final ContentAsset asset in pending.values) {
      final Option<Failure> validation = asset.validate;
      if (validation.isSome()) {
        validation.map(_failureHandler.handleFailure);
        return;
      }
    }

    safeEmit(state.copyWith(isPublishing: true));
    safeEmitPresentation(const ContentPresentationEvent.showLoader());

    unawaited(
      safeRun(
        action: () async {
          final List<ContentAsset> assets = pending.values.toList();
          final Result<Unit> result = await _repository.scheduleAssets(assets).run();
          result.fold(_failureHandler.handleFailure, (Unit _) {
            safeEmit(state.copyWith(pendingChanges: const <String, ContentAsset>{}, isPublishing: false));
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
            safeEmitPresentation(const ContentPresentationEvent.onScheduleSuccess());
          });
        },
        onException: _failureHandler.handleException,
        onLoading: (bool isLoading) {
          safeEmit(state.copyWith(isPublishing: isLoading));
          if (!isLoading) {
            safeEmitPresentation(const ContentPresentationEvent.hideLoader());
          }
        },
      ),
    );
  }

  void toggleGroup(String group) {
    final Set<String> newExpanded = Set<String>.of(state.expandedGroups);
    if (newExpanded.contains(group)) {
      newExpanded.remove(group);
    } else {
      newExpanded.add(group);
    }
    safeEmit(state.copyWith(expandedGroups: newExpanded));
  }

  void setFilter({ContentAssetType? type, ContentPlacementGroup? placement, String? search}) {
    safeEmit(state.copyWith(selectedTypeFilter: type, selectedPlacementFilter: placement, searchQuery: search ?? ''));
  }
}
