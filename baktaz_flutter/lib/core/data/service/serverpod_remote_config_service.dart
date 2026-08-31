import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/core/data/dto/remote_app_config.dto.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

@LazySingleton(as: IRemoteConfigService)
class ServerpodRemoteConfigService implements IRemoteConfigService {
  ServerpodRemoteConfigService(this._serverpod, this._deviceInfoRepository);

  final Serverpod _serverpod;
  final IDeviceInfoRepository _deviceInfoRepository;

  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  Map<String, dynamic> _cachedConfig = RemoteAppConfigDTO.fallback().toJson();

  Client get _client => _serverpod.client;

  @override
  Future<StreamSubscription<dynamic>> initializeConfig(void Function(dynamic)? onData) async {
    if (onData != null) {
      return _controller.stream.listen(onData);
    }
    return _controller.stream.listen((_) {});
  }

  @override
  Future<Map<String, dynamic>> get remoteConfig async {
    try {
      final Client client = _client;
      final Result<String> appVersionResult = _deviceInfoRepository.getAppVersion();
      final String appVersion = appVersionResult.fold(
        (_) => '1.0.0',
        (String version) => version,
      );
      final String platform = kIsWeb ? 'web' : defaultTargetPlatform.name.toLowerCase();

      final RemoteConfig result = await client.remoteConfig.getRemoteConfig(
        appVersion: appVersion,
        platform: platform,
      );

      final Map<String, dynamic> map = <String, dynamic>{};
      result.config.forEach((String key, RemoteConfigValue val) {
        switch (val.valueType) {
          case RemoteConfigValueType.boolean:
            map[key] = val.value.toLowerCase() == 'true';
          case RemoteConfigValueType.integer:
            map[key] = int.tryParse(val.value) ?? 0;
          case RemoteConfigValueType.double:
            map[key] = double.tryParse(val.value) ?? 0.0;
          case RemoteConfigValueType.string:
          case RemoteConfigValueType.json:
            map[key] = val.value;
        }
      });

      _cachedConfig = map;
      _controller.add(_cachedConfig);
      return map;
    } on Exception catch (_) {
      return _cachedConfig;
    }
  }

  @override
  Future<String?> getString(String key) async {
    final Map<String, dynamic> map = await remoteConfig;
    return map[key]?.toString();
  }
}
