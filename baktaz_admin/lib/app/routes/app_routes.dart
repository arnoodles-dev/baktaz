// ignore_for_file: prefer-match-file-name

import 'package:baktaz_admin/core/presentation/views/splash_screen.dart';
import 'package:baktaz_admin/features/auth/presentation/views/login_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

// ---------------------------------------------------------------------------
// Top-level typed route declarations consumed by go_router_builder.
// ---------------------------------------------------------------------------

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}
