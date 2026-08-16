// ignore_for_file: avoid_flutter_imports

import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/core/domain/interface/i_asset_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'app_core_cubit.freezed.dart';
part 'app_core_state.dart';

@lazySingleton
class AppCoreCubit extends CubitSignal<AppCoreState> {
  AppCoreCubit(this._failureHandler, this._assetRepository) : super(initialState: AppCoreState.initial());

  final FailureHandler _failureHandler;
  final IAssetRepository _assetRepository;

  Future<void> initialize() async {
    await safeRun(action: _assetRepository.preloadSVGs, onException: _failureHandler.handleException);
  }
}
