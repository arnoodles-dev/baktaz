import 'package:baktaz_flutter/app/helpers/mixins/failure_handler.dart';
import 'package:baktaz_flutter/core/domain/interface/i_device_info_repository.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/account/domain/interface/i_account_repository.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'profile_cubit.freezed.dart';
part 'profile_state.dart';

@injectable
final class ProfileCubit extends CubitSignal<ProfileState> {
  ProfileCubit(this._accountRepository, this._deviceRepository, this._failureHandler)
    : super(initialState: ProfileState.initial());

  final IAccountRepository _accountRepository;
  final IDeviceInfoRepository _deviceRepository;
  final FailureHandler _failureHandler;

  Future<void> initialize() async {
    await safeRun(
      onException: _failureHandler.handleException,
      onLoading: (bool isLoading) {
        if (isLoading) {
          safeEmit(stateValue.copyWith(queryStatus: const QueryStatus.loading()));
        }
      },
      action: () async {
        final Result<String> appVersionResult = _deviceRepository.getAppVersion();
        final Result<String> buildNumberResult = _deviceRepository.getBuildNumber();

        if (buildNumberResult.isLeft()) {
          _failureHandler.handleFailure(buildNumberResult.asLeft());
          return;
        }
        if (appVersionResult.isLeft()) {
          _failureHandler.handleFailure(appVersionResult.asLeft());
          return;
        }

        safeEmit(stateValue.copyWith(appVersion: appVersionResult.asRight(), buildNumber: buildNumberResult.asRight()));

        final Result<Profile> profileResult = await _accountRepository.getProfile().run();

        profileResult.fold(_failureHandler.handleFailure, (Profile profile) {
          safeEmit(stateValue.copyWith(profile: profile, queryStatus: const QueryStatus.done()));
        });
      },
    );
  }
}
