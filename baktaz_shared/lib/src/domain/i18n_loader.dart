// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:convert';

/// A function type that loads raw locale data mapping.
typedef RemoteConfigResolver = Future<String?> Function(String languageCode);
typedef LocalConfigResolver<T> = Future<T> Function();

abstract class I18nLoader {
  const I18nLoader._();

  static Future<T> loadLocalization<L, T>({
    required L deviceLocale,
    required String languageCode,
    required RemoteConfigResolver fetchRemote,
    required LocalConfigResolver<T> fetchLocalFallback,
    required Future<T> Function(L locale, {required bool isFlatMap, required Map<String, dynamic> map})
    buildWithOverrides,
  }) async {
    try {
      final String? remoteStr = await fetchRemote(languageCode);
      if (remoteStr != null) {
        final Map<String, dynamic>? remoteMap = json.decode(remoteStr) as Map<String, dynamic>?;
        if (remoteMap != null) {
          return await buildWithOverrides(deviceLocale, isFlatMap: true, map: remoteMap);
        }
      }
    } catch (_) {
      // Fall through to local fallback on any failure
    }

    return fetchLocalFallback();
  }
}
