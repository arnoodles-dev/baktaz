import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'account_cubit.freezed.dart';
part 'account_state.dart';

/// Manages state and actions for the user account feature including account summary and deletion.
@injectable
final class AccountCubit extends CubitSignal<AccountState> {
  /// Constructs an [AccountCubit] and initializes account summary data.
  AccountCubit(this._accountRepository, this._failureHandler) : super(initialState: AccountState.initial()) {
    unawaited(initialize());
  }

  final IAccountRepository _accountRepository;
  final FailureHandler _failureHandler;

  /// Triggers account deletion for the current user.
  Future<void> deleteAccount() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        safeEmit(stateValue.copyWith(queryStatus: isLoading ? const QueryStatus.loading() : const QueryStatus.done()));
      },
      action: () async {
        final Result<Unit> possibleFailure = await _accountRepository.deleteAccount().run();
        possibleFailure.fold(
          (_) => safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.done())),
          (_) => safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.done())),
        );
      },
    );
  }

  /// Initializes grouped account options and fetches account summary details.
  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        safeEmit(stateValue.copyWith(queryStatus: isLoading ? const QueryStatus.loading() : const QueryStatus.done()));
      },
      action: () async {
        final List<String> accountMonetizationOptions = AccountHeader.accountMonetization.options;
        final List<String> preferencesSettingsOptions = AccountHeader.preferencesSettings.options;
        final List<String> supportLegalOptions = AccountHeader.supportLegal.options;

        safeEmit(
          stateValue.copyWith(
            groupedOptions: <AccountHeader, List<String>>{
              AccountHeader.accountMonetization: accountMonetizationOptions,
              AccountHeader.preferencesSettings: preferencesSettingsOptions,
              AccountHeader.supportLegal: supportLegalOptions,
            },
          ),
        );

        final Result<AccountSummary> possibleFailure = await _accountRepository.getAccountSummary().run();
        possibleFailure.fold(
          _failureHandler.handleFailure,
          (AccountSummary accountSummary) => safeEmit(stateValue.copyWith(accountSummary: accountSummary)),
        );
      },
    );
  }
}
