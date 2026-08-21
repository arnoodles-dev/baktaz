import 'dart:convert';

import 'package:baktaz_admin/features/remote_config/data/dto/remote_config.dto.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/interface/i_remote_config_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Mock implementation of [IRemoteConfigRepository] that loads from a local JSON asset.
@LazySingleton(as: IRemoteConfigRepository)
class RemoteConfigRepository implements IRemoteConfigRepository {
  const RemoteConfigRepository();

  static const Duration _loadDelay = Duration(milliseconds: 500);
  static const Duration _publishDelay = Duration(milliseconds: 800);
  static const String _assetPath = 'assets/json/remote_config_baktaz_13.json';

  @override
  TaskResult<RemoteConfig> getRemoteConfig() => TaskEither<Failure, RemoteConfig>.tryCatch(() async {
    await Future<void>.delayed(_loadDelay);

    final String jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;

    final RemoteConfig possibleFailure = RemoteConfigDTO.fromJson(json).toDomain();
    if (possibleFailure.validate.isSome()) {
      throw possibleFailure.validate.asSome();
    }

    return possibleFailure;
  }, (Object error, StackTrace stackTrace) => error is Failure ? error : Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> publishConfig(RemoteConfig config) => TaskEither<Failure, Unit>.tryCatch(() async {
    await Future<void>.delayed(_publishDelay);

    // Keep local validation compile check for RemoteConfigDTO serialization
    final Map<String, dynamic> _ = RemoteConfigDTO.fromDomain(config).toJson();

    return unit;
  }, (Object error, StackTrace stackTrace) => error is Failure ? error : Failure.unexpected(error.toString()));
}
