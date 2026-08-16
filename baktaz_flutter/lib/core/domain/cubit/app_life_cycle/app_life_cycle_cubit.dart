import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
// ignore: avoid_flutter_imports
import 'package:flutter/material.dart' show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

part 'app_life_cycle_cubit.freezed.dart';
part 'app_life_cycle_state.dart';

@lazySingleton
class AppLifeCycleCubit extends CubitSignal<AppLifeCycleState>
    with WidgetsBindingObserver {
  AppLifeCycleCubit(this._talker)
      : super(initialState: const AppLifeCycleState.resumed()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Talker _talker;

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);

    return super.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _talker.debug('AppLifeCycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        safeEmit(const AppLifeCycleState.resumed());
      case AppLifecycleState.paused:
        safeEmit(const AppLifeCycleState.paused());
      case AppLifecycleState.inactive:
        safeEmit(const AppLifeCycleState.inactive());
      case AppLifecycleState.detached:
        safeEmit(const AppLifeCycleState.detached());
      case AppLifecycleState.hidden:
        safeEmit(const AppLifeCycleState.hidden());
    }
  }
}
