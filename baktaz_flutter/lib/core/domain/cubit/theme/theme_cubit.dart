// ignore_for_file: prefer-bloc-state-suffix,prefer_void_public_cubit_methods,avoid_flutter_imports

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeCubit extends CubitSignal<ThemeMode> {
  ThemeCubit(this._localStorageRepository, this._failureHandler) : super(initialState: ThemeMode.system);

  final ILocalStorageRepository _localStorageRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Result<bool?> possibleFailure = await _localStorageRepository.getIsDarkMode().run();
        possibleFailure.fold(_failureHandler.handleFailure, (bool? isDarkMode) {
          if (isDarkMode != null) {
            safeEmit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
          }
        });
      },
    );
  }

  Future<void> switchTheme(Brightness currentBrightness) async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final bool isDarkMode = currentBrightness != Brightness.dark;
        final Result<Unit> possibleFailure = await _localStorageRepository.setIsDarkMode(isDarkMode: isDarkMode).run();
        possibleFailure.fold(_failureHandler.handleFailure, (_) {
          safeEmit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
        });
      },
    );
  }

  bool get isDarkMode => stateValue == ThemeMode.dark;
}
