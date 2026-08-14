import 'dart:async';

import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@lazySingleton
class RouteRefreshListener extends ChangeNotifier {
  RouteRefreshListener(this._authCubit) {
    notifyListeners();
    _authStreamSubscription = _authCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  final AuthCubit _authCubit;
  late final StreamSubscription<AuthState> _authStreamSubscription;

  @override
  void dispose() {
    unawaited(
      _authStreamSubscription.cancel().catchError((Object error, StackTrace stackTrace) {
        //TODO: add crashlytics implementation
        getIt<Talker>().handle(error, stackTrace);
      }),
    );
    super.dispose();
  }
}
