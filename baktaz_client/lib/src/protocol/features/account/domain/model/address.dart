/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Address
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Address._({
    this.id,
    this.label,
    this.street,
    this.subLocality,
    this.locality,
    this.administrativeArea,
    this.country,
    this.postalCode,
    bool? isDefault,
  }) : isDefault = isDefault ?? false;

  factory Address({
    _i1.UuidValue? id,
    String? label,
    String? street,
    String? subLocality,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) = _AddressImpl;

  factory Address.fromJson(Map<String, dynamic> jsonSerialization) {
    return Address(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      label: jsonSerialization['label'] as String?,
      street: jsonSerialization['street'] as String?,
      subLocality: jsonSerialization['subLocality'] as String?,
      locality: jsonSerialization['locality'] as String?,
      administrativeArea: jsonSerialization['administrativeArea'] as String?,
      country: jsonSerialization['country'] as String?,
      postalCode: jsonSerialization['postalCode'] as String?,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String? label;

  String? street;

  String? subLocality;

  String? locality;

  String? administrativeArea;

  String? country;

  String? postalCode;

  bool isDefault;

  /// Returns a shallow copy of this [Address]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Address copyWith({
    _i1.UuidValue? id,
    String? label,
    String? street,
    String? subLocality,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
    bool? isDefault,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Address',
      if (id != null) 'id': id?.toJson(),
      if (label != null) 'label': label,
      if (street != null) 'street': street,
      if (subLocality != null) 'subLocality': subLocality,
      if (locality != null) 'locality': locality,
      if (administrativeArea != null) 'administrativeArea': administrativeArea,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Address',
      if (id != null) 'id': id?.toJson(),
      if (label != null) 'label': label,
      if (street != null) 'street': street,
      if (subLocality != null) 'subLocality': subLocality,
      if (locality != null) 'locality': locality,
      if (administrativeArea != null) 'administrativeArea': administrativeArea,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AddressImpl extends Address {
  _AddressImpl({
    _i1.UuidValue? id,
    String? label,
    String? street,
    String? subLocality,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
    bool? isDefault,
  }) : super._(
         id: id,
         label: label,
         street: street,
         subLocality: subLocality,
         locality: locality,
         administrativeArea: administrativeArea,
         country: country,
         postalCode: postalCode,
         isDefault: isDefault,
       );

  /// Returns a shallow copy of this [Address]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Address copyWith({
    Object? id = _Undefined,
    Object? label = _Undefined,
    Object? street = _Undefined,
    Object? subLocality = _Undefined,
    Object? locality = _Undefined,
    Object? administrativeArea = _Undefined,
    Object? country = _Undefined,
    Object? postalCode = _Undefined,
    bool? isDefault,
  }) {
    return Address(
      id: id is _i1.UuidValue? ? id : this.id,
      label: label is String? ? label : this.label,
      street: street is String? ? street : this.street,
      subLocality: subLocality is String? ? subLocality : this.subLocality,
      locality: locality is String? ? locality : this.locality,
      administrativeArea: administrativeArea is String?
          ? administrativeArea
          : this.administrativeArea,
      country: country is String? ? country : this.country,
      postalCode: postalCode is String? ? postalCode : this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
