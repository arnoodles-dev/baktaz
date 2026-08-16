import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_state.freezed.dart';

@freezed
abstract class LocalizationState with _$LocalizationState {
  const factory LocalizationState({
    @Default(QueryStatus.initial()) QueryStatus status,
    @Default(<LocalizationKey>[]) List<LocalizationKey> keys,
    @Default(<String, LocalizationTranslation>{}) Map<String, LocalizationTranslation> pendingChanges,
    @Default(1) int currentPage,
    @Default(10) int itemsPerPage,
    @Default(LocalizationSortCriteria.namespace) LocalizationSortCriteria sortCriteria,
    @Default(true) bool ascending,
    @Default('en') String selectedLocale,
    @Default(<String>['en', 'es', 'de']) List<String> locales,
    @Default(<String>{}) Set<String> expandedNamespaces,
    @Default('') String searchQuery,
    @Default(<int>{}) Set<int> addedKeyIds,
  }) = _LocalizationState;

  const LocalizationState._();

  List<LocalizationKey> get filteredKeys {
    if (searchQuery.trim().isEmpty) {
      return keys;
    }
    final String query = searchQuery.trim().toLowerCase();
    return keys.where((LocalizationKey k) {
      final String keyPath = '${k.namespace}.${k.key}'.toLowerCase();
      final String translationKey = '${k.id}_$selectedLocale';
      final String displayValue =
          (pendingChanges[translationKey]?.value ?? (selectedLocale == 'en' ? k.defaultValueEn : '')).toLowerCase();
      return keyPath.contains(query) || displayValue.contains(query);
    }).toList();
  }

  List<LocalizationKey> get sortedKeys =>
      List<LocalizationKey>.of(filteredKeys)..sort((LocalizationKey a, LocalizationKey b) {
        final int comparison = switch (sortCriteria) {
          LocalizationSortCriteria.key => a.key.compareTo(b.key),
          LocalizationSortCriteria.namespace => a.namespace.compareTo(b.namespace),
        };
        return ascending ? comparison : -comparison;
      });

  List<LocalizationKey> get paginatedKeys {
    final List<LocalizationKey> allKeys = sortedKeys;
    if (allKeys.isEmpty) {
      return <LocalizationKey>[];
    }

    if (sortCriteria == LocalizationSortCriteria.namespace) {
      final List<String> uniqueNamespaces = allKeys.map((LocalizationKey k) => k.namespace).toSet().toList();

      final int start = (currentPage - 1) * itemsPerPage;
      if (start >= uniqueNamespaces.length) {
        return <LocalizationKey>[];
      }
      final int end = (start + itemsPerPage).clamp(0, uniqueNamespaces.length);
      final List<String> paginatedNamespaces = uniqueNamespaces.sublist(start, end);

      return allKeys.where((LocalizationKey k) => paginatedNamespaces.contains(k.namespace)).toList();
    } else {
      final int start = (currentPage - 1) * itemsPerPage;
      if (start >= allKeys.length) {
        return <LocalizationKey>[];
      }
      final int end = (start + itemsPerPage).clamp(0, allKeys.length);
      return allKeys.sublist(start, end);
    }
  }

  int get totalItems {
    if (sortCriteria == LocalizationSortCriteria.namespace) {
      return filteredKeys.map((LocalizationKey k) => k.namespace).toSet().length;
    }
    return filteredKeys.length;
  }

  int get totalPages => (totalItems / itemsPerPage).ceil().clamp(1, double.infinity).toInt();

  int get startIndex => totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage;

  int get endIndex => (startIndex + itemsPerPage).clamp(0, totalItems);
}
