import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:baktaz_flutter/core/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_flutter/features/auth/domain/cubit/auth/auth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
final class RouteGuard(
  final RemoteConfigCubit _remoteConfigBloc,
  final AppCoreCubit _appCoreBloc,
  final AuthCubit _authBloc,
) {
  String? guard(BuildContext context, GoRouterState goRouterState) {
    if (_remoteConfigBloc.isMaintenance) {
      return const MaintenanceRoute().location;
    }

    if (_remoteConfigBloc.isForceUpdate) {
      return const UpdateRoute().location;
    }

    final String matchedLocation = goRouterState.matchedLocation;
    final bool isMaintenancePath = matchedLocation == const MaintenanceRoute().location;
    final bool isUpdatePath = matchedLocation == const UpdateRoute().location;

    if ((isMaintenancePath || isUpdatePath) && (!_remoteConfigBloc.isMaintenance || !_remoteConfigBloc.isForceUpdate)) {
      return const SplashRoute().location;
    }

    return _authBloc.stateValue.map(
      initial: (_) => const SplashRoute().location,
      authenticated: (_) => _authenticatedRouteGuard(matchedLocation),
      unauthenticated: (_) => _unauthenticatedRouteGuard(matchedLocation),
    );
  }

  // Add Routes that is allowed to be unauthenticated
  bool _getAllowedUnauthenticatedRoutes(String location) =>
      location.startsWith('/registration') || location == '/loginMobile' || location == '/selectAddress';

  String? _unauthenticatedRouteGuard(String matchedLocation) {
    if (!_appCoreBloc.stateValue.isOnboardingDone) {
      return const OnboardingRoute().location;
    } else if (_getAllowedUnauthenticatedRoutes(matchedLocation)) {
      return null;
    } else {
      return const LoginRoute().location;
    }
  }

  String? _authenticatedRouteGuard(String matchedLocation) {
    final bool isLoginScreen = matchedLocation == const LoginRoute().location;
    final bool isSplashScreen = matchedLocation == const SplashRoute().location;

    return (isLoginScreen || isSplashScreen) ? const HomeRoute().location : null;
  }
}
