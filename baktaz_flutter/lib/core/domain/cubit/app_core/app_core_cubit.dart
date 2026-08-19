import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';

part 'app_core_cubit.freezed.dart';
part 'app_core_state.dart';

@lazySingleton
class AppCoreCubit extends CubitSignal<AppCoreState> {
  AppCoreCubit(this._analyticsService, this._localStorageRepository, this._failureHandler)
    : super(initialState: AppCoreState.initial());

  final IAnalyticsService _analyticsService;
  final ILocalStorageRepository _localStorageRepository;
  final FailureHandler _failureHandler;
  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      action: () async {
        unawaited(_analyticsService.logOnOpenApp());
        unawaited(_preloadSVG());
        await _initializePermissions();
        final Result<bool?> possibleFailure = await _localStorageRepository.getIsOnboardingDone().run();

        possibleFailure.fold(_failureHandler.handleFailure, (bool? isOnboardingDone) {
          safeEmit(stateValue.copyWith(isOnboardingDone: isOnboardingDone ?? false));
        });
      },
    );
  }

  List<String> _getSvgAssets() {
    final List<String> svgPaths = <String>[];

    return svgPaths
      ..addAll(
        _filterSvgAssets(Assets.images.values), // get svgs in images folder
      )
      ..addAll(
        _filterSvgAssets(Assets.icons.values), // get svgs in icons folder
      );
  }

  Future<void> _preloadSVG() async {
    final List<String> assetPaths = _getSvgAssets();
    for (final String path in assetPaths) {
      final SvgAssetLoader loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }
  }

  List<String> _filterSvgAssets(List<dynamic> assetPaths) =>
      assetPaths.whereType<String>().toList().where((String path) => path.contains('.svg')).toList();

  Future<void> setOnboardingDone() async {
    await _localStorageRepository.setIsOnboardingDone().run();
    safeEmit(stateValue.copyWith(isOnboardingDone: true));
  }

  Future<void> _initializePermissions() async {
    // Request tracking authorization before showing Facebook Sign In
    final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();
    if (status == TrackingStatus.denied) {
      return Future<void>.error(Exception('Tracking authorization denied'));
    }
  }
}
