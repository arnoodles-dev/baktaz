import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

class GMSRemoteConfigService extends IRemoteConfigService {
  GMSRemoteConfigService() : _remoteConfig = FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<StreamSubscription<dynamic>> initializeConfig(void Function(RemoteConfigUpdate)? onData) async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 10),
      ),
    );
    return _remoteConfig.onConfigUpdated.listen(onData);
  }

  @override
  Future<Map<String, String>> get remoteConfig async {
    await _remoteConfig.fetchAndActivate();

    return _remoteConfig.getAll().map(
      (String key, RemoteConfigValue value) => MapEntry<String, String>(key, value.asString()),
    );
  }

  @override
  Future<String?> getString(String key) async {
    final String cachedValue = _remoteConfig.getString(key);
    if (cachedValue.isNotEmpty) {
      return cachedValue;
    }
    await _remoteConfig.fetchAndActivate();
    return _remoteConfig.getString(key).isNotEmpty ? _remoteConfig.getString(key) : null;
  }
}
