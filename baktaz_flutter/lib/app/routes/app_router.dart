import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_flutter/app/routes/app_routes.dart';
import 'package:baktaz_flutter/app/routes/route_guard.dart';
import 'package:baktaz_flutter/app/routes/route_navigator_keys.dart';
import 'package:baktaz_flutter/app/routes/route_refresh_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    routes: AppRoutes.routes,
    redirect: getIt<RouteGuard>().guard,
    refreshListenable: getIt<RouteRefreshListener>(),
    initialLocation: const SplashRoute().location,
    observers: <NavigatorObserver>[getIt<TalkerRouteObserver>()],
    navigatorKey: RouteNavigatorKeys.root,
  );
}
