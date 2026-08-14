import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:baktaz_admin/features/localization/domain/cubit/localization_state.dart';
import 'package:baktaz_admin/features/localization/domain/entity/enum/localization_sort_criteria.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_admin/features/localization/domain/interface/i_localization_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

@injectable
class LocalizationCubit extends Cubit<LocalizationState>
    with BlocPresentationMixin<LocalizationState, LocalizationPresentationEvent> {
  LocalizationCubit(this._repository) : super(const LocalizationState());
  final ILocalizationRepository _repository;

  Future<void> initialize() async {
    emit(state.copyWith(status: const QueryStatus.loading()));

    final Either<Failure, PaginatedResponse<LocalizationKey>> result = await _repository
        .getKeys(page: 1, limit: 1000, sortField: state.sortCriteria.name, ascending: state.ascending)
        .run();

    if (isClosed) {
      return;
    }

    result.fold(
      (Failure failure) {
        emit(state.copyWith(status: const QueryStatus.initial()));
        emitPresentation(
          OnInitializationError(
            failure.message ?? getIt<AppLocalizationCubit>().state.localization.errors.initialize_failed,
          ),
        );
      },
      (PaginatedResponse<LocalizationKey> paginatedResponse) {
        emit(state.copyWith(status: const QueryStatus.done(), keys: paginatedResponse.data));
      },
    );
  }

  void setPage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  void selectSortCriteria(LocalizationSortCriteria criteria) {
    emit(state.copyWith(sortCriteria: criteria));
  }

  void toggleSortOrder() {
    emit(state.copyWith(ascending: !state.ascending));
  }

  void updateTranslation(LocalizationTranslation translation) {
    final String key = '${translation.keyId}_${translation.locale}';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      state.pendingChanges,
    );
    newPending[key] = translation;
    emit(state.copyWith(pendingChanges: newPending));
  }

  void discardChanges() {
    emit(state.copyWith(pendingChanges: const <String, LocalizationTranslation>{}));
  }

  void selectLocale(String locale) {
    emit(state.copyWith(selectedLocale: locale));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleNamespace(String path) {
    final Set<String> newExpanded = Set<String>.of(state.expandedNamespaces);
    if (newExpanded.contains(path)) {
      newExpanded.remove(path);
    } else {
      newExpanded.add(path);
    }
    emit(state.copyWith(expandedNamespaces: newExpanded));
  }

  void clearExpanded() {
    emit(state.copyWith(expandedNamespaces: const <String>{}));
  }

  void addKey({required String key, required String namespace, required String defaultValueEn}) {
    final int nextId = state.keys.isEmpty
        ? 1
        : state.keys.map((LocalizationKey k) => k.id).fold(0, (int maxId, int id) => id > maxId ? id : maxId) + 1;
    final LocalizationKey newKey = LocalizationKey(
      id: nextId,
      namespace: namespace,
      key: key,
      defaultValueEn: defaultValueEn,
    );
    final List<LocalizationKey> newKeys = List<LocalizationKey>.of(state.keys)..add(newKey);

    final String translationKey = '${newKey.id}_en';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      state.pendingChanges,
    );
    newPending[translationKey] = LocalizationTranslation(keyId: newKey.id, locale: 'en', value: defaultValueEn);

    final Set<int> newAddedKeyIds = Set<int>.of(state.addedKeyIds)..add(newKey.id);

    emit(state.copyWith(keys: newKeys, pendingChanges: newPending, addedKeyIds: newAddedKeyIds));
  }

  void deleteTranslation(int keyId, String locale) {
    final String translationKey = '${keyId}_$locale';
    final Map<String, LocalizationTranslation> newPending = Map<String, LocalizationTranslation>.of(
      state.pendingChanges,
    );
    newPending[translationKey] = LocalizationTranslation(keyId: keyId, locale: locale, value: '');
    emit(state.copyWith(pendingChanges: newPending));
  }

  Future<void> publishChanges() async {
    emit(state.copyWith(status: const QueryStatus.loading()));

    final Either<Failure, Unit> result = await _repository
        .publishTranslations(state.pendingChanges.values.toList())
        .run();

    if (isClosed) {
      return;
    }

    result.fold(
      (Failure failure) {
        emit(state.copyWith(status: const QueryStatus.initial()));
        emitPresentation(
          OnPublishError(failure.message ?? getIt<AppLocalizationCubit>().state.localization.errors.publish_failed),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: const QueryStatus.done(),
            pendingChanges: const <String, LocalizationTranslation>{},
            addedKeyIds: const <int>{},
          ),
        );
        emitPresentation(const OnPublishSuccess());
      },
    );
  }
}
