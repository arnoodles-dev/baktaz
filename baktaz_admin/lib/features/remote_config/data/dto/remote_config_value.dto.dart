import 'dart:convert';

import 'package:baktaz_admin/features/remote_config/data/dto/config_default_value.dto.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_value.dto.freezed.dart';
part 'remote_config_value.dto.g.dart';

@freezed
sealed class RemoteConfigValueDTO with _$RemoteConfigValueDTO {
  const factory RemoteConfigValueDTO({
    required ConfigDefaultValueDTO defaultValue,
    required String valueType,
    String? description,
    String? lastModified,
  }) = _RemoteConfigValueDTO;

  const RemoteConfigValueDTO._();

  factory RemoteConfigValueDTO.fromJson(Map<String, dynamic> json) => _$RemoteConfigValueDTOFromJson(json);

  factory RemoteConfigValueDTO.fromDomain(RemoteConfigValue domain) => RemoteConfigValueDTO(
    defaultValue: ConfigDefaultValueDTO.fromDomain(domain.defaultValue),
    valueType: domain.valueType.name.toUpperCase(),
    description: domain.description?.getValue(),
    lastModified: domain.lastModified?.toIso8601String(),
  );

  /// Returns the value cast to the type indicated by [valueType].
  dynamic get typedValue {
    final String raw = defaultValue.value;
    return switch (valueType.toUpperCase()) {
      'STRING' => raw,
      'BOOLEAN' => (raw.toLowerCase() == 'true' || raw.toLowerCase() == 'false') ? raw.toLowerCase() == 'true' : null,
      'NUMBER' => num.tryParse(raw),
      'JSON' => _tryParseJson(raw),
      _ => raw,
    };
  }

  dynamic _tryParseJson(String raw) {
    try {
      return jsonDecode(raw);
    } on Exception catch (_) {
      return null;
    }
  }

  RemoteConfigValue toDomain() {
    final ConfigValueType type = ConfigValueType.fromString(valueType);
    final dynamic typed = typedValue;
    late final ValueObject<dynamic> mappedValueObject;

    switch (type) {
      case ConfigValueType.string:
        mappedValueObject = ValueString(typed as String, fieldName: 'defaultValue');
      case ConfigValueType.boolean:
        mappedValueObject = ValueBoolean(input: typed as bool?, fieldName: 'defaultValue');
      case ConfigValueType.number:
        mappedValueObject = Number(typed as num?);
      case ConfigValueType.json:
        mappedValueObject = ValueJson(typed, fieldName: 'defaultValue');
    }

    return RemoteConfigValue(
      defaultValue: ConfigDefaultValue(value: mappedValueObject),
      valueType: type,
      description: description.let((String desc) => ValueString(desc, fieldName: 'description')),
      lastModified: lastModified != null ? DateTime.tryParse(lastModified!) : null,
    );
  }
}
