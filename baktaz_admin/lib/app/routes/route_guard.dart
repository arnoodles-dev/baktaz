import 'package:baktaz_admin/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class RouteGuard {
  RouteGuard(this._authCubit);

  static const String _dashboardLocation = '/dashboard';
  static const String _loginLocation = '/login';
  static const String _splashLocation = '/';

  final AuthCubit _authCubit;

  String? guard(BuildContext context, GoRouterState goRouterState) => _authCubit.stateValue.maybeWhen(
    initial: () => _splashLocation,
    unauthenticated: () => _loginLocation,
    authenticated: (_) => _authenticatedRouteGuard(goRouterState.matchedLocation),
    orElse: () => null,
  );

  String? _authenticatedRouteGuard(String matchedLocation) {
    final bool isLogin = matchedLocation == _loginLocation;
    final bool isSplash = matchedLocation == _splashLocation;
    return isLogin || isSplash ? _dashboardLocation : null;
  }
}
