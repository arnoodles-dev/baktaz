import 'package:json_annotation/json_annotation.dart';

part 'resource_error.dto.g.dart';

@JsonSerializable()
final class ResourceErrorDTO {
  const ResourceErrorDTO(this.type, this.message);
  final String? type;
  final String? message;

  static const ResourceErrorDTO Function(Map<String, dynamic> json) fromJsonFactory = _$ResourceErrorDTOFromJson;

  Map<String, dynamic> toJson() => _$ResourceErrorDTOToJson(this);
}
