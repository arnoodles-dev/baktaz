import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_translation.freezed.dart';
part 'localization_translation.g.dart';

@freezed
abstract class LocalizationTranslation with _$LocalizationTranslation {
  const factory LocalizationTranslation({
    required int keyId,
    required String locale,
    required String value,
    String? pluralForm,
  }) = _LocalizationTranslation;

  factory LocalizationTranslation.fromJson(Map<String, dynamic> json) => _$LocalizationTranslationFromJson(json);
}
