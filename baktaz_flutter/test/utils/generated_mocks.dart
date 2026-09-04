// ignore_for_file: prefer-match-file-name, prefer-bloc-state-suffix, depend_on_referenced_packages, unused_import, directives_ordering

import 'dart:async';

import 'package:baktaz_client/baktaz_client.dart';
import 'package:baktaz_flutter/app/config/serverpod_config.dart';
import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_flutter/core/domain/interface/i_local_storage_repository.dart';
import 'package:baktaz_flutter/core/domain/interface/i_remote_localization_repository.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/interface/i_auth_repository.dart';
import 'package:baktaz_flutter/features/challenge/domain/interface/i_challenge_repository.dart';
import 'package:baktaz_flutter/features/home/data/service/sync_steps_service.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_flutter/features/home/domain/interface/i_steps_repository.dart';
import 'package:baktaz_flutter/features/steps/domain/interface/i_steps_analytics_repository.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_service_core/features/analytics/i_analytics_service.dart';
import 'package:mobile_service_core/features/crashlytics/i_crashlytics_service.dart';
import 'package:mobile_service_core/features/remote_config/i_remote_config_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

export 'generated_mocks.mocks.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[
  MockSpec<Client>(),
  MockSpec<EndpointAccount>(),
  MockSpec<EndpointProfile>(),
  MockSpec<EndpointAuth>(),
  MockSpec<EndpointOtp>(),
  MockSpec<EndpointRemoteConfig>(),
  MockSpec<EndpointRemoteLocalization>(),
  MockSpec<EndpointHome>(),
  MockSpec<EndpointStep>(),
  MockSpec<IStepsAnalyticsRepository>(),
  MockSpec<IAuthRepository>(),
  MockSpec<IAccountRepository>(),
  MockSpec<ILocalStorageRepository>(),
  MockSpec<IRemoteLocalizationRepository>(),
  MockSpec<ICrashlyticsService>(),
  MockSpec<IRemoteConfigService>(),
  MockSpec<IAnalyticsService>(),
  MockSpec<SharedPreferences>(),
  MockSpec<FlutterSecureStorage>(),
  MockSpec<Serverpod>(),
  MockSpec<FlutterAuthSessionManager>(),
  MockSpec<FailureHandler>(),
  MockSpec<Talker>(),
  MockSpec<PackageInfo>(),
  MockSpec<GoRouter>(),
  MockSpec<AuthCubit>(),
  MockSpec<IDeviceInfoRepository>(),
  MockSpec<DeviceInfoPlugin>(),
  MockSpec<StreamSubscription<dynamic>>(),
  MockSpec<StatefulNavigationShell>(),
  MockSpec<IStepsRepository>(),
  MockSpec<IChallengeRepository>(),
  MockSpec<SyncStepsService>(),
  MockSpec<HomeCubit>(),
  MockSpec<HidableCubit>(),
])
void main() {}

class MockAppLocalizationCubit extends Mock implements AppLocalizationCubit {
  @override
  I18n get stateValue {
    final I18n fallback = AppLocale.values.first.buildSync();
    return super.noSuchMethod(
      Invocation.getter(#stateValue),
      returnValue: fallback,
      returnValueForMissingStub: fallback,
    ) as I18n;
  }

  @override
  Future<void> close() async => super.noSuchMethod(
    Invocation.method(#close, <Object?>[]),
    returnValue: Future<void>.value(),
    returnValueForMissingStub: Future<void>.value(),
  ) as Future<void>;
}
