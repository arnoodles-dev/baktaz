import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/my_account_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/settings_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'account_cubit.freezed.dart';
part 'account_state.dart';

@injectable
interface class AccountCubit extends CubitSignal<AccountState> {
  AccountCubit(
    this._accountRepository,
    this._failureHandler,
  ) : super(initialState: AccountState.initial()) {
    unawaited(initialize());
  }

  final IAccountRepository _accountRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        safeEmit(stateValue.copyWith(queryStatus: isLoading ? const QueryStatus.loading() : const QueryStatus.done()));
      },
      action: () async {
        safeEmit(
          stateValue.copyWith(
            groupedOptions: <AccountHeader, List<String>>{
              AccountHeader.myAccount: MyAccountOption.values.map((MyAccountOption option) => option.name).toList(),
              AccountHeader.support: SupportOption.values.map((SupportOption option) => option.name).toList(),
              AccountHeader.settings: SettingsOption.values.map((SettingsOption option) => option.name).toList(),
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
