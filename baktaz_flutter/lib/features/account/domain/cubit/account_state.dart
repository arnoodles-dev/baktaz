part of 'account_cubit.dart';

@freezed
sealed class AccountState with _$AccountState {
  const factory AccountState({
    required QueryStatus queryStatus,
    required Map<AccountHeader, List<String>> groupedOptions,
    AccountSummary? accountSummary,
  }) = _AccountState;

  factory AccountState.initial() =>
      const _AccountState(groupedOptions: <AccountHeader, List<String>>{}, queryStatus: QueryStatus.loading());
}
