import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_snapshot_version.dto.freezed.dart';
part 'config_snapshot_version.dto.g.dart';

@freezed
sealed class ConfigSnapshotVersionDTO with _$ConfigSnapshotVersionDTO {
  const factory ConfigSnapshotVersionDTO({
    required String versionNumber,
    required String updateTime,
    required String updateUser,
  }) = _ConfigSnapshotVersionDTO;

  const ConfigSnapshotVersionDTO._();

  factory ConfigSnapshotVersionDTO.fromJson(Map<String, dynamic> json) => _$ConfigSnapshotVersionDTOFromJson(json);

  factory ConfigSnapshotVersionDTO.fromDomain(ConfigSnapshotVersion domain) => ConfigSnapshotVersionDTO(
    versionNumber: domain.versionNumber.getValue(),
    updateTime: domain.updateTime.toIso8601String(),
    updateUser: domain.updateUser.getValue(),
  );

  ConfigSnapshotVersion toDomain() => ConfigSnapshotVersion(
    versionNumber: ValueString(versionNumber, fieldName: 'versionNumber'),
    updateTime: DateTime.tryParse(updateTime) ?? DateTime.now(),
    updateUser: EmailAddress(updateUser),
  );
}
