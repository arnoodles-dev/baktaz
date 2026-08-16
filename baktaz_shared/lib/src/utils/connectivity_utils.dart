import 'dart:async';
import 'dart:io';

import 'package:baktaz_shared/src/entity/enum/connection_status.dart';
import 'package:baktaz_shared/src/extensions/int_ext.dart';
import 'package:baktaz_shared/src/extensions/status_code_ext.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

final class ConnectivityUtils {
  ConnectivityUtils._() : _testStream = null {
    _connectionSubscription = _connectivity.onConnectivityChanged
        .debounceTime(const Duration(milliseconds: 300))
        .listen((_) => _checkInternetConnection());
    _checkInternetConnection();
  }

  @visibleForTesting
  ConnectivityUtils.testing(this._testStream);

  static ConnectivityUtils get instance => _instance;

  @visibleForTesting
  static set instance(ConnectivityUtils value) => _instance = value;

  static ConnectivityUtils _instance = ConnectivityUtils._();

  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<ConnectionStatus> _controller = BehaviorSubject<ConnectionStatus>.seeded(
    ConnectionStatus.online,
  );
  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;
  ConnectionStatus _currentStatus = ConnectionStatus.online;
  final Stream<ConnectionStatus>? _testStream;

  bool get isConnected => _testStream != null || _currentStatus == ConnectionStatus.online;
  bool get isNotConnected => !isConnected;

  Stream<ConnectionStatus> get internetStatus => _testStream ?? _controller.stream;

  Future<void> _checkInternetConnection() async {
    final ConnectionStatus status = await checkInternet();
    _updateStatus(status);
  }

  static const String _defaultLookup = 'www.google.com';

  Future<ConnectionStatus> checkInternet({String lookupUrl = _defaultLookup}) async {
    try {
      final Either<List<InternetAddress>, http.Response> result = kIsWeb
          ? right(await http.get(Uri.parse(lookupUrl)))
          : left(await InternetAddress.lookup(lookupUrl));

      return await result.fold(
        (List<InternetAddress> mobile) => mobile.isNotEmpty && mobile.first.rawAddress.isNotEmpty
            ? ConnectionStatus.online
            : ConnectionStatus.offline,
        (http.Response web) => web.statusCode.statusCode.isSuccess ? ConnectionStatus.online : ConnectionStatus.offline,
      );
    } on SocketException {
      return ConnectionStatus.offline;
    }
  }

  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _controller.add(status);
    }
  }

  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    await _controller.close();
  }
}
