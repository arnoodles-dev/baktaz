import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/account_header.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/my_account_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/settings_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/account_summary.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AccountCubit, () {
    late MockIAccountRepository accountRepository;
    late MockFailureHandler failureHandler;

    final Map<AccountHeader, List<String>> expectedGroupedOptions = <AccountHeader, List<String>>{
      AccountHeader.myAccount: MyAccountOption.values.map((MyAccountOption option) => option.name).toList(),
      AccountHeader.support: SupportOption.values.map((SupportOption option) => option.name).toList(),
      AccountHeader.settings: SettingsOption.values.map((SettingsOption option) => option.name).toList(),
    };

    setUp(() {
      accountRepository = MockIAccountRepository();
      failureHandler = MockFailureHandler();

      provideDummy<TaskResult<AccountSummary>>(TaskResult<AccountSummary>.right(mockAccountSummary));
    });

    tearDown(() {
      reset(accountRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      blocSignalTest<AccountCubit, AccountState>(
        'should initialize with grouped options and fetch account summary successfully',
        build: () {
          when(accountRepository.getAccountSummary()).thenReturn(TaskResult<AccountSummary>.right(mockAccountSummary));
          return AccountCubit(accountRepository, failureHandler);
        },
        act: (AccountCubit cubit) => cubit.initialize(),
        expect: () => <AccountState>[
          AccountState(
            queryStatus: const QueryStatus.loading(),
            groupedOptions: expectedGroupedOptions,
            accountSummary: mockAccountSummary,
          ),
          AccountState(
            queryStatus: const QueryStatus.done(),
            groupedOptions: expectedGroupedOptions,
            accountSummary: mockAccountSummary,
          ),
        ],
        verify: (_) {
          verify(accountRepository.getAccountSummary()).called(2);
        },
      );

      blocSignalTest<AccountCubit, AccountState>(
        'should handle failure when fetching account summary fails',
        build: () {
          const Failure failure = Failure.server(StatusCode.serverpod, 'Failed to load summary');
          when(accountRepository.getAccountSummary()).thenReturn(TaskResult<AccountSummary>.left(failure));
          return AccountCubit(accountRepository, failureHandler);
        },
        act: (AccountCubit cubit) => cubit.initialize(),
        expect: () => <AccountState>[
          AccountState(queryStatus: const QueryStatus.done(), groupedOptions: expectedGroupedOptions),
        ],
        verify: (_) {
          verify(accountRepository.getAccountSummary()).called(2);
          verify(failureHandler.handleFailure(any)).called(2);
        },
      );

      blocSignalTest<AccountCubit, AccountState>(
        'should handle unexpected exception during initialization',
        build: () {
          final Exception exception = Exception('Connection timeout');
          when(accountRepository.getAccountSummary()).thenThrow(exception);
          return AccountCubit(accountRepository, failureHandler);
        },
        act: (AccountCubit cubit) => cubit.initialize(),
        expect: () => <AccountState>[
          AccountState(queryStatus: const QueryStatus.done(), groupedOptions: expectedGroupedOptions),
        ],
        verify: (_) {
          verify(accountRepository.getAccountSummary()).called(2);
          verify(failureHandler.handleException(any, any)).called(2);
        },
      );
    });
  });
}
