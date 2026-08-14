import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> with BlocPresentationMixin<HomeState, HomeStateSideEffect> {
  HomeCubit(this._accountRepository, this._failureHandler) : super(HomeState.initial()) {
    initialize();
  }

  final IAccountRepository _accountRepository;

  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) => isLoading
          ? safeEmit(state.copyWith(queryStatus: const QueryStatus.loading()))
          : safeEmit(state.copyWith(queryStatus: const QueryStatus.done())),
      action: () async {
        final Result<Address?> possibleAddressFailure = await _accountRepository.getDefaultAddress().run();

        possibleAddressFailure.fold(_emitFailure, (Address? address) {
          if (address == null) {
            safeEmitPresentation(const HomeStateSideEffect.initializeAddress());
          } else {
            safeEmit(state.copyWith(address: address));
          }
        });
        final Result<Profile> possibleProfileFailure = await _accountRepository.getProfile().run();
        possibleProfileFailure.fold(_emitFailure, (Profile profile) => safeEmit(state.copyWith(profile: profile)));
      },
    );
  }

  void _emitFailure(Failure failure) {
    _failureHandler.handleFailure(failure);
    safeEmitPresentation(HomeStateException(Exception(failure.message)));
  }
}
