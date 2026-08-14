import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HidableCubit extends Cubit<bool> {
  HidableCubit() : super(true);

  void setVisibility({required bool isVisible}) => safeEmit(isVisible);
}
