import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_app_config.dto.freezed.dart';
part 'remote_app_config.dto.g.dart';

@freezed
abstract class RemoteAppConfigDTO with _$RemoteAppConfigDTO {
  const factory RemoteAppConfigDTO({
    @JsonKey(name: 'is_maintenance') required bool isMaintenance,
    @JsonKey(name: 'min_supported_version') required String minSupportedVersion,
    @JsonKey(name: 'android_store_url') required String androidStoreUrl,
    @JsonKey(name: 'ios_store_url') required String iosStoreUrl,
    @JsonKey(name: 'help_center_url') required String helpCenterUrl,
    @JsonKey(name: 'about_us_url') required String aboutUsUrl,
    @JsonKey(name: 'privacy_policy_url') required String privacyPolicyUrl,
    required Map<String, dynamic> en,
  }) = _RemoteAppConfigDTO;

  const RemoteAppConfigDTO._();

  factory RemoteAppConfigDTO.fallback() => const _RemoteAppConfigDTO(
    isMaintenance: false,
    minSupportedVersion: '1.0.0',
    androidStoreUrl: 'https://play.google.com/',
    iosStoreUrl: 'https://www.apple.com/app-store/',
    privacyPolicyUrl: 'https://www.google.com',
    helpCenterUrl: 'https://www.google.com',
    aboutUsUrl: 'https://www.google.com',
    en: <String, dynamic>{},
  );

  factory RemoteAppConfigDTO.fromJson(Map<String, dynamic> json) => _$RemoteAppConfigDTOFromJson(json);
}
