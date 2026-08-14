import 'dart:async';

import 'package:flutter/services.dart';

final class AppUtils {
  AppUtils._();

  static void closeApp() {
    unawaited(SystemNavigator.pop());
  }
}
