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

abstract class RemoteLocalizationRelease
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  RemoteLocalizationRelease._({
    this.id,
    required this.version,
    required this.publishedBy,
    required this.publishedAt,
    required this.active,
    this.notes,
    required this.payloadJson,
    required this.checksum,
  });

  factory RemoteLocalizationRelease({
    int? id,
    required int version,
    required String publishedBy,
    required DateTime publishedAt,
    required bool active,
    String? notes,
    required String payloadJson,
    required String checksum,
  }) = _RemoteLocalizationReleaseImpl;

  factory RemoteLocalizationRelease.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RemoteLocalizationRelease(
      id: jsonSerialization['id'] as int?,
      version: jsonSerialization['version'] as int,
      publishedBy: jsonSerialization['publishedBy'] as String,
      publishedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['publishedAt'],
      ),
      active: _i1.BoolJsonExtension.fromJson(jsonSerialization['active']),
      notes: jsonSerialization['notes'] as String?,
      payloadJson: jsonSerialization['payloadJson'] as String,
      checksum: jsonSerialization['checksum'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int version;

  String publishedBy;

  DateTime publishedAt;

  bool active;

  String? notes;

  String payloadJson;

  String checksum;

  /// Returns a shallow copy of this [RemoteLocalizationRelease]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RemoteLocalizationRelease copyWith({
    int? id,
    int? version,
    String? publishedBy,
    DateTime? publishedAt,
    bool? active,
    String? notes,
    String? payloadJson,
    String? checksum,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RemoteLocalizationRelease',
      if (id != null) 'id': id,
      'version': version,
      'publishedBy': publishedBy,
      'publishedAt': publishedAt.toJson(),
      'active': active,
      if (notes != null) 'notes': notes,
      'payloadJson': payloadJson,
      'checksum': checksum,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RemoteLocalizationRelease',
      if (id != null) 'id': id,
      'version': version,
      'publishedBy': publishedBy,
      'publishedAt': publishedAt.toJson(),
      'active': active,
      if (notes != null) 'notes': notes,
      'payloadJson': payloadJson,
      'checksum': checksum,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RemoteLocalizationReleaseImpl extends RemoteLocalizationRelease {
  _RemoteLocalizationReleaseImpl({
    int? id,
    required int version,
    required String publishedBy,
    required DateTime publishedAt,
    required bool active,
    String? notes,
    required String payloadJson,
    required String checksum,
  }) : super._(
         id: id,
         version: version,
         publishedBy: publishedBy,
         publishedAt: publishedAt,
         active: active,
         notes: notes,
         payloadJson: payloadJson,
         checksum: checksum,
       );

  /// Returns a shallow copy of this [RemoteLocalizationRelease]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RemoteLocalizationRelease copyWith({
    Object? id = _Undefined,
    int? version,
    String? publishedBy,
    DateTime? publishedAt,
    bool? active,
    Object? notes = _Undefined,
    String? payloadJson,
    String? checksum,
  }) {
    return RemoteLocalizationRelease(
      id: id is int? ? id : this.id,
      version: version ?? this.version,
      publishedBy: publishedBy ?? this.publishedBy,
      publishedAt: publishedAt ?? this.publishedAt,
      active: active ?? this.active,
      notes: notes is String? ? notes : this.notes,
      payloadJson: payloadJson ?? this.payloadJson,
      checksum: checksum ?? this.checksum,
    );
  }
}
