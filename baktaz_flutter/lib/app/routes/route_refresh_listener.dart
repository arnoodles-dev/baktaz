import 'dart:async';

import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RouteRefreshListener extends ChangeNotifier {
  RouteRefreshListener(this._authBloc, this._remoteConfigBloc) {
    notifyListeners();
    _authSubscription = _authBloc.stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
    _remoteConfigSubscription = _remoteConfigBloc.stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  final AuthCubit _authBloc;
  final RemoteConfigCubit _remoteConfigBloc;
  late final StreamSubscription<dynamic> _authSubscription;
  late final StreamSubscription<dynamic> _remoteConfigSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    _remoteConfigSubscription.cancel();
    super.dispose();
  }
}
