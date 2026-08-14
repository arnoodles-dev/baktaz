part of 'profile_cubit.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    required QueryStatus queryStatus,
    Profile? profile,
    String? appVersion,
    String? buildNumber,
  }) = _ProfileState;

  factory ProfileState.initial() => const _ProfileState(queryStatus: QueryStatus.loading());
}
