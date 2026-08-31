import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

/// Contract for client-side OTA remote localization sync.
abstract interface class IRemoteLocalizationRepository {
  /// Reads cached OTA localization overrides from local storage.
  TaskResult<String?> getCachedOverrides();

  /// Synchronizes remote localization overrides with Serverpod backend.
  /// Returns `true` if new overrides were downloaded and persisted; `false` otherwise.
  TaskResult<bool> syncRemoteLocalization();

  /// Clears cached OTA localization overrides and resets cached version.
  TaskResult<Unit> clearCachedOverrides();
}
