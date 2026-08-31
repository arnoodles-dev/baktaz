import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_localization/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class RemoteLocalizationEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  final IRemoteLocalizationRepository _remoteLocalizationRepository =
      getIt<IRemoteLocalizationRepository>();

  /// Returns active remote localization payload.
  Future<RemoteLocalizationResponse> get(
    Session session,
    int clientVersion,
  ) async => _remoteLocalizationRepository.getActiveReleasePayload(
        session,
        clientVersion: clientVersion,
      );
}
