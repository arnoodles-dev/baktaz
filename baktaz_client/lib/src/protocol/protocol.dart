/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, no_leading_underscores_for_library_prefixes
// ignore_for_file: unnecessary_type_check

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'core/domain/model/enum/gender.dart' as _i2;
import 'core/domain/model/enum/transaction_type.dart' as _i3;
import 'core/domain/model/exception/api_exception.dart' as _i4;
import 'core/domain/model/exception/api_exception_code.dart' as _i5;
import 'features/account/domain/model/account.dart' as _i6;
import 'features/account/domain/model/account_state.dart' as _i7;
import 'features/account/domain/model/account_summary.dart' as _i8;
import 'features/account/domain/model/address.dart' as _i9;
import 'features/account/domain/model/contact.dart' as _i10;
import 'features/account/domain/model/profile.dart' as _i11;
import 'features/account/domain/model/rank.dart' as _i12;
import 'features/account/domain/model/user_info.dart' as _i13;
import 'features/auth/domain/models/otp_exception.dart' as _i14;
import 'features/auth/domain/models/otp_verification_result.dart' as _i15;
import 'features/auth/domain/models/registration_form.dart' as _i16;
import 'features/home/domain/model/active_challenge_summary.dart' as _i17;
import 'features/home/domain/model/daily_step_telemetry.dart' as _i18;
import 'features/home/domain/model/home_leaderboard_entry.dart' as _i19;
import 'features/home/domain/model/weekly_step_analytics.dart' as _i20;
import 'features/remote_config/domain/model/config_key.dart' as _i21;
import 'features/remote_config/domain/model/config_snapshot_version.dart'
    as _i22;
import 'features/remote_config/domain/model/public_config_version.dart' as _i23;
import 'features/remote_config/domain/model/remote_config.dart' as _i24;
import 'features/remote_config/domain/model/remote_config_default_value.dart'
    as _i25;
import 'features/remote_config/domain/model/remote_config_value.dart' as _i26;
import 'features/remote_config/domain/model/remote_config_value_type.dart'
    as _i27;
import 'features/remote_config/domain/model/targeting_override.dart' as _i28;
import 'features/remote_localization/domain/model/remote_localization_audit_log.dart'
    as _i29;
import 'features/remote_localization/domain/model/remote_localization_release.dart'
    as _i30;
import 'features/remote_localization/domain/model/remote_localization_response.dart'
    as _i31;
import 'features/security/domain/models/security_event.dart' as _i32;
import 'features/steps/domain/model/step_integration.dart' as _i33;
import 'features/steps/domain/model/step_sync.dart' as _i34;
import 'features/steps/domain/model/user_device.dart' as _i35;
import 'features/wallet/domain/model/wallet.dart' as _i36;
import 'features/wallet/domain/model/wallet_transactions.dart' as _i37;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i38;
import 'package:baktaz_client/src/protocol/features/home/domain/model/home_leaderboard_entry.dart'
    as _i39;
import 'package:baktaz_client/src/protocol/features/security/domain/models/security_event.dart'
    as _i40;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i41;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i42;
export 'core/domain/model/enum/gender.dart';
export 'core/domain/model/enum/transaction_type.dart';
export 'core/domain/model/exception/api_exception.dart';
export 'core/domain/model/exception/api_exception_code.dart';
export 'features/account/domain/model/account.dart';
export 'features/account/domain/model/account_state.dart';
export 'features/account/domain/model/account_summary.dart';
export 'features/account/domain/model/address.dart';
export 'features/account/domain/model/contact.dart';
export 'features/account/domain/model/profile.dart';
export 'features/account/domain/model/rank.dart';
export 'features/account/domain/model/user_info.dart';
export 'features/auth/domain/models/otp_exception.dart';
export 'features/auth/domain/models/otp_verification_result.dart';
export 'features/auth/domain/models/registration_form.dart';
export 'features/home/domain/model/active_challenge_summary.dart';
export 'features/home/domain/model/daily_step_telemetry.dart';
export 'features/home/domain/model/home_leaderboard_entry.dart';
export 'features/home/domain/model/weekly_step_analytics.dart';
export 'features/remote_config/domain/model/config_key.dart';
export 'features/remote_config/domain/model/config_snapshot_version.dart';
export 'features/remote_config/domain/model/public_config_version.dart';
export 'features/remote_config/domain/model/remote_config.dart';
export 'features/remote_config/domain/model/remote_config_default_value.dart';
export 'features/remote_config/domain/model/remote_config_value.dart';
export 'features/remote_config/domain/model/remote_config_value_type.dart';
export 'features/remote_config/domain/model/targeting_override.dart';
export 'features/remote_localization/domain/model/remote_localization_audit_log.dart';
export 'features/remote_localization/domain/model/remote_localization_release.dart';
export 'features/remote_localization/domain/model/remote_localization_response.dart';
export 'features/security/domain/models/security_event.dart';
export 'features/steps/domain/model/step_integration.dart';
export 'features/steps/domain/model/step_sync.dart';
export 'features/steps/domain/model/user_device.dart';
export 'features/wallet/domain/model/wallet.dart';
export 'features/wallet/domain/model/wallet_transactions.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Gender) {
      return _i2.Gender.fromJson(data) as T;
    }
    if (t == _i3.TransactionType) {
      return _i3.TransactionType.fromJson(data) as T;
    }
    if (t == _i4.ApiException) {
      return _i4.ApiException.fromJson(data) as T;
    }
    if (t == _i5.ApiExceptionCode) {
      return _i5.ApiExceptionCode.fromJson(data) as T;
    }
    if (t == _i6.Account) {
      return _i6.Account.fromJson(data) as T;
    }
    if (t == _i7.AccountState) {
      return _i7.AccountState.fromJson(data) as T;
    }
    if (t == _i8.AccountSummary) {
      return _i8.AccountSummary.fromJson(data) as T;
    }
    if (t == _i9.Address) {
      return _i9.Address.fromJson(data) as T;
    }
    if (t == _i10.Contact) {
      return _i10.Contact.fromJson(data) as T;
    }
    if (t == _i11.Profile) {
      return _i11.Profile.fromJson(data) as T;
    }
    if (t == _i12.Rank) {
      return _i12.Rank.fromJson(data) as T;
    }
    if (t == _i13.UserInfo) {
      return _i13.UserInfo.fromJson(data) as T;
    }
    if (t == _i14.OtpException) {
      return _i14.OtpException.fromJson(data) as T;
    }
    if (t == _i15.OtpVerificationResult) {
      return _i15.OtpVerificationResult.fromJson(data) as T;
    }
    if (t == _i16.RegistrationForm) {
      return _i16.RegistrationForm.fromJson(data) as T;
    }
    if (t == _i17.ActiveChallengeSummary) {
      return _i17.ActiveChallengeSummary.fromJson(data) as T;
    }
    if (t == _i18.DailyStepTelemetry) {
      return _i18.DailyStepTelemetry.fromJson(data) as T;
    }
    if (t == _i19.HomeLeaderboardEntry) {
      return _i19.HomeLeaderboardEntry.fromJson(data) as T;
    }
    if (t == _i20.WeeklyStepAnalytics) {
      return _i20.WeeklyStepAnalytics.fromJson(data) as T;
    }
    if (t == _i21.ConfigKey) {
      return _i21.ConfigKey.fromJson(data) as T;
    }
    if (t == _i22.ConfigSnapshotVersion) {
      return _i22.ConfigSnapshotVersion.fromJson(data) as T;
    }
    if (t == _i23.PublicConfigVersion) {
      return _i23.PublicConfigVersion.fromJson(data) as T;
    }
    if (t == _i24.RemoteConfig) {
      return _i24.RemoteConfig.fromJson(data) as T;
    }
    if (t == _i25.RemoteConfigDefaultValue) {
      return _i25.RemoteConfigDefaultValue.fromJson(data) as T;
    }
    if (t == _i26.RemoteConfigValue) {
      return _i26.RemoteConfigValue.fromJson(data) as T;
    }
    if (t == _i27.RemoteConfigValueType) {
      return _i27.RemoteConfigValueType.fromJson(data) as T;
    }
    if (t == _i28.TargetingOverride) {
      return _i28.TargetingOverride.fromJson(data) as T;
    }
    if (t == _i29.RemoteLocalizationAuditLog) {
      return _i29.RemoteLocalizationAuditLog.fromJson(data) as T;
    }
    if (t == _i30.RemoteLocalizationRelease) {
      return _i30.RemoteLocalizationRelease.fromJson(data) as T;
    }
    if (t == _i31.RemoteLocalizationResponse) {
      return _i31.RemoteLocalizationResponse.fromJson(data) as T;
    }
    if (t == _i32.SecurityEvent) {
      return _i32.SecurityEvent.fromJson(data) as T;
    }
    if (t == _i33.StepIntegration) {
      return _i33.StepIntegration.fromJson(data) as T;
    }
    if (t == _i34.StepSync) {
      return _i34.StepSync.fromJson(data) as T;
    }
    if (t == _i35.UserDevice) {
      return _i35.UserDevice.fromJson(data) as T;
    }
    if (t == _i36.Wallet) {
      return _i36.Wallet.fromJson(data) as T;
    }
    if (t == _i37.WalletTransactions) {
      return _i37.WalletTransactions.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Gender?>()) {
      return (data != null ? _i2.Gender.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.TransactionType?>()) {
      return (data != null ? _i3.TransactionType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ApiException?>()) {
      return (data != null ? _i4.ApiException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ApiExceptionCode?>()) {
      return (data != null ? _i5.ApiExceptionCode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Account?>()) {
      return (data != null ? _i6.Account.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AccountState?>()) {
      return (data != null ? _i7.AccountState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AccountSummary?>()) {
      return (data != null ? _i8.AccountSummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Address?>()) {
      return (data != null ? _i9.Address.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Contact?>()) {
      return (data != null ? _i10.Contact.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Profile?>()) {
      return (data != null ? _i11.Profile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Rank?>()) {
      return (data != null ? _i12.Rank.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.UserInfo?>()) {
      return (data != null ? _i13.UserInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.OtpException?>()) {
      return (data != null ? _i14.OtpException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.OtpVerificationResult?>()) {
      return (data != null ? _i15.OtpVerificationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.RegistrationForm?>()) {
      return (data != null ? _i16.RegistrationForm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ActiveChallengeSummary?>()) {
      return (data != null ? _i17.ActiveChallengeSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.DailyStepTelemetry?>()) {
      return (data != null ? _i18.DailyStepTelemetry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.HomeLeaderboardEntry?>()) {
      return (data != null ? _i19.HomeLeaderboardEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.WeeklyStepAnalytics?>()) {
      return (data != null ? _i20.WeeklyStepAnalytics.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.ConfigKey?>()) {
      return (data != null ? _i21.ConfigKey.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.ConfigSnapshotVersion?>()) {
      return (data != null ? _i22.ConfigSnapshotVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.PublicConfigVersion?>()) {
      return (data != null ? _i23.PublicConfigVersion.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.RemoteConfig?>()) {
      return (data != null ? _i24.RemoteConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.RemoteConfigDefaultValue?>()) {
      return (data != null
              ? _i25.RemoteConfigDefaultValue.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i26.RemoteConfigValue?>()) {
      return (data != null ? _i26.RemoteConfigValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.RemoteConfigValueType?>()) {
      return (data != null ? _i27.RemoteConfigValueType.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.TargetingOverride?>()) {
      return (data != null ? _i28.TargetingOverride.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.RemoteLocalizationAuditLog?>()) {
      return (data != null
              ? _i29.RemoteLocalizationAuditLog.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i30.RemoteLocalizationRelease?>()) {
      return (data != null
              ? _i30.RemoteLocalizationRelease.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i31.RemoteLocalizationResponse?>()) {
      return (data != null
              ? _i31.RemoteLocalizationResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i32.SecurityEvent?>()) {
      return (data != null ? _i32.SecurityEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.StepIntegration?>()) {
      return (data != null ? _i33.StepIntegration.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.StepSync?>()) {
      return (data != null ? _i34.StepSync.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.UserDevice?>()) {
      return (data != null ? _i35.UserDevice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.Wallet?>()) {
      return (data != null ? _i36.Wallet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.WalletTransactions?>()) {
      return (data != null ? _i37.WalletTransactions.fromJson(data) : null)
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == Map<String, _i26.RemoteConfigValue>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i26.RemoteConfigValue>(v),
            ),
          )
          as T;
    }
    if (t == List<_i37.WalletTransactions>) {
      return (data as List)
              .map((e) => deserialize<_i37.WalletTransactions>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i37.WalletTransactions>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i37.WalletTransactions>(e))
                    .toList()
              : null)
          as T;
    }
    if (t ==
        List<
          ({_i38.AuthUserModel authUser, _i38.UserProfileModel userProfile})
        >) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      ({
                        _i38.AuthUserModel authUser,
                        _i38.UserProfileModel userProfile,
                      })
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _i1
            .getType<
              ({_i38.AuthUserModel authUser, _i38.UserProfileModel userProfile})
            >()) {
      return (
            authUser: deserialize<_i38.AuthUserModel>(
              ((data as Map)['n'] as Map)['authUser'],
            ),
            userProfile: deserialize<_i38.UserProfileModel>(
              data['n']['userProfile'],
            ),
          )
          as T;
    }
    if (t ==
        _i1
            .getType<
              ({_i38.AuthUserModel authUser, _i38.UserProfileModel userProfile})
            >()) {
      return (
            authUser: deserialize<_i38.AuthUserModel>(
              ((data as Map)['n'] as Map)['authUser'],
            ),
            userProfile: deserialize<_i38.UserProfileModel>(
              data['n']['userProfile'],
            ),
          )
          as T;
    }
    if (t == List<_i38.AuthUserModel>) {
      return (data as List)
              .map((e) => deserialize<_i38.AuthUserModel>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i39.HomeLeaderboardEntry>) {
      return (data as List)
              .map((e) => deserialize<_i39.HomeLeaderboardEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.SecurityEvent>) {
      return (data as List)
              .map((e) => deserialize<_i40.SecurityEvent>(e))
              .toList()
          as T;
    }
    try {
      return _i38.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i41.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i42.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Gender => 'Gender',
      _i3.TransactionType => 'TransactionType',
      _i4.ApiException => 'ApiException',
      _i5.ApiExceptionCode => 'ApiExceptionCode',
      _i6.Account => 'Account',
      _i7.AccountState => 'AccountState',
      _i8.AccountSummary => 'AccountSummary',
      _i9.Address => 'Address',
      _i10.Contact => 'Contact',
      _i11.Profile => 'Profile',
      _i12.Rank => 'Rank',
      _i13.UserInfo => 'UserInfo',
      _i14.OtpException => 'OtpException',
      _i15.OtpVerificationResult => 'OtpVerificationResult',
      _i16.RegistrationForm => 'RegistrationForm',
      _i17.ActiveChallengeSummary => 'ActiveChallengeSummary',
      _i18.DailyStepTelemetry => 'DailyStepTelemetry',
      _i19.HomeLeaderboardEntry => 'HomeLeaderboardEntry',
      _i20.WeeklyStepAnalytics => 'WeeklyStepAnalytics',
      _i21.ConfigKey => 'ConfigKey',
      _i22.ConfigSnapshotVersion => 'ConfigSnapshotVersion',
      _i23.PublicConfigVersion => 'PublicConfigVersion',
      _i24.RemoteConfig => 'RemoteConfig',
      _i25.RemoteConfigDefaultValue => 'RemoteConfigDefaultValue',
      _i26.RemoteConfigValue => 'RemoteConfigValue',
      _i27.RemoteConfigValueType => 'RemoteConfigValueType',
      _i28.TargetingOverride => 'TargetingOverride',
      _i29.RemoteLocalizationAuditLog => 'RemoteLocalizationAuditLog',
      _i30.RemoteLocalizationRelease => 'RemoteLocalizationRelease',
      _i31.RemoteLocalizationResponse => 'RemoteLocalizationResponse',
      _i32.SecurityEvent => 'SecurityEvent',
      _i33.StepIntegration => 'StepIntegration',
      _i34.StepSync => 'StepSync',
      _i35.UserDevice => 'UserDevice',
      _i36.Wallet => 'Wallet',
      _i37.WalletTransactions => 'WalletTransactions',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('baktaz.', '');
    }

    switch (data) {
      case _i2.Gender():
        return 'Gender';
      case _i3.TransactionType():
        return 'TransactionType';
      case _i4.ApiException():
        return 'ApiException';
      case _i5.ApiExceptionCode():
        return 'ApiExceptionCode';
      case _i6.Account():
        return 'Account';
      case _i7.AccountState():
        return 'AccountState';
      case _i8.AccountSummary():
        return 'AccountSummary';
      case _i9.Address():
        return 'Address';
      case _i10.Contact():
        return 'Contact';
      case _i11.Profile():
        return 'Profile';
      case _i12.Rank():
        return 'Rank';
      case _i13.UserInfo():
        return 'UserInfo';
      case _i14.OtpException():
        return 'OtpException';
      case _i15.OtpVerificationResult():
        return 'OtpVerificationResult';
      case _i16.RegistrationForm():
        return 'RegistrationForm';
      case _i17.ActiveChallengeSummary():
        return 'ActiveChallengeSummary';
      case _i18.DailyStepTelemetry():
        return 'DailyStepTelemetry';
      case _i19.HomeLeaderboardEntry():
        return 'HomeLeaderboardEntry';
      case _i20.WeeklyStepAnalytics():
        return 'WeeklyStepAnalytics';
      case _i21.ConfigKey():
        return 'ConfigKey';
      case _i22.ConfigSnapshotVersion():
        return 'ConfigSnapshotVersion';
      case _i23.PublicConfigVersion():
        return 'PublicConfigVersion';
      case _i24.RemoteConfig():
        return 'RemoteConfig';
      case _i25.RemoteConfigDefaultValue():
        return 'RemoteConfigDefaultValue';
      case _i26.RemoteConfigValue():
        return 'RemoteConfigValue';
      case _i27.RemoteConfigValueType():
        return 'RemoteConfigValueType';
      case _i28.TargetingOverride():
        return 'TargetingOverride';
      case _i29.RemoteLocalizationAuditLog():
        return 'RemoteLocalizationAuditLog';
      case _i30.RemoteLocalizationRelease():
        return 'RemoteLocalizationRelease';
      case _i31.RemoteLocalizationResponse():
        return 'RemoteLocalizationResponse';
      case _i32.SecurityEvent():
        return 'SecurityEvent';
      case _i33.StepIntegration():
        return 'StepIntegration';
      case _i34.StepSync():
        return 'StepSync';
      case _i35.UserDevice():
        return 'UserDevice';
      case _i36.Wallet():
        return 'Wallet';
      case _i37.WalletTransactions():
        return 'WalletTransactions';
    }
    className = _i38.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _i41.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i42.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Gender') {
      return deserialize<_i2.Gender>(data['data']);
    }
    if (dataClassName == 'TransactionType') {
      return deserialize<_i3.TransactionType>(data['data']);
    }
    if (dataClassName == 'ApiException') {
      return deserialize<_i4.ApiException>(data['data']);
    }
    if (dataClassName == 'ApiExceptionCode') {
      return deserialize<_i5.ApiExceptionCode>(data['data']);
    }
    if (dataClassName == 'Account') {
      return deserialize<_i6.Account>(data['data']);
    }
    if (dataClassName == 'AccountState') {
      return deserialize<_i7.AccountState>(data['data']);
    }
    if (dataClassName == 'AccountSummary') {
      return deserialize<_i8.AccountSummary>(data['data']);
    }
    if (dataClassName == 'Address') {
      return deserialize<_i9.Address>(data['data']);
    }
    if (dataClassName == 'Contact') {
      return deserialize<_i10.Contact>(data['data']);
    }
    if (dataClassName == 'Profile') {
      return deserialize<_i11.Profile>(data['data']);
    }
    if (dataClassName == 'Rank') {
      return deserialize<_i12.Rank>(data['data']);
    }
    if (dataClassName == 'UserInfo') {
      return deserialize<_i13.UserInfo>(data['data']);
    }
    if (dataClassName == 'OtpException') {
      return deserialize<_i14.OtpException>(data['data']);
    }
    if (dataClassName == 'OtpVerificationResult') {
      return deserialize<_i15.OtpVerificationResult>(data['data']);
    }
    if (dataClassName == 'RegistrationForm') {
      return deserialize<_i16.RegistrationForm>(data['data']);
    }
    if (dataClassName == 'ActiveChallengeSummary') {
      return deserialize<_i17.ActiveChallengeSummary>(data['data']);
    }
    if (dataClassName == 'DailyStepTelemetry') {
      return deserialize<_i18.DailyStepTelemetry>(data['data']);
    }
    if (dataClassName == 'HomeLeaderboardEntry') {
      return deserialize<_i19.HomeLeaderboardEntry>(data['data']);
    }
    if (dataClassName == 'WeeklyStepAnalytics') {
      return deserialize<_i20.WeeklyStepAnalytics>(data['data']);
    }
    if (dataClassName == 'ConfigKey') {
      return deserialize<_i21.ConfigKey>(data['data']);
    }
    if (dataClassName == 'ConfigSnapshotVersion') {
      return deserialize<_i22.ConfigSnapshotVersion>(data['data']);
    }
    if (dataClassName == 'PublicConfigVersion') {
      return deserialize<_i23.PublicConfigVersion>(data['data']);
    }
    if (dataClassName == 'RemoteConfig') {
      return deserialize<_i24.RemoteConfig>(data['data']);
    }
    if (dataClassName == 'RemoteConfigDefaultValue') {
      return deserialize<_i25.RemoteConfigDefaultValue>(data['data']);
    }
    if (dataClassName == 'RemoteConfigValue') {
      return deserialize<_i26.RemoteConfigValue>(data['data']);
    }
    if (dataClassName == 'RemoteConfigValueType') {
      return deserialize<_i27.RemoteConfigValueType>(data['data']);
    }
    if (dataClassName == 'TargetingOverride') {
      return deserialize<_i28.TargetingOverride>(data['data']);
    }
    if (dataClassName == 'RemoteLocalizationAuditLog') {
      return deserialize<_i29.RemoteLocalizationAuditLog>(data['data']);
    }
    if (dataClassName == 'RemoteLocalizationRelease') {
      return deserialize<_i30.RemoteLocalizationRelease>(data['data']);
    }
    if (dataClassName == 'RemoteLocalizationResponse') {
      return deserialize<_i31.RemoteLocalizationResponse>(data['data']);
    }
    if (dataClassName == 'SecurityEvent') {
      return deserialize<_i32.SecurityEvent>(data['data']);
    }
    if (dataClassName == 'StepIntegration') {
      return deserialize<_i33.StepIntegration>(data['data']);
    }
    if (dataClassName == 'StepSync') {
      return deserialize<_i34.StepSync>(data['data']);
    }
    if (dataClassName == 'UserDevice') {
      return deserialize<_i35.UserDevice>(data['data']);
    }
    if (dataClassName == 'Wallet') {
      return deserialize<_i36.Wallet>(data['data']);
    }
    if (dataClassName == 'WalletTransactions') {
      return deserialize<_i37.WalletTransactions>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i38.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i41.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i42.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i38.Protocol().registerHostProtocol('baktaz', this);
    _i41.Protocol().registerHostProtocol('baktaz', this);
    _i42.Protocol().registerHostProtocol('baktaz', this);
  }

  @override
  String getModuleName() => 'baktaz';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    if (record
        is ({_i38.AuthUserModel authUser, _i38.UserProfileModel userProfile})) {
      return {
        "n": {
          "authUser": record.authUser.toJson(),
          "userProfile": record.userProfile.toJson(),
        },
      };
    }
    try {
      return _i38.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i41.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i42.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}
