import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_flutter/core/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IRemoteLocalizationRepository)
final class RemoteLocalizationRepository implements IRemoteLocalizationRepository {
  const RemoteLocalizationRepository(
    this._client,
    this._localStorageRepository,
    this._failureHandler,
  );

  final Client _client;
  final ILocalStorageRepository _localStorageRepository;
  final FailureHandler _failureHandler;

  @override
  TaskResult<String?> getCachedOverrides() => _localStorageRepository.getOtaLocalizationOverrides();

  @override
  TaskResult<bool> syncRemoteLocalization() => TaskResult<bool>.tryCatch(
    () async {
      final Either<Failure, int?> currentVersionResult =
          await _localStorageRepository.getOtaLocalizationVersion().run();
      final int currentVersion = currentVersionResult.fold((_) => 0, (int? v) => v ?? 0);

      final RemoteLocalizationResponse response = await _client.remoteLocalization.get(currentVersion);

      if (response.updated && response.overridesJson != null) {
        await _localStorageRepository.setOtaLocalizationVersion(response.version).run();
        await _localStorageRepository.setOtaLocalizationOverrides(response.overridesJson!).run();
        return true;
      }

      return false;
    },
    (Object error, StackTrace stackTrace) {
      _failureHandler.handleException(
        error is Exception ? error : Exception(error.toString()),
        stackTrace,
      );
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );

  @override
  TaskResult<Unit> clearCachedOverrides() => TaskResult<Unit>.tryCatch(
    () async {
      await _localStorageRepository.setOtaLocalizationVersion(0).run();
      await _localStorageRepository.setOtaLocalizationOverrides('').run();
      return unit;
    },
    (Object error, StackTrace stackTrace) {
      _failureHandler.handleException(
        error is Exception ? error : Exception(error.toString()),
        stackTrace,
      );
      return Failure.server(StatusCode.serverpod, error.toString());
    },
  );
}
