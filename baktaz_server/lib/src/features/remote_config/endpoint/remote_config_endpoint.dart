import 'package:baktaz_server/src/app/injection/service_locator.dart';
import 'package:baktaz_server/src/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

final class RemoteConfigEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  final IRemoteConfigRepository _repository = getIt<IRemoteConfigRepository>();

  Future<RemoteConfig> getRemoteConfig(
    Session session, {
    required String appVersion,
    required String platform,
    String? userId,
    String? userTier,
    String? customSegment,
  }) async =>
      _repository.getPublicConfig(session);
}
