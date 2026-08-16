// ignore_for_file: prefer-bloc-state-suffix

import 'package:baktaz_admin/app/generated/localization.g.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppLocalizationCubit extends CubitSignal<I18n> {
  AppLocalizationCubit() : super(initialState: AppLocale.values.first.buildSync());

  Future<void> initialize() async {
    await safeRun(
      action: () async {
        safeEmit(
          await I18nLoader.loadLocalization<AppLocale, I18n>(
            deviceLocale: AppLocaleUtils.findDeviceLocale(),
            languageCode: AppLocaleUtils.findDeviceLocale().languageCode,
            fetchRemote: (String code) async => null,
            fetchLocalFallback: () async => AppLocaleUtils.findDeviceLocale().build(),
            buildWithOverrides: (AppLocale locale, {required bool isFlatMap, required Map<String, dynamic> map}) =>
                AppLocaleUtils.buildWithOverridesFromMap(locale: locale, isFlatMap: isFlatMap, map: map),
          ),
        );
      },
      onException: (Exception _, StackTrace? _) => safeEmit(AppLocale.values.first.buildSync()),
    );
  }
}
