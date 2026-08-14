part of 'remote_config_cubit.dart';

@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory RemoteConfigState({
    required QueryStatus status,
    RemoteConfig? remoteConfig,
    @Default(<String, RemoteConfigValue>{}) Map<String, RemoteConfigValue> pendingChanges,
    ConfigValueType? selectedType,
    @Default(1) int currentPage,
    @Default(SortCriteria.alphabetical) SortCriteria sortCriteria,
    @Default(true) bool isAscending,
  }) = _RemoteConfigState;

  factory RemoteConfigState.initial() => const _RemoteConfigState(status: QueryStatus.initial());

  const RemoteConfigState._();

  bool get hasPendingChanges => pendingChanges.isNotEmpty;

  // Business logic getters in Domain Layer

  Set<ConfigValueType> get availableTypes {
    final Map<String, RemoteConfigValue> parameters = remoteConfig?.parameters ?? const <String, RemoteConfigValue>{};
    final Set<String> allKeys = <String>{...parameters.keys, ...pendingChanges.keys};
    return allKeys.map((String key) => (pendingChanges[key] ?? parameters[key]!).valueType).toSet();
  }

  List<MapEntry<String, RemoteConfigValue>> get sortedParameters {
    final Map<String, RemoteConfigValue> parameters = remoteConfig?.parameters ?? const <String, RemoteConfigValue>{};
    final Set<String> allKeys = <String>{...parameters.keys, ...pendingChanges.keys};

    final List<MapEntry<String, RemoteConfigValue>> merged = allKeys.map((String key) {
      final RemoteConfigValue value = pendingChanges[key] ?? parameters[key]!;
      return MapEntry<String, RemoteConfigValue>(key, value);
    }).toList();

    return merged
        .where((MapEntry<String, RemoteConfigValue> e) => selectedType == null || e.value.valueType == selectedType)
        .toList()
      ..sort((MapEntry<String, RemoteConfigValue> a, MapEntry<String, RemoteConfigValue> b) {
        int cmp;
        switch (sortCriteria) {
          case SortCriteria.alphabetical:
            cmp = a.key.compareTo(b.key);
          case SortCriteria.type:
            cmp = a.value.valueType.name.compareTo(b.value.valueType.name);
          case SortCriteria.dateModified:
            final DateTime dateA = a.value.lastModified ?? DateTime.now();
            final DateTime dateB = b.value.lastModified ?? DateTime.now();
            cmp = dateA.compareTo(dateB);
        }
        return isAscending ? cmp : -cmp;
      });
  }

  List<MapEntry<String, RemoteConfigValue>> get paginatedParameters {
    final List<MapEntry<String, RemoteConfigValue>> sorted = sortedParameters;
    final int start = (currentPage - 1) * 10;
    if (start >= sorted.length) {
      return const <MapEntry<String, RemoteConfigValue>>[];
    }
    final int end = (start + 10).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  int get totalItems => sortedParameters.length;
  int get totalPages => totalItems == 0 ? 1 : (totalItems / 10).ceil();
  int get startIndex => (currentPage - 1) * 10;
  int get endIndex => (startIndex + paginatedParameters.length).clamp(0, totalItems);

  int get totalParametersCount {
    final Map<String, RemoteConfigValue> parameters = remoteConfig?.parameters ?? const <String, RemoteConfigValue>{};
    return <String>{...parameters.keys, ...pendingChanges.keys}.length;
  }
}

@freezed
sealed class RemoteConfigPresentationEvent with _$RemoteConfigPresentationEvent {
  const factory RemoteConfigPresentationEvent.onPublishSuccess() = _RemoteConfigPublishSuccess;
  const factory RemoteConfigPresentationEvent.showLoader() = _ShowLoader;
  const factory RemoteConfigPresentationEvent.hideLoader() = _HideLoader;
}
