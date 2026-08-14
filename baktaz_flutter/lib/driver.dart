// This file is never meant to be used on real apps, just for development.
import 'package:baktaz_flutter/main.dart' as app;
import 'package:flutter_driver/driver_extension.dart';

void main() {
  enableFlutterDriverExtension(
    // Text entry emulation is disabled by default to allow manual usage of the
    // app, but will be required for agents to type through the app. Set this
    // parameter to true to switch from manual to automated usage.
    enableTextEntryEmulation: false,
  );
  app.main();
}
