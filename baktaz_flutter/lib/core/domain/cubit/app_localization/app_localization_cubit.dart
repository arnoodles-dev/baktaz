// ignore_for_file: prefer-bloc-state-suffix

import 'dart:async';

import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/app/utils/slang_override_helper.dart';
import 'package:baktaz_flutter/core/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppLocalizationCubit extends CubitSignal<I18n> {
  AppLocalizationCubit(this._remoteLocRepository, this._failureHandler)
    : super(initialState: AppLocale.values.first.buildSync()) {
    unawaited(initialize());
  }

  final IRemoteLocalizationRepository _remoteLocRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await _loadCachedOverrides();
    _syncInBackground();
  }

  Future<void> _loadCachedOverrides() async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Result<String?> result = await _remoteLocRepository.getCachedOverrides().run();
        result.fold(_failureHandler.handleFailure, (String? overridesJson) {
          if (overridesJson != null) {
            safeEmit(SlangOverrideHelper.applyOverridesJson(jsonContent: overridesJson));
          }
        });
      },
    );
  }

  void _syncInBackground() {
    safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        final Result<bool> result = await _remoteLocRepository.syncRemoteLocalization().run();
        result.fold(_failureHandler.handleFailure, (bool hasNewOverrides) {
          if (hasNewOverrides) {
            unawaited(_loadCachedOverrides());
          }
        });
      },
    );
  }
}
