// ignore_for_file: prefer_void_public_cubit_methods
import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/data/dto/remote_app_config.dto.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
// ignore: avoid_flutter_imports
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kDebugMode;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';

part 'remote_config_state.dart';
part 'remote_config_cubit.freezed.dart';

@lazySingleton
class RemoteConfigCubit extends CubitSignal<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigService, this._deviceRepository, this._failureHandler)
    : super(initialState: const RemoteConfigState());

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
      onException: (Exception _, StackTrace? _) =>
          safeEmit(RemoteConfigState(values: RemoteAppConfigDTO.fallback().toJson())),
      action: () async {
        final Map<String, dynamic> raw = await _remoteConfigService.remoteConfig;
        safeEmit(RemoteConfigState(values: raw));
      },
    );
  }

  bool get isMaintenance => stateValue.isMaintenance;

  bool get isForceUpdate {
    try {
      return _isForceUpdate(stateValue.minSupportedVersion);
    } on Exception catch (error) {
      _failureHandler.handleFailure(Failure.remoteConfig(error.toString()));

      return false;
    }
  }

  String? get storeLink {
    try {
      if (defaultTargetPlatform case TargetPlatform.android) {
        return stateValue.androidStoreUrl;
      } else if (defaultTargetPlatform case TargetPlatform.iOS) {
        return stateValue.iosStoreUrl;
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
