import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/app/routes/app_routes.dart';
import 'package:baktaz_admin/app/routes/route_guard.dart';
import 'package:baktaz_admin/app/routes/route_navigator_keys.dart';
import 'package:baktaz_admin/app/routes/route_refresh_listener.dart';
import 'package:baktaz_admin/core/presentation/views/main_screen.dart';
import 'package:baktaz_admin/features/content/presentation/views/content_screen.dart';
import 'package:baktaz_admin/features/dashboard/presentation/views/dashboard_screen.dart';
import 'package:baktaz_admin/features/localization/presentation/views/localization_screen.dart';
import 'package:baktaz_admin/features/remote_config/presentation/views/remote_config_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      ...$appRoutes,
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) => MainScreen(child: child),
        routes: <RouteBase>[
          GoRoute(path: '/dashboard', builder: (BuildContext context, GoRouterState state) => const DashboardScreen()),
          GoRoute(path: '/users', builder: (_, _) => const Placeholder()),
          GoRoute(path: '/config', builder: (_, _) => const RemoteConfigScreen()),
          GoRoute(path: '/localization', builder: (_, _) => const LocalizationScreen()),
          GoRoute(path: '/activities', builder: (_, _) => const Placeholder()),
          GoRoute(path: '/sales', builder: (_, _) => const Placeholder()),
          GoRoute(path: '/analytics', builder: (_, _) => const Placeholder()),
          GoRoute(path: '/reports', builder: (_, _) => const Placeholder()),
          GoRoute(path: '/content', builder: (BuildContext context, GoRouterState state) => const ContentScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const Placeholder()),
        ],
      ),
    ],
    redirect: getIt<RouteGuard>().guard,
    refreshListenable: getIt<RouteRefreshListener>(),
    initialLocation: const SplashRoute().location,
    observers: <NavigatorObserver>[getIt<TalkerRouteObserver>()],
    navigatorKey: RouteNavigatorKeys.root,
  );
}
