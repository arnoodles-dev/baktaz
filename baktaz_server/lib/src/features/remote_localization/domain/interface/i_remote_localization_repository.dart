import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Server-side remote localization repository contract.
abstract interface class IRemoteLocalizationRepository {
  /// Resolves the active remote localization payload.
  /// If client version matches active release, returns updated=false payload.
  Future<RemoteLocalizationResponse> getActiveReleasePayload(
    Session session, {
    required int clientVersion,
  });

  /// Publishes a new immutable release from currently enabled overrides.
  Future<RemoteLocalizationRelease> publishRelease(
    Session session, {
    required String publishedBy,
    String? notes,
  });

  /// Rolls back active release status to a specific previous release version.
  Future<RemoteLocalizationRelease> rollbackToRelease(
    Session session, {
    required int targetVersion,
    required String author,
  });

  /// Seeds default initial release if no active release exists.
  Future<RemoteLocalizationRelease> seedInitialRelease(Session session);
}
