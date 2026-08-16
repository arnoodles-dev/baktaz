import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_admin/features/localization/domain/interface/i_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@injectable
class LocalizationCubit extends CubitSignal<LocalizationState> {
  LocalizationCubit(
    this._repository, {
    super.initialState = const LocalizationState(),
  });

  @visibleForTesting
  LocalizationCubit.test(ILocalizationRepository repository, LocalizationState initialState)
    : this(repository, initialState: initialState);

  final ILocalizationRepository _repository;

  Future<void> initialize() async {
    safeEmit(stateValue.copyWith(status: const QueryStatus.loading()));

    final Either<Failure, PaginatedResponse<LocalizationKey>> result = await _repository
        .getKeys(page: 1, limit: 1000, sortField: stateValue.sortCriteria.name, ascending: stateValue.ascending)
        .run();

    if (isClosed) {
      return;
    }

    result.fold(
      (Failure failure) {
        safeEmit(stateValue.copyWith(status: const QueryStatus.initial()));
      },
      (PaginatedResponse<LocalizationKey> paginatedResponse) {
        safeEmit(stateValue.copyWith(status: const QueryStatus.done(), keys: paginatedResponse.data));
      },
    );
  }

  void setPage(int page) {
    safeEmit(stateValue.copyWith(currentPage: page));
  }

  void selectSortCriteria(LocalizationSortCriteria criteria) {
    safeEmit(stateValue.copyWith(sortCriteria: criteria));
  }

  void toggleSortOrder() {
    safeEmit(stateValue.copyWith(ascending: !stateValue.ascending));
  }

  void updateTranslation(LocalizationTranslation translation) {
    final String key = '${translation.keyId}_${translation.locale}';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      stateValue.pendingChanges,
    );
    newPending[key] = translation;
    safeEmit(stateValue.copyWith(pendingChanges: newPending));
  }

  void discardChanges() {
    safeEmit(stateValue.copyWith(pendingChanges: const <String, LocalizationTranslation>{}));
  }

  void selectLocale(String locale) {
    safeEmit(stateValue.copyWith(selectedLocale: locale));
  }

  void setSearchQuery(String query) {
    safeEmit(stateValue.copyWith(searchQuery: query));
  }

  void toggleNamespace(String path) {
    final Set<String> newExpanded = Set<String>.of(stateValue.expandedNamespaces);
    if (newExpanded.contains(path)) {
      newExpanded.remove(path);
    } else {
      newExpanded.add(path);
    }
    safeEmit(stateValue.copyWith(expandedNamespaces: newExpanded));
  }

  void clearExpanded() {
    safeEmit(stateValue.copyWith(expandedNamespaces: const <String>{}));
  }

  void addKey({required String key, required String namespace, required String defaultValueEn}) {
    final int nextId = stateValue.keys.isEmpty
        ? 1
        : stateValue.keys.map((LocalizationKey k) => k.id).fold(0, (int maxId, int id) => id > maxId ? id : maxId) + 1;
    final LocalizationKey newKey = LocalizationKey(
      id: nextId,
      namespace: namespace,
      key: key,
      defaultValueEn: defaultValueEn,
    );
    final List<LocalizationKey> newKeys = List<LocalizationKey>.of(stateValue.keys)..add(newKey);

    final String translationKey = '${newKey.id}_en';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      stateValue.pendingChanges,
    );
    newPending[translationKey] = LocalizationTranslation(keyId: newKey.id, locale: 'en', value: defaultValueEn);

    final Set<int> newAddedKeyIds = Set<int>.of(stateValue.addedKeyIds)..add(newKey.id);

    safeEmit(stateValue.copyWith(keys: newKeys, pendingChanges: newPending, addedKeyIds: newAddedKeyIds));
  }

  void deleteTranslation(int keyId, String locale) {
    final String translationKey = '${keyId}_$locale';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      stateValue.pendingChanges,
    );
    newPending[translationKey] = LocalizationTranslation(keyId: keyId, locale: locale, value: '');
    safeEmit(stateValue.copyWith(pendingChanges: newPending));
  }

  Future<void> publishChanges() async {
    safeEmit(stateValue.copyWith(status: const QueryStatus.loading()));

    final Either<Failure, Unit> result = await _repository
        .publishTranslations(stateValue.pendingChanges.values.toList())
        .run();

    if (isClosed) {
      return;
    }

    result.fold(
      (Failure failure) {
        safeEmit(stateValue.copyWith(status: const QueryStatus.initial()));
      },
      (_) {
        safeEmit(
          stateValue.copyWith(
            status: const QueryStatus.done(),
            pendingChanges: const <String, LocalizationTranslation>{},
            addedKeyIds: const <int>{},
          ),
        );
      },
    );
  }
}
