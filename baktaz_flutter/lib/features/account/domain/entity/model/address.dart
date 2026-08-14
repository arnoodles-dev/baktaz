import 'package:baktaz_client/baktaz_client.dart' as serverpod;
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';

@freezed
abstract class Address with _$Address {
  const factory Address({
    required UniqueId id,
    ValueName? label,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
    String? subLocality,
    String? street,
    @Default(false) bool? isDefault,
  }) = _Address;

  const Address._();

  factory Address.fromServer(serverpod.Address address) => Address(
    id: UniqueId.fromUniqueString(address.id?.toString() ?? const serverpod.Uuid().v4()),
    label: address.label.let(ValueName.new),
    street: address.street,
    subLocality: address.subLocality,
    locality: address.locality,
    administrativeArea: address.administrativeArea,
    country: address.country,
    postalCode: address.postalCode,
    isDefault: address.isDefault,
  );

  serverpod.Address toServer() => serverpod.Address(
    id: serverpod.UuidValue.fromString(id.getValue()),
    label: label?.getValue(),
    street: street,
    subLocality: subLocality,
    locality: locality,
    administrativeArea: administrativeArea,
    country: country,
    postalCode: postalCode,
    isDefault: isDefault,
  );

  Option<Failure> get validate => id.validate.andThen(() => label?.validate ?? right(unit)).fold(some, (_) => none());

  String get displayAddress => <String?>[
    street,
    subLocality,
    locality,
    administrativeArea,
  ].where((String? element) => element != null && element.isNotEmpty).join(', ');
}
