import 'package:flutter/widgets.dart';

abstract final class RouteNavigatorKeys {
  static const String debugLabel = 'root';
  static final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>(debugLabel: debugLabel);
  static final GlobalKey<NavigatorState> mainHome = GlobalKey<NavigatorState>(debugLabel: 'main_home');
  static final GlobalKey<NavigatorState> home = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final GlobalKey<NavigatorState> mainMessage = GlobalKey<NavigatorState>(debugLabel: 'main_messages');
  static final GlobalKey<NavigatorState> message = GlobalKey<NavigatorState>(debugLabel: 'messages');
}
