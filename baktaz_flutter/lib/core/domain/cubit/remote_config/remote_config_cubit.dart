// ignore_for_file: prefer_void_public_cubit_methods
import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/data/dto/remote_app_config.dto.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
// ignore: avoid_flutter_imports
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kDebugMode;
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

@lazySingleton
class RemoteConfigCubit extends CubitSignal<Map<String, dynamic>> {
  RemoteConfigCubit(this._remoteConfigService, this._deviceRepository, this._failureHandler)
    : super(initialState: <String, dynamic>{});

  final IRemoteConfigService _remoteConfigService;
  final IDeviceInfoRepository _deviceRepository;
  final FailureHandler _failureHandler;
  late StreamSubscription<dynamic> _remoteConfigSubscription;

  Future<void> initialize() async {
    await remoteConfig;
    _remoteConfigSubscription = await _remoteConfigService.initializeConfig((_) => remoteConfig);
  }

  // Fetch Remote Config values
  Future<void> get remoteConfig async {
    await safeRun(
      onException: (Exception _, StackTrace? _) => safeEmit(RemoteAppConfigDTO.fallback().toJson()),
      action: () async {
        safeEmit(await _remoteConfigService.remoteConfig);
      },
    );
  }

  bool get isMaintenance {
    try {
      final String? configValue = stateValue['is_maintenance'] as String?;

      return configValue?.toBoolean ?? false;
    } on Exception catch (error) {
      _failureHandler.handleFailure(Failure.remoteConfig(error.toString()));

      return false;
    }
  }

  bool get isForceUpdate {
    try {
      final String? configValue = stateValue['min_supported_version'] as String?;

      return _isForceUpdate(configValue);
    } on Exception catch (error) {
      _failureHandler.handleFailure(Failure.remoteConfig(error.toString()));

      return false;
    }
  }

  String? get storeLink {
    try {
      if (defaultTargetPlatform case TargetPlatform.android) {
        return stateValue['android_store_url'] as String?;
      } else if (defaultTargetPlatform case TargetPlatform.iOS) {
        return stateValue['ios_store_url'] as String?;
      } else {
        return null;
      }
    } on Object catch (error) {
      //No need to redirect in splash screen
      if (kDebugMode) {
        _failureHandler.handleFailure(Failure.remoteConfig(error.toString()));
      }
      return null;
    }
  }

  bool _isForceUpdate(String? minSupportedVersion) => _deviceRepository.getAppVersion().fold(
    (Failure failure) {
      _failureHandler.handleFailure(failure);

      return false;
    },
    (String value) {
      final int appVersion = int.tryParse(value.replaceAll('.', '')) ?? 1;
      if (minSupportedVersion != null) {
        final int minimumVersion = int.tryParse(minSupportedVersion.replaceAll('.', '')) ?? 1;

        return appVersion < minimumVersion;
      } else {
        return appVersion < 1;
      }
    },
  );

  @override
  Future<void> close() {
    _remoteConfigSubscription.cancel();

    return super.close();
  }
}
