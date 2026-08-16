import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HidableCubit extends CubitSignal<bool> {
  HidableCubit() : super(initialState: true);

  void setVisibility({required bool isVisible}) => safeEmit(isVisible);
}
