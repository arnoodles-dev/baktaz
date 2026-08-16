import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RouteRefreshListener extends ChangeNotifier {
  RouteRefreshListener(this._authBloc, this._remoteConfigBloc) {
    notifyListeners();
    _authDispose = _authBloc.state.subscribe((_) => notifyListeners());
    _remoteConfigDispose = _remoteConfigBloc.state.subscribe((_) => notifyListeners());
  }

  final AuthCubit _authBloc;
  final RemoteConfigCubit _remoteConfigBloc;
  late final void Function() _authDispose;
  late final void Function() _remoteConfigDispose;

  @override
  void dispose() {
    _authDispose();
    _remoteConfigDispose();
    super.dispose();
  }
}
