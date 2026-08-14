import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_key.freezed.dart';
part 'localization_key.g.dart';

@freezed
abstract class LocalizationKey with _$LocalizationKey {
  const factory LocalizationKey({
    required int id,
    required String namespace,
    required String key,
    required String defaultValueEn,
    List<String>? variables,
    String? description,
  }) = _LocalizationKey;

  factory LocalizationKey.fromJson(Map<String, dynamic> json) => _$LocalizationKeyFromJson(json);
}
