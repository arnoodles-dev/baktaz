import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/content/domain/cubit/content_state.dart';
import 'package:baktaz_admin/features/content/domain/entity/content_asset.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_asset_type.dart';
import 'package:baktaz_admin/features/content/domain/entity/enum/content_placement_group.dart';
import 'package:baktaz_admin/features/content/domain/interface/i_content_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ContentCubit extends CubitSignal<ContentState> {
  ContentCubit(this._repository, this._failureHandler) : super(initialState: const ContentState());

  final IContentRepository _repository;
  final FailureHandler _failureHandler;

  Future<void> loadAssets() async {
    await safeRun(
      action: () async {
        final Result<List<ContentAsset>> result = await _repository.listAssets().run();
        result.fold(
          _failureHandler.handleFailure,
          (List<ContentAsset> assets) =>
              safeEmit(stateValue.copyWith(assets: assets, status: const QueryStatus.done())),
        );
      },
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(stateValue.copyWith(status: const QueryStatus.loading()));
        }
      },
    );
  }

  void selectAsset(String? id) {
    safeEmit(stateValue.copyWith(selectedAssetId: id));
  }

  void updateDraft(ContentAsset updated) {
    final Option<Failure> validation = updated.validate;
    if (validation.isSome()) {
      validation.map(_failureHandler.handleFailure);
      return;
    }

    final Map<String, ContentAsset> newPending = Map<String, ContentAsset>.of(stateValue.pendingChanges)
      ..[updated.id.getValue()] = updated;
    safeEmit(stateValue.copyWith(pendingChanges: newPending));
  }

  void submitDraft() {
    final ContentAsset? selected = stateValue.selectedAsset;
    if (selected == null) return;

    final Option<Failure> validation = selected.validate;
    if (validation.isSome()) {
      validation.map(_failureHandler.handleFailure);
      return;
    }

    unawaited(
      safeRun(
        action: () async {
          final Result<ContentAsset> result = await _repository.saveAsset(selected).run();
          result.fold(_failureHandler.handleFailure, (ContentAsset saved) {
            final List<ContentAsset> newAssets = List<ContentAsset>.of(stateValue.assets);
            final int index = newAssets.indexWhere((ContentAsset a) => a.id == saved.id);
            if (index >= 0) {
              newAssets[index] = saved;
            } else {
              newAssets.add(saved);
            }
            final Map<String, ContentAsset> newPending = Map<String, ContentAsset>.of(stateValue.pendingChanges)
              ..remove(saved.id.getValue());
            safeEmit(stateValue.copyWith(assets: newAssets, pendingChanges: newPending));
          });
        },
        onException: _failureHandler.handleException,
      ),
    );
  }

  void discardChanges() {
    final String? selectedId = stateValue.selectedAssetId;
    if (selectedId == null) return;

    final Map<String, ContentAsset> newPending = Map<String, ContentAsset>.of(stateValue.pendingChanges)
      ..remove(selectedId);
    safeEmit(stateValue.copyWith(pendingChanges: newPending));
  }

  void publishChanges() {
    final Map<String, ContentAsset> pending = stateValue.pendingChanges;
    if (pending.isEmpty) return;

    for (final ContentAsset asset in pending.values) {
      final Option<Failure> validation = asset.validate;
      if (validation.isSome()) {
        validation.map(_failureHandler.handleFailure);
        return;
      }
    }

    safeEmit(stateValue.copyWith(isPublishing: true));

    unawaited(
      safeRun(
        action: () async {
          final List<ContentAsset> assets = pending.values.toList();
          final Result<Unit> result = await _repository.publishAssets(assets).run();
          result.fold(_failureHandler.handleFailure, (Unit _) {
            safeEmit(stateValue.copyWith(pendingChanges: const <String, ContentAsset>{}, isPublishing: false));
          });
        },
        onException: _failureHandler.handleException,
        onLoading: (bool isLoading) {
          safeEmit(stateValue.copyWith(isPublishing: isLoading));
        },
      ),
    );
  }

  void scheduleChanges() {
    final Map<String, ContentAsset> pending = stateValue.pendingChanges;
    if (pending.isEmpty) return;

    for (final ContentAsset asset in pending.values) {
      final Option<Failure> validation = asset.validate;
      if (validation.isSome()) {
        validation.map(_failureHandler.handleFailure);
        return;
      }
    }

    safeEmit(stateValue.copyWith(isPublishing: true));

    unawaited(
      safeRun(
        action: () async {
          final List<ContentAsset> assets = pending.values.toList();
          final Result<Unit> result = await _repository.scheduleAssets(assets).run();
          result.fold(_failureHandler.handleFailure, (Unit _) {
            safeEmit(stateValue.copyWith(pendingChanges: const <String, ContentAsset>{}, isPublishing: false));
          });
        },
        onException: _failureHandler.handleException,
        onLoading: (bool isLoading) {
          safeEmit(stateValue.copyWith(isPublishing: isLoading));
        },
      ),
    );
  }

  void toggleGroup(String group) {
    final Set<String> newExpanded = Set<String>.of(stateValue.expandedGroups);
    if (newExpanded.contains(group)) {
      newExpanded.remove(group);
    } else {
      newExpanded.add(group);
    }
    safeEmit(stateValue.copyWith(expandedGroups: newExpanded));
  }

  void setFilter({ContentAssetType? type, ContentPlacementGroup? placement, String? search}) {
    safeEmit(
      stateValue.copyWith(selectedTypeFilter: type, selectedPlacementFilter: placement, searchQuery: search ?? ''),
    );
  }
}
