part of 'app_core_cubit.dart';

@freezed
sealed class AppCoreState with _$AppCoreState {
  const factory AppCoreState({required bool isOnboardingDone}) = _AppCoreState;

  factory AppCoreState.initial() => const _AppCoreState(isOnboardingDone: false);
}
