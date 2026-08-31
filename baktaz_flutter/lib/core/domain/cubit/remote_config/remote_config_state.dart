part of 'remote_config_cubit.dart';

@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory RemoteConfigState({@Default(<String, dynamic>{}) Map<String, dynamic> values}) = _RemoteConfigState;

  const RemoteConfigState._();

  bool get isMaintenance => values['is_maintenance'] == true || values['is_maintenance'] == 'true';

  String? get minSupportedVersion => values['min_supported_version'] as String?;

  String? get androidStoreUrl => values['android_store_url'] as String?;

  String? get iosStoreUrl => values['ios_store_url'] as String?;

  bool get isChatEnabled => values['enable_chat'] == true || values['enable_chat'] == 'true';

  bool get isPayoutEnabled => values['enable_payout'] == true || values['enable_payout'] == 'true';

  bool get isChallengesEnabled => values['enable_challenges'] == true || values['enable_challenges'] == 'true';

  /// Escape hatch for dynamic admin-defined keys (e.g. webview configKey).
  String? value(String key) => values[key] as String?;
}
