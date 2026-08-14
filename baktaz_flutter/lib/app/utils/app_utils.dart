import 'dart:io';

import 'package:baktaz_flutter/app/themes/app_theme.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class AppUtils {
  AppUtils._();

  static void closeApp() {
    if (defaultTargetPlatform case TargetPlatform.android) {
      SystemNavigator.pop();
    } else if (defaultTargetPlatform case TargetPlatform.iOS) {
      exit(0);
    }
  }

  static bool isSliverAppBarExpanded(ScrollController scrollController, {double? appBarHeight}) =>
      scrollController.hasClients && scrollController.offset < (appBarHeight ?? AppTheme.defaultAppBarHeight);
}
