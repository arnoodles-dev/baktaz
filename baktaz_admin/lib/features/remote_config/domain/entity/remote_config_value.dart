import 'dart:convert';

import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_value.freezed.dart';

/// Represents a single remote configuration parameter value.
@freezed
sealed class RemoteConfigValue with _$RemoteConfigValue {
  const factory RemoteConfigValue({
    required ConfigDefaultValue defaultValue,
    required ConfigValueType valueType,
    ValueString? description,
    DateTime? lastModified,
  }) = _RemoteConfigValue;

  const RemoteConfigValue._();

  /// Convenience getter for the raw string value.
  String get rawValue {
    final dynamic val = defaultValue.value.getValue();
    if (val is Map || val is List) {
      return jsonEncode(val);
    }
    return val.toString();
  }

  Option<Failure> get validate =>
      defaultValue.validate.alt(() => description?.validate.fold(some, (_) => none()) ?? none());
}

/// Value object wrapping the default value of a remote config parameter.
@freezed
sealed class ConfigDefaultValue with _$ConfigDefaultValue {
  const factory ConfigDefaultValue({required ValueObject<dynamic> value}) = _ConfigDefaultValue;

  const ConfigDefaultValue._();

  Option<Failure> get validate => value.validate.fold(some, (_) => none());
}
