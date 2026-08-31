import 'dart:convert';

import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:slang/overrides.dart';

/// Utility for parsing and applying Slang localization overrides dynamically.
abstract final class SlangOverrideHelper {
  /// Safely parses a JSON string containing key-value translation overrides.
  /// Returns an empty map if parsing fails or input is null/empty.
  static Map<String, dynamic> parseOverridesJson(String? jsonContent) {
    if (jsonContent == null || jsonContent.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final dynamic decoded = json.decode(jsonContent);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } on Exception catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Builds an [I18n] instance with translation overrides applied from a JSON string.
  /// Falls back to default locale translations if overrides are invalid or empty.
  static I18n applyOverridesJson({
    required String? jsonContent,
    AppLocale? locale,
  }) {
    final AppLocale targetLocale = locale ?? AppLocaleUtils.findDeviceLocale();
    if (jsonContent == null || jsonContent.trim().isEmpty) {
      return targetLocale.buildSync();
    }
    try {
      return AppLocaleUtils.buildWithOverridesSync(
        locale: targetLocale,
        fileType: FileType.json,
        content: jsonContent,
      );
    } on Exception catch (_) {
      return targetLocale.buildSync();
    }
  }

  /// Builds an [I18n] instance with translation overrides applied from a map.
  /// [isFlatMap] indicates if keys are dot-notated strings (e.g., `'auth.login'`).
  static I18n applyOverridesMap({
    required Map<String, dynamic> map,
    AppLocale? locale,
    bool isFlatMap = true,
  }) {
    final AppLocale targetLocale = locale ?? AppLocaleUtils.findDeviceLocale();
    if (map.isEmpty) {
      return targetLocale.buildSync();
    }
    try {
      return AppLocaleUtils.buildWithOverridesFromMapSync(
        locale: targetLocale,
        isFlatMap: isFlatMap,
        map: map,
      );
    } on Exception catch (_) {
      return targetLocale.buildSync();
    }
  }
}
