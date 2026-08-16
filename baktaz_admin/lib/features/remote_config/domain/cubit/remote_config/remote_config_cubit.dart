import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/sort_criteria.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_admin/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'remote_config_cubit.freezed.dart';
part 'remote_config_state.dart';

@injectable
class RemoteConfigCubit extends CubitSignal<RemoteConfigState> {
  @factoryMethod
  RemoteConfigCubit(this._repository, this._failureHandler) : super(initialState: RemoteConfigState.initial());

  @visibleForTesting
  RemoteConfigCubit.test(this._repository, this._failureHandler, RemoteConfigState initialState)
    : super(initialState: initialState);

  final IRemoteConfigRepository _repository;
  final FailureHandler _failureHandler;

  Future<void> loadConfig() async {
    await safeRun(
      action: () async {
        final Result<RemoteConfig> result = await _repository.getRemoteConfig().run();
        result.fold(_failureHandler.handleFailure, (RemoteConfig config) {
          safeEmit(stateValue.copyWith(remoteConfig: config, status: const QueryStatus.done()));
        });
      },
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(stateValue.copyWith(status: const QueryStatus.loading()));
        }
      },
    );
  }

  void updateParameter(String key, RemoteConfigValue newValue) {
    final Map<String, RemoteConfigValue> updatedChanges = Map<String, RemoteConfigValue>.of(stateValue.pendingChanges);
    final RemoteConfigValue? originalValue = stateValue.remoteConfig?.parameters[key];
    if (originalValue != null &&
        originalValue.defaultValue.value.getValue() == newValue.defaultValue.value.getValue() &&
        originalValue.description?.getValue() == newValue.description?.getValue()) {
      updatedChanges.remove(key);
    } else {
      updatedChanges[key] = newValue;
    }
    safeEmit(stateValue.copyWith(pendingChanges: updatedChanges));
  }

  void discardChanges() {
    safeEmit(stateValue.copyWith(pendingChanges: const <String, RemoteConfigValue>{}));
  }

  void selectType(ConfigValueType? type) {
    safeEmit(stateValue.copyWith(selectedType: type, currentPage: 1));
  }

  void setPage(int page) {
    safeEmit(stateValue.copyWith(currentPage: page));
  }

  void selectSortCriteria(SortCriteria criteria) {
    safeEmit(stateValue.copyWith(sortCriteria: criteria, currentPage: 1));
  }

  void toggleSortOrder() {
    safeEmit(stateValue.copyWith(isAscending: !stateValue.isAscending, currentPage: 1));
  }

  Future<void> publishChanges() async {
    final RemoteConfig? currentConfig = stateValue.remoteConfig;
    if (currentConfig == null) {
      return;
    }

    await safeRun(
      action: () async {
        final Map<String, RemoteConfigValue> mergedParameters = Map<String, RemoteConfigValue>.of(
          currentConfig.parameters,
        )..addAll(stateValue.pendingChanges);

        final RemoteConfig mergedConfig = currentConfig.copyWith(parameters: mergedParameters);
        final Result<Unit> result = await _repository.publishConfig(mergedConfig).run();

        result.fold(_failureHandler.handleFailure, (Unit _) {
          safeEmit(
            stateValue.copyWith(remoteConfig: mergedConfig, pendingChanges: const <String, RemoteConfigValue>{}),
          );
        });
      },
      onException: _failureHandler.handleException,
    );
  }
}
