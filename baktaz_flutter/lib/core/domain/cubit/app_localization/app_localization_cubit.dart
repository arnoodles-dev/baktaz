// ignore_for_file: prefer-bloc-state-suffix

import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

@lazySingleton
class AppLocalizationCubit extends Cubit<I18n> {
  AppLocalizationCubit(this._remoteConfigService, this._failureHandler) : super(AppLocale.values.first.buildSync()) {
    initialize();
  }

  final IRemoteConfigService _remoteConfigService;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    final AppLocale appLocale = AppLocaleUtils.findDeviceLocale();

    await safeRun(
      onException: (Exception error, StackTrace? stackTrace) async {
        _failureHandler.handleException(error, stackTrace);
        safeEmit(await AppLocaleUtils.findDeviceLocale().build());
      },
      action: () async {
        safeEmit(
          await I18nLoader.loadLocalization<AppLocale, I18n>(
            deviceLocale: appLocale,
            languageCode: appLocale.languageCode,
            fetchRemote: _remoteConfigService.getString,
            fetchLocalFallback: () async => AppLocaleUtils.findDeviceLocale().build(),
            buildWithOverrides: (AppLocale locale, {required bool isFlatMap, required Map<String, dynamic> map}) =>
                AppLocaleUtils.buildWithOverridesFromMap(locale: locale, isFlatMap: isFlatMap, map: map),
          ),
        );
      },
    );
  }
}
