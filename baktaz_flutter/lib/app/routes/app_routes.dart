// ignore_for_file: prefer-match-file-name

import 'package:baktaz_flutter/app/routes/route_navigator_keys.dart';
import 'package:baktaz_flutter/core/domain/entity/enum/select_address_entry.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/app_update_screen.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/main_screen.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/maintenance_screen.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/onboarding_screen.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/select_address_screen.dart';
import 'package:baktaz_flutter/core/presentation/views/screens/splash_screen.dart';
import 'package:baktaz_flutter/features/account/domain/entity/enum/support_option.dart';
import 'package:baktaz_flutter/features/account/presentation/views/pages/account_page.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/address_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/contact_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/preference_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/profile_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/my_account/review_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/settings/dark_mode_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/settings/language_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/support/share_feedback_screen.dart';
import 'package:baktaz_flutter/features/account/presentation/views/screens/support/support_webview_screen.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/blocked_account_screen.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/login_email_screen.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/login_screen.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/otp_verification_screen.dart';
import 'package:baktaz_flutter/features/auth/presentation/views/registration_screen.dart';
import 'package:baktaz_flutter/features/challenge/presentation/views/pages/challenge_page.dart';
import 'package:baktaz_flutter/features/challenge/presentation/views/screens/challenge_history_screen.dart';
import 'package:baktaz_flutter/features/home/presentation/views/home_page.dart';
import 'package:baktaz_flutter/features/message/presentation/views/chat_page.dart';
import 'package:baktaz_flutter/features/message/presentation/views/message_page.dart';
import 'package:baktaz_flutter/features/message/presentation/views/notification_page.dart';
import 'package:baktaz_flutter/features/steps/presentation/views/steps_page.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

@TypedGoRoute<SplashRoute>(path: '/', name: 'splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<UpdateRoute>(path: '/update', name: 'update')
class UpdateRoute extends GoRouteData with $UpdateRoute {
  const UpdateRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const AppUpdateScreen();
}

@TypedGoRoute<MaintenanceRoute>(path: '/maintenance', name: 'maintenance')
class MaintenanceRoute extends GoRouteData with $MaintenanceRoute {
  const MaintenanceRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const MaintenanceScreen();
}

@TypedGoRoute<OnboardingRoute>(path: '/onboarding', name: 'onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const OnboardingScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login', name: 'login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<LoginEmailRoute>(path: '/loginEmail', name: 'loginEmail')
class LoginEmailRoute extends GoRouteData with $LoginEmailRoute {
  const LoginEmailRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginEmailScreen();
}

@TypedGoRoute<OtpRoute>(path: '/otp', name: 'otp')
class OtpRoute extends GoRouteData with $OtpRoute {
  const OtpRoute({required this.email});
  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => OtpVerificationScreen(email: email);
}

@TypedGoRoute<BlockedRoute>(path: '/blocked', name: 'blocked')
class BlockedRoute extends GoRouteData with $BlockedRoute {
  const BlockedRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const BlockedAccountScreen();
}

@TypedGoRoute<RegistrationRoute>(path: '/registration', name: 'registration')
class RegistrationRoute extends GoRouteData with $RegistrationRoute {
  const RegistrationRoute({required this.email, required this.registrationToken});
  final String email;
  final String registrationToken;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      RegistrationScreen(email: email, registrationToken: registrationToken);
}

@TypedGoRoute<SelectAddressRoute>(path: '/selectAddress', name: 'selectAddress')
class SelectAddressRoute extends GoRouteData with $SelectAddressRoute {
  const SelectAddressRoute({required this.$extra});
  final SelectAddressEntry $extra;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;

  @override
  Widget build(BuildContext context, GoRouterState state) => SelectAddressScreen(entryPoint: $extra);
}

@TypedStatefulShellRoute<MainShellRoute>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<HomeBranch>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<HomeRoute>(path: '/home', name: 'home')],
    ),
    TypedStatefulShellBranch<ChallengeBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChallengeRoute>(
          path: '/challenge',
          name: 'challenge',
          routes: <TypedRoute<RouteData>>[TypedGoRoute<HistoryRoute>(path: 'history', name: 'history')],
        ),
      ],
    ),
    TypedStatefulShellBranch<MessageBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedShellRoute<MessageShellRoute>(
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<ChatRoute>(path: '/chat', name: 'chat'),
            TypedGoRoute<NotificationRoute>(path: '/notifications', name: 'notifications'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<AccountBranch>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<AccountRoute>(
          path: '/account',
          name: 'account',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<ProfileRoute>(path: 'profile', name: 'profile'),
            TypedGoRoute<ContactRoute>(path: 'contact', name: 'contact'),
            TypedGoRoute<AddressRoute>(path: 'address', name: 'address'),
            TypedGoRoute<PreferenceRoute>(path: 'preference', name: 'preference'),
            TypedGoRoute<ReviewRoute>(path: 'review', name: 'review'),
            TypedGoRoute<HelpCenterRoute>(path: 'helpCenter', name: 'helpCenter'),
            TypedGoRoute<PrivacyPolicyRoute>(path: 'privacyPolicy', name: 'privacyPolicy'),
            TypedGoRoute<AboutUsRoute>(path: 'aboutUs', name: 'aboutUs'),
            TypedGoRoute<ShareFeedbackRoute>(path: 'shareFeedback', name: 'shareFeedback'),
            TypedGoRoute<LanguageRoute>(path: 'language', name: 'language'),
            TypedGoRoute<DarkModeRoute>(path: 'darkMode', name: 'darkMode'),
            TypedGoRoute<StepsAnalyticsRoute>(path: 'steps', name: 'steps'),
          ],
        ),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) =>
      MainScreen(navigationShell: navigationShell);
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
  static final GlobalKey<NavigatorState> $navigatorKey = RouteNavigatorKeys.mainHome;
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage(key: state.pageKey, child: const HomePage());
}

class ChallengeBranch extends StatefulShellBranchData {
  const ChallengeBranch();
  static final GlobalKey<NavigatorState> $navigatorKey = RouteNavigatorKeys.mainMessage;
}

class ChallengeRoute extends GoRouteData with $ChallengeRoute {
  const ChallengeRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage(key: state.pageKey, child: const ChallengePage());
}

class HistoryRoute extends GoRouteData with $HistoryRoute {
  const HistoryRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    transitionType: SlideTransitionType.rightToLeft,
    key: state.pageKey,
    fullscreenDialog: true,
    child: const ChallengeHistoryScreen(),
  );
}

class MessageBranch extends StatefulShellBranchData {
  const MessageBranch();
}

class MessageShellRoute extends ShellRouteData {
  const MessageShellRoute();
  static final GlobalKey<NavigatorState> $navigatorKey = RouteNavigatorKeys.message;
  @override
  Page<void> pageBuilder(BuildContext context, GoRouterState state, Widget navigator) => FadeTransitionPage(
    key: state.pageKey,
    child: MessagePage(child: navigator),
  );
}

class ChatRoute extends GoRouteData with $ChatRoute {
  const ChatRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(key: state.pageKey, transitionType: SlideTransitionType.leftToRight, child: const ChatPage());
}

class NotificationRoute extends GoRouteData with $NotificationRoute {
  const NotificationRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const NotificationPage(),
  );
}

class AccountBranch extends StatefulShellBranchData {
  const AccountBranch();
}

class AccountRoute extends GoRouteData with $AccountRoute {
  const AccountRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      FadeTransitionPage(key: state.pageKey, child: const AccountPage());
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const ProfileScreen(),
  );
}

class ContactRoute extends GoRouteData with $ContactRoute {
  const ContactRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const ContactScreen(),
  );
}

class AddressRoute extends GoRouteData with $AddressRoute {
  const AddressRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const AddressScreen(),
  );
}

class PreferenceRoute extends GoRouteData with $PreferenceRoute {
  const PreferenceRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const PreferenceScreen(),
  );
}

class ReviewRoute extends GoRouteData with $ReviewRoute {
  const ReviewRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    transitionType: SlideTransitionType.rightToLeft,
    child: const ReviewScreen(),
  );
}

class HelpCenterRoute extends GoRouteData with $HelpCenterRoute {
  const HelpCenterRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    child: const SupportWebviewScreen(option: SupportOption.helpCenter),
  );
}

class PrivacyPolicyRoute extends GoRouteData with $PrivacyPolicyRoute {
  const PrivacyPolicyRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    child: const SupportWebviewScreen(option: SupportOption.privacyPolicy),
  );
}

class AboutUsRoute extends GoRouteData with $AboutUsRoute {
  const AboutUsRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SlideTransitionPage(
    key: state.pageKey,
    child: const SupportWebviewScreen(option: SupportOption.aboutUs),
  );
}

class ShareFeedbackRoute extends GoRouteData with $ShareFeedbackRoute {
  const ShareFeedbackRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(key: state.pageKey, child: const ShareFeedbackScreen());
}

class LanguageRoute extends GoRouteData with $LanguageRoute {
  const LanguageRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(key: state.pageKey, child: const LanguageScreen());
}

class DarkModeRoute extends GoRouteData with $DarkModeRoute {
  const DarkModeRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(key: state.pageKey, child: const DarkModeScreen());
}

class StepsAnalyticsRoute extends GoRouteData with $StepsAnalyticsRoute {
  const StepsAnalyticsRoute();
  static final GlobalKey<NavigatorState> $parentNavigatorKey = RouteNavigatorKeys.root;
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      SlideTransitionPage(key: state.pageKey, child: const StepsPage());
}

abstract final class AppRoutes {
  static List<RouteBase> get routes => $appRoutes;
}
