import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RouteRefreshListener extends ChangeNotifier {
  RouteRefreshListener(this._authCubit) {
    notifyListeners();
    _authDisposer = _authCubit.state.subscribe((_) {
      notifyListeners();
    });
  }

  final AuthCubit _authCubit;
  late final void Function() _authDisposer;

  @override
  void dispose() {
    _authDisposer();
    super.dispose();
  }
}
