import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';

/// Interface for accessing remote configuration data.
abstract interface class IRemoteConfigRepository {
  /// Fetches the current remote configuration.
  TaskResult<RemoteConfig> getRemoteConfig();

  /// Publishes the updated remote configuration.
  TaskResult<Unit> publishConfig(RemoteConfig config);
}
