import 'package:baktaz_shared/src/observer/talker_bloc_signal_settings.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:talker/talker.dart';

/// [Talker] observer implementation for [BlocSignalObserver].
class TalkerBlocSignalObserver extends BlocSignalObserver {
  const TalkerBlocSignalObserver({required this.talker, this.settings = const TalkerBlocSignalSettings()});

  final Talker talker;
  final TalkerBlocSignalSettings settings;

  @override
  void onCreate(BlocSignalBase<dynamic> bloc) {
    super.onCreate(bloc);
    talker.logCustom(TalkerLog('${bloc.runtimeType} created', title: 'BlocSignal'));
  }

  @override
  void onEvent(BlocSignalBase<dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (!settings.printEvent) return;
    talker.logCustom(TalkerLog('${bloc.runtimeType} event: $event', title: 'BlocSignal'));
  }

  @override
  void onTransition(BlocSignalBase<dynamic> bloc, Object? event, Object? state) {
    super.onTransition(bloc, event, state);
    if (!settings.printChange) return;
    talker.logCustom(
      TalkerLog('${bloc.runtimeType} transition event: $event, next state: $state', title: 'BlocSignal'),
    );
  }

  @override
  void onChange(BlocSignalBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (!settings.printChange) return;
    talker.logCustom(TalkerLog('${bloc.runtimeType} change: $change', title: 'BlocSignal'));
  }

  @override
  void onError(BlocSignalBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (!settings.printError) return;
    talker.logCustom(
      TalkerLog('${bloc.runtimeType} error: $error', title: 'BlocSignal', exception: error, stackTrace: stackTrace),
    );
  }

  @override
  void onClose(BlocSignalBase<dynamic> bloc) {
    super.onClose(bloc);
    if (!settings.printClose) return;
    talker.logCustom(TalkerLog('${bloc.runtimeType} closed', title: 'BlocSignal'));
  }
}
