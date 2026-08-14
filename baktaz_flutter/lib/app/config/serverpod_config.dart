// ignore_for_file: prefer-match-file-name

import 'package:baktaz_client/baktaz_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

class Serverpod {
  late Client client;
  late FlutterAuthSessionManager sessionManager;

  Future<void> initialize({required String serverpodUrl}) async {
    sessionManager = FlutterAuthSessionManager();
    client = Client(serverpodUrl)
      ..authSessionManager = sessionManager
      ..connectivityMonitor = FlutterConnectivityMonitor();

    await sessionManager.initialize();
  }
}
