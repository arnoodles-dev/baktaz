import 'dart:convert';

import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_admin/features/localization/domain/interface/i_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@LazySingleton(as: ILocalizationRepository)
final class LocalizationRepository implements ILocalizationRepository {
  static const Duration _loadDelay = Duration(milliseconds: 500);
  static const Duration _publishDelay = Duration(milliseconds: 800);
  static const String _assetPath = 'assets/i18n/en.i18n.json';

  final RegExp _variableRegex = RegExp(r'\$\{([a-zA-Z0-9_]+)(?:\s*:\s*[a-zA-Z0-9_]+)?\}');

  @override
  TaskResult<PaginatedResponse<LocalizationKey>> getKeys({
    required int page,
    required int limit,
    required String sortField,
    required bool ascending,
  }) => TaskEither<Failure, PaginatedResponse<LocalizationKey>>.tryCatch(() async {
    await Future<void>.delayed(_loadDelay);

    final String jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;

    final List<LocalizationKey> flattenedKeys = <LocalizationKey>[];
    flattenJson(json, '', flattenedKeys);

    // Sort
    flattenedKeys.sort((LocalizationKey a, LocalizationKey b) {
      int comparison = 0;
      switch (sortField) {
        case 'key':
          comparison = '${a.namespace}.${a.key}'.compareTo('${b.namespace}.${b.key}');
        case 'defaultValueEn':
          comparison = a.defaultValueEn.compareTo(b.defaultValueEn);
        default:
          comparison = '${a.namespace}.${a.key}'.compareTo('${b.namespace}.${b.key}');
      }
      return ascending ? comparison : -comparison;
    });

    // Paginate
    final int totalCount = flattenedKeys.length;
    final int startIndex = (page - 1) * limit;
    final int endIndex = (startIndex + limit) > totalCount ? totalCount : (startIndex + limit);

    final List<LocalizationKey> paginatedData = startIndex < totalCount
        ? flattenedKeys.sublist(startIndex, endIndex)
        : <LocalizationKey>[];

    return PaginatedResponse<LocalizationKey>(data: paginatedData, totalCount: totalCount);
  }, (Object error, StackTrace stackTrace) => error is Failure ? error : Failure.unexpected(error.toString()));

  @override
  TaskResult<Unit> publishTranslations(List<LocalizationTranslation> translations) =>
      TaskEither<Failure, Unit>.tryCatch(() async {
        await Future<void>.delayed(_publishDelay);
        return unit;
      }, (Object error, StackTrace stackTrace) => error is Failure ? error : Failure.unexpected(error.toString()));

  @visibleForTesting
  void flattenJson(Map<String, dynamic> json, String currentPath, List<LocalizationKey> output) {
    for (final MapEntry<String, dynamic> entry in json.entries) {
      final String newPath = currentPath.isEmpty ? entry.key : '$currentPath.${entry.key}';

      if (entry.value is Map<String, dynamic>) {
        flattenJson(entry.value as Map<String, dynamic>, newPath, output);
      } else if (entry.value is String) {
        final String value = entry.value as String;

        final Iterable<Match> matches = _variableRegex.allMatches(value);
        final List<String> variables = matches.map((Match m) => m.group(1)!).toList();

        final List<String> parts = newPath.split('.');
        final String namespace = parts.first;
        final String key = parts.length > 1 ? parts.sublist(1).join('.') : '';

        output.add(
          LocalizationKey(
            id: output.length + 1,
            namespace: namespace,
            key: key,
            variables: variables.isNotEmpty ? variables : null,
            defaultValueEn: value,
          ),
        );
      } else if (entry.value is List) {
        final List<dynamic> list = entry.value as List<dynamic>;
        for (int i = 0; i < list.length; i++) {
          final dynamic item = list[i];
          if (item is String) {
            final Iterable<Match> matches = _variableRegex.allMatches(item);
            final List<String> variables = matches.map((Match m) => m.group(1)!).toList();

            final List<String> parts = newPath.split('.');
            final String namespace = parts.first;
            final String key = parts.length > 1 ? '${parts.sublist(1).join('.')}.$i' : '$i';

            output.add(
              LocalizationKey(
                id: output.length + 1,
                namespace: namespace,
                key: key,
                variables: variables.isNotEmpty ? variables : null,
                defaultValueEn: item,
              ),
            );
          }
        }
      }
    }
  }
}
