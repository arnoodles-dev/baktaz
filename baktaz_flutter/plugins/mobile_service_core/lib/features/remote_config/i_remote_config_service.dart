import 'dart:async';

abstract class IRemoteConfigService {
  Future<StreamSubscription<dynamic>> initializeConfig(void Function(dynamic)? onData);
  Future<Map<String, dynamic>> get remoteConfig;

  Future<String?> getString(String key);
}
