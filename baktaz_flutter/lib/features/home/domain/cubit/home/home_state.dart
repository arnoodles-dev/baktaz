part of 'home_cubit.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    required QueryStatus queryStatus,
    required List<String>? contentList,
    Profile? profile,
    Address? address,
    Map<String, dynamic>? homeContent,
  }) = _HomeState;

  const HomeState._();

  factory HomeState.initial() => const _HomeState(contentList: <String>[], queryStatus: QueryStatus.loading());
}

@freezed
sealed class HomeStateSideEffect with _$HomeStateSideEffect {
  const factory HomeStateSideEffect.onException(Exception exception) = HomeStateException;
  const factory HomeStateSideEffect.initializeAddress() = HomeStateInitializeAddress;
}
