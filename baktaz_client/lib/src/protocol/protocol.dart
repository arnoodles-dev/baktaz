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
import 'features/account/domain/model/user_info.dart' as _i12;
import 'features/auth/domain/models/otp_exception.dart' as _i13;
import 'features/auth/domain/models/otp_verification_result.dart' as _i14;
import 'features/auth/domain/models/registration_form.dart' as _i15;
import 'features/home/domain/model/active_challenge_summary.dart' as _i16;
import 'features/home/domain/model/daily_step_telemetry.dart' as _i17;
import 'features/home/domain/model/home_leaderboard_entry.dart' as _i18;
import 'features/home/domain/model/weekly_step_analytics.dart' as _i19;
import 'features/security/domain/models/security_event.dart' as _i20;
import 'features/wallet/domain/model/wallet.dart' as _i21;
import 'features/wallet/domain/model/wallet_transactions.dart' as _i22;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i23;
import 'package:baktaz_client/src/protocol/features/home/domain/model/home_leaderboard_entry.dart'
    as _i24;
import 'package:baktaz_client/src/protocol/features/security/domain/models/security_event.dart'
    as _i25;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i26;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i27;
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
export 'features/account/domain/model/user_info.dart';
export 'features/auth/domain/models/otp_exception.dart';
export 'features/auth/domain/models/otp_verification_result.dart';
export 'features/auth/domain/models/registration_form.dart';
export 'features/home/domain/model/active_challenge_summary.dart';
export 'features/home/domain/model/daily_step_telemetry.dart';
export 'features/home/domain/model/home_leaderboard_entry.dart';
export 'features/home/domain/model/weekly_step_analytics.dart';
export 'features/security/domain/models/security_event.dart';
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
    if (t == _i12.UserInfo) {
      return _i12.UserInfo.fromJson(data) as T;
    }
    if (t == _i13.OtpException) {
      return _i13.OtpException.fromJson(data) as T;
    }
    if (t == _i14.OtpVerificationResult) {
      return _i14.OtpVerificationResult.fromJson(data) as T;
    }
    if (t == _i15.RegistrationForm) {
      return _i15.RegistrationForm.fromJson(data) as T;
    }
    if (t == _i16.ActiveChallengeSummary) {
      return _i16.ActiveChallengeSummary.fromJson(data) as T;
    }
    if (t == _i17.DailyStepTelemetry) {
      return _i17.DailyStepTelemetry.fromJson(data) as T;
    }
    if (t == _i18.HomeLeaderboardEntry) {
      return _i18.HomeLeaderboardEntry.fromJson(data) as T;
    }
    if (t == _i19.WeeklyStepAnalytics) {
      return _i19.WeeklyStepAnalytics.fromJson(data) as T;
    }
    if (t == _i20.SecurityEvent) {
      return _i20.SecurityEvent.fromJson(data) as T;
    }
    if (t == _i21.Wallet) {
      return _i21.Wallet.fromJson(data) as T;
    }
    if (t == _i22.WalletTransactions) {
      return _i22.WalletTransactions.fromJson(data) as T;
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
    if (t == _i1.getType<_i12.UserInfo?>()) {
      return (data != null ? _i12.UserInfo.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.OtpException?>()) {
      return (data != null ? _i13.OtpException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.OtpVerificationResult?>()) {
      return (data != null ? _i14.OtpVerificationResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.RegistrationForm?>()) {
      return (data != null ? _i15.RegistrationForm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ActiveChallengeSummary?>()) {
      return (data != null ? _i16.ActiveChallengeSummary.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.DailyStepTelemetry?>()) {
      return (data != null ? _i17.DailyStepTelemetry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.HomeLeaderboardEntry?>()) {
      return (data != null ? _i18.HomeLeaderboardEntry.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.WeeklyStepAnalytics?>()) {
      return (data != null ? _i19.WeeklyStepAnalytics.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.SecurityEvent?>()) {
      return (data != null ? _i20.SecurityEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Wallet?>()) {
      return (data != null ? _i21.Wallet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.WalletTransactions?>()) {
      return (data != null ? _i22.WalletTransactions.fromJson(data) : null)
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
    if (t == List<_i22.WalletTransactions>) {
      return (data as List)
              .map((e) => deserialize<_i22.WalletTransactions>(e))
              .toList()
          as T;
    }
    if (t == _i1.getType<List<_i22.WalletTransactions>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i22.WalletTransactions>(e))
                    .toList()
              : null)
          as T;
    }
    if (t ==
        List<
          ({_i23.AuthUserModel authUser, _i23.UserProfileModel userProfile})
        >) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      ({
                        _i23.AuthUserModel authUser,
                        _i23.UserProfileModel userProfile,
                      })
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _i1
            .getType<
              ({_i23.AuthUserModel authUser, _i23.UserProfileModel userProfile})
            >()) {
      return (
            authUser: deserialize<_i23.AuthUserModel>(
              ((data as Map)['n'] as Map)['authUser'],
            ),
            userProfile: deserialize<_i23.UserProfileModel>(
              data['n']['userProfile'],
            ),
          )
          as T;
    }
    if (t ==
        _i1
            .getType<
              ({_i23.AuthUserModel authUser, _i23.UserProfileModel userProfile})
            >()) {
      return (
            authUser: deserialize<_i23.AuthUserModel>(
              ((data as Map)['n'] as Map)['authUser'],
            ),
            userProfile: deserialize<_i23.UserProfileModel>(
              data['n']['userProfile'],
            ),
          )
          as T;
    }
    if (t == List<_i23.AuthUserModel>) {
      return (data as List)
              .map((e) => deserialize<_i23.AuthUserModel>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i24.HomeLeaderboardEntry>) {
      return (data as List)
              .map((e) => deserialize<_i24.HomeLeaderboardEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.SecurityEvent>) {
      return (data as List)
              .map((e) => deserialize<_i25.SecurityEvent>(e))
              .toList()
          as T;
    }
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i26.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i27.Protocol().deserialize<T>(data, t);
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
      _i12.UserInfo => 'UserInfo',
      _i13.OtpException => 'OtpException',
      _i14.OtpVerificationResult => 'OtpVerificationResult',
      _i15.RegistrationForm => 'RegistrationForm',
      _i16.ActiveChallengeSummary => 'ActiveChallengeSummary',
      _i17.DailyStepTelemetry => 'DailyStepTelemetry',
      _i18.HomeLeaderboardEntry => 'HomeLeaderboardEntry',
      _i19.WeeklyStepAnalytics => 'WeeklyStepAnalytics',
      _i20.SecurityEvent => 'SecurityEvent',
      _i21.Wallet => 'Wallet',
      _i22.WalletTransactions => 'WalletTransactions',
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
      case _i12.UserInfo():
        return 'UserInfo';
      case _i13.OtpException():
        return 'OtpException';
      case _i14.OtpVerificationResult():
        return 'OtpVerificationResult';
      case _i15.RegistrationForm():
        return 'RegistrationForm';
      case _i16.ActiveChallengeSummary():
        return 'ActiveChallengeSummary';
      case _i17.DailyStepTelemetry():
        return 'DailyStepTelemetry';
      case _i18.HomeLeaderboardEntry():
        return 'HomeLeaderboardEntry';
      case _i19.WeeklyStepAnalytics():
        return 'WeeklyStepAnalytics';
      case _i20.SecurityEvent():
        return 'SecurityEvent';
      case _i21.Wallet():
        return 'Wallet';
      case _i22.WalletTransactions():
        return 'WalletTransactions';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _i26.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _i27.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'UserInfo') {
      return deserialize<_i12.UserInfo>(data['data']);
    }
    if (dataClassName == 'OtpException') {
      return deserialize<_i13.OtpException>(data['data']);
    }
    if (dataClassName == 'OtpVerificationResult') {
      return deserialize<_i14.OtpVerificationResult>(data['data']);
    }
    if (dataClassName == 'RegistrationForm') {
      return deserialize<_i15.RegistrationForm>(data['data']);
    }
    if (dataClassName == 'ActiveChallengeSummary') {
      return deserialize<_i16.ActiveChallengeSummary>(data['data']);
    }
    if (dataClassName == 'DailyStepTelemetry') {
      return deserialize<_i17.DailyStepTelemetry>(data['data']);
    }
    if (dataClassName == 'HomeLeaderboardEntry') {
      return deserialize<_i18.HomeLeaderboardEntry>(data['data']);
    }
    if (dataClassName == 'WeeklyStepAnalytics') {
      return deserialize<_i19.WeeklyStepAnalytics>(data['data']);
    }
    if (dataClassName == 'SecurityEvent') {
      return deserialize<_i20.SecurityEvent>(data['data']);
    }
    if (dataClassName == 'Wallet') {
      return deserialize<_i21.Wallet>(data['data']);
    }
    if (dataClassName == 'WalletTransactions') {
      return deserialize<_i22.WalletTransactions>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i26.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i27.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _i23.Protocol().registerHostProtocol('baktaz', this);
    _i26.Protocol().registerHostProtocol('baktaz', this);
    _i27.Protocol().registerHostProtocol('baktaz', this);
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
        is ({_i23.AuthUserModel authUser, _i23.UserProfileModel userProfile})) {
      return {
        "n": {
          "authUser": record.authUser.toJson(),
          "userProfile": record.userProfile.toJson(),
        },
      };
    }
    try {
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i26.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i27.Protocol().mapRecordToJson(record);
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
