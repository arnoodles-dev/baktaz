import 'dart:async';

import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

@injectable
class HomeCubit extends CubitSignal<HomeState> {
  HomeCubit(this._accountRepository, this._failureHandler) : super(initialState: HomeState.initial()) {
    unawaited(initialize());
  }

  final IAccountRepository _accountRepository;
  final FailureHandler _failureHandler;

  final StreamController<HomeStateSideEffect> _sideEffectController = StreamController<HomeStateSideEffect>.broadcast();

  Stream<HomeStateSideEffect> get sideEffectStream => _sideEffectController.stream;

  void safeEmitPresentation(HomeStateSideEffect sideEffect) {
    if (isClosed) return;
    _sideEffectController.add(sideEffect);
  }

  @override
  Future<void> close() {
    _sideEffectController.close();
    return super.close();
  }

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) => isLoading
          ? safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.loading()))
          : safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.done())),
      action: () async {
        final Result<Address?> possibleAddressFailure = await _accountRepository.getDefaultAddress().run();

        possibleAddressFailure.fold(_emitFailure, (Address? address) {
          if (address == null) {
            safeEmitPresentation(const HomeStateSideEffect.initializeAddress());
          } else {
            safeEmit(stateValue.copyWith(address: address));
          }
        });
        final Result<Profile> possibleProfileFailure = await _accountRepository.getProfile().run();
        possibleProfileFailure.fold(_emitFailure, (Profile profile) => safeEmit(stateValue.copyWith(profile: profile)));
      },
    );
  }

  void _emitFailure(Failure failure) {
    _failureHandler.handleFailure(failure);
    safeEmitPresentation(HomeStateException(Exception(failure.message)));
  }
}
