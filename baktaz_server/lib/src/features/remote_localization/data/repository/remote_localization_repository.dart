import 'dart:convert';

import 'package:baktaz_server/src/features/remote_localization/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod/serverpod.dart';

@LazySingleton(as: IRemoteLocalizationRepository)
final class RemoteLocalizationRepository implements IRemoteLocalizationRepository {
  static const String _activeReleaseCacheKey = 'remote_loc:active_release';

  @override
  Future<RemoteLocalizationResponse> getActiveReleasePayload(
    Session session, {
    required int clientVersion,
  }) async {
    final RemoteLocalizationRelease? activeRelease = await _getActiveRelease(session);

    if (activeRelease == null) {
      return RemoteLocalizationResponse(version: 0, updated: false);
    }

    if (clientVersion == activeRelease.version) {
      return RemoteLocalizationResponse(
        version: activeRelease.version,
        updated: false,
        checksum: activeRelease.checksum,
      );
    }

    return RemoteLocalizationResponse(
      version: activeRelease.version,
      updated: true,
      checksum: activeRelease.checksum,
      overridesJson: activeRelease.payloadJson,
    );
  }

  @override
  Future<RemoteLocalizationRelease> publishRelease(
    Session session, {
    required String publishedBy,
    String? notes,
  }) async {
    final RemoteLocalizationRelease inserted =
        await session.db.transaction<RemoteLocalizationRelease>((Transaction transaction) async {
      final RemoteLocalizationRelease? latestRelease =
          await RemoteLocalizationRelease.db.findFirstRow(
        session,
        orderBy: (RemoteLocalizationReleaseTable t) => t.version.desc(),
        transaction: transaction,
      );

      final int nextVersion = (latestRelease?.version ?? 0) + 1;

      // Deactivate previous active releases
      final List<RemoteLocalizationRelease> activeReleases =
          await RemoteLocalizationRelease.db.find(
        session,
        where: (RemoteLocalizationReleaseTable t) => t.active.equals(true),
        transaction: transaction,
      );
      for (final RemoteLocalizationRelease rel in activeReleases) {
        await RemoteLocalizationRelease.db.updateRow(
          session,
          rel.copyWith(active: false),
          transaction: transaction,
        );
      }

      final RemoteLocalizationRelease newRelease = RemoteLocalizationRelease(
        version: nextVersion,
        publishedBy: publishedBy,
        publishedAt: DateTime.now().toUtc(),
        active: true,
        notes: notes,
        payloadJson: latestRelease?.payloadJson ?? '{}',
        checksum: _computeChecksum(latestRelease?.payloadJson ?? '{}'),
      );

      final RemoteLocalizationRelease insertedRow =
          await RemoteLocalizationRelease.db.insertRow(
        session,
        newRelease,
        transaction: transaction,
      );

      await RemoteLocalizationAuditLog.db.insertRow(
        session,
        RemoteLocalizationAuditLog(
          timestamp: DateTime.now().toUtc(),
          author: publishedBy,
          action: 'PUBLISH_RELEASE',
          details: 'Published release version $nextVersion',
          newValue: insertedRow.payloadJson,
        ),
        transaction: transaction,
      );

      return insertedRow;
    });

    await _updateCache(session, inserted);
    return inserted;
  }

  @override
  Future<RemoteLocalizationRelease> rollbackToRelease(
    Session session, {
    required int targetVersion,
    required String author,
  }) async {
    final RemoteLocalizationRelease updatedTarget =
        await session.db.transaction<RemoteLocalizationRelease>((Transaction transaction) async {
      final RemoteLocalizationRelease? targetRelease =
          await RemoteLocalizationRelease.db.findFirstRow(
        session,
        where: (RemoteLocalizationReleaseTable t) => t.version.equals(targetVersion),
        transaction: transaction,
      );

      if (targetRelease == null) {
        throw ApiException(
          message: 'Target release version $targetVersion not found',
          code: ApiExceptionCode.notFound,
        );
      }

      final List<RemoteLocalizationRelease> activeReleases =
          await RemoteLocalizationRelease.db.find(
        session,
        where: (RemoteLocalizationReleaseTable t) => t.active.equals(true),
        transaction: transaction,
      );
      for (final RemoteLocalizationRelease rel in activeReleases) {
        await RemoteLocalizationRelease.db.updateRow(
          session,
          rel.copyWith(active: false),
          transaction: transaction,
        );
      }

      final RemoteLocalizationRelease updatedRow =
          await RemoteLocalizationRelease.db.updateRow(
        session,
        targetRelease.copyWith(active: true),
        transaction: transaction,
      );

      await RemoteLocalizationAuditLog.db.insertRow(
        session,
        RemoteLocalizationAuditLog(
          timestamp: DateTime.now().toUtc(),
          author: author,
          action: 'ROLLBACK',
          details: 'Rolled back active release to version $targetVersion',
          newValue: targetRelease.payloadJson,
        ),
        transaction: transaction,
      );

      return updatedRow;
    });

    await _updateCache(session, updatedTarget);
    return updatedTarget;
  }

  @override
  Future<RemoteLocalizationRelease> seedInitialRelease(Session session) async {
    final int count = await RemoteLocalizationRelease.db.count(session);
    if (count > 0) {
      final RemoteLocalizationRelease? active = await _getActiveRelease(session);
      if (active != null) {
        return active;
      }
      final RemoteLocalizationRelease? latest = await RemoteLocalizationRelease.db.findFirstRow(
        session,
        orderBy: (RemoteLocalizationReleaseTable t) => t.version.desc(),
      );
      if (latest != null) {
        return latest;
      }
    }

    const String defaultPayload =
        '{"common.error.generic":"Something went wrong. Please try again.","auth.loginButton":"Sign In"}';
    final String checksum = _computeChecksum(defaultPayload);

    final RemoteLocalizationRelease release = RemoteLocalizationRelease(
      version: 1,
      publishedBy: 'system_seed',
      publishedAt: DateTime.now().toUtc(),
      active: true,
      notes: 'Initial seeded remote localization release',
      payloadJson: defaultPayload,
      checksum: checksum,
    );

    final RemoteLocalizationRelease inserted = await RemoteLocalizationRelease.db.insertRow(session, release);
    await _updateCache(session, inserted);
    return inserted;
  }

  Future<RemoteLocalizationRelease?> _getActiveRelease(Session session) async {
    final RemoteLocalizationRelease? cached =
        await session.caches.local.get<RemoteLocalizationRelease>(_activeReleaseCacheKey);
    if (cached != null) {
      return cached;
    }

    final RemoteLocalizationRelease? activeFromDb = await RemoteLocalizationRelease.db.findFirstRow(
      session,
      where: (RemoteLocalizationReleaseTable t) => t.active.equals(true),
    );

    if (activeFromDb != null) {
      await session.caches.local.put(
        _activeReleaseCacheKey,
        activeFromDb,
        lifetime: const Duration(minutes: 10),
      );
    }

    return activeFromDb;
  }

  Future<void> _updateCache(Session session, RemoteLocalizationRelease release) async {
    await session.caches.local.put(
      _activeReleaseCacheKey,
      release,
      lifetime: const Duration(minutes: 10),
    );
  }

  String _computeChecksum(String payload) {
    final String digest = sha256.convert(utf8.encode(payload)).toString();
    return 'sha256:$digest';
  }
}
