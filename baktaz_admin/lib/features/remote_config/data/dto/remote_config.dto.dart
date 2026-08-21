import 'package:baktaz_admin/features/remote_config/data/dto/config_snapshot_version.dto.dart';
import 'package:baktaz_admin/features/remote_config/data/dto/remote_config_value.dto.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config.dto.freezed.dart';
part 'remote_config.dto.g.dart';

@freezed
sealed class RemoteConfigDTO with _$RemoteConfigDTO {
  const factory RemoteConfigDTO({
    required Map<String, RemoteConfigValueDTO> parameters,
    required ConfigSnapshotVersionDTO version,
  }) = _RemoteConfigDTO;

  const RemoteConfigDTO._();

  factory RemoteConfigDTO.fromJson(Map<String, dynamic> json) => _$RemoteConfigDTOFromJson(json);

  factory RemoteConfigDTO.fromDomain(RemoteConfig domain) => RemoteConfigDTO(
    parameters: domain.parameters.map(
      (String key, RemoteConfigValue value) =>
          MapEntry<String, RemoteConfigValueDTO>(key, RemoteConfigValueDTO.fromDomain(value)),
    ),
    version: ConfigSnapshotVersionDTO.fromDomain(domain.version),
  );

  RemoteConfig toDomain() => RemoteConfig(
    parameters: parameters.map(
      (String key, RemoteConfigValueDTO value) => MapEntry<String, RemoteConfigValue>(key, value.toDomain()),
    ),
    version: version.toDomain(),
  );
}
