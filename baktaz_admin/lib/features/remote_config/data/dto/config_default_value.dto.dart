import 'dart:convert';

import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_default_value.dto.freezed.dart';
part 'config_default_value.dto.g.dart';

@freezed
sealed class ConfigDefaultValueDTO with _$ConfigDefaultValueDTO {
  const factory ConfigDefaultValueDTO({@JsonKey(readValue: _readValue) required String value}) = _ConfigDefaultValueDTO;

  const ConfigDefaultValueDTO._();

  factory ConfigDefaultValueDTO.fromJson(Map<String, dynamic> json) => _$ConfigDefaultValueDTOFromJson(json);

  factory ConfigDefaultValueDTO.fromDomain(ConfigDefaultValue domain) {
    final dynamic val = domain.value.getValue();
    if (val is Map || val is List) {
      return ConfigDefaultValueDTO(value: jsonEncode(val));
    }
    return ConfigDefaultValueDTO(value: val.toString());
  }
}

Object? _readValue(Map<dynamic, dynamic> json, String key) {
  final dynamic val = json[key];
  if (val != null && val is! String) {
    if (val is Map || val is List) {
      return jsonEncode(val);
    }
    return val.toString();
  }
  return val;
}
