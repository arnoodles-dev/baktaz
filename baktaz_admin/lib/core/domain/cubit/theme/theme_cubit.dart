// ignore_for_file: prefer-bloc-state-suffix, avoid_flutter_imports

import 'dart:async';

import 'package:baktaz_admin/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_admin/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ThemeCubit extends CubitSignal<ThemeMode> {
  ThemeCubit(this._localStorageRepository, this._failureHandler) : super(initialState: ThemeMode.system);

  final ILocalStorageRepository _localStorageRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      action: () async {
        final Result<bool?> possibleFailure = await _localStorageRepository.getIsDarkMode().run();
        possibleFailure.fold(_failureHandler.handleFailure, (bool? isDarkMode) {
          if (isDarkMode != null) {
            safeEmit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
          }
        });
      },
      onException: _failureHandler.handleException,
    );
  }

  Future<void> switchTheme(Brightness currentBrightness) async {
    await safeRun(
      action: () async {
        final bool isDarkMode = currentBrightness != Brightness.dark;
        final Result<Unit> possibleFailure = await _localStorageRepository.setIsDarkMode(isDarkMode: isDarkMode).run();
        possibleFailure.fold(_failureHandler.handleFailure, (_) {
          safeEmit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
          // Change system bar brightness
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: AppColors.transparent, // Only Android
              statusBarBrightness: isDarkMode
                  ? Brightness.dark
                  : Brightness.light, // Only iOS (Note: light and dark are inverted for iOS)
              statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark, // Only Android
              systemStatusBarContrastEnforced: false,
            ),
          );
        });
      },
      onException: _failureHandler.handleException,
    );
  }
}
