import 'dart:io';

import 'package:baktaz_flutter/app/config/app_config.dart';
import 'package:baktaz_flutter/app/constants/trusted_certificate.dart';
import 'package:baktaz_flutter/app/helpers/injection/service_locator.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:chopper/chopper.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/io_client.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_chopper_logger/talker_chopper_logger.dart';

@lazySingleton
final class ChopperConfig {
  final List<ChopperService> _services = <ChopperService>[];

  final JsonSerializableConverter _converter = const JsonSerializableConverter(
    <Type, dynamic Function(Map<String, dynamic>)>{},
  );

  final List<Interceptor> _interceptors = <Interceptor>[
    const HeadersInterceptor(<String, String>{'Accept': 'application/json', 'Content-type': 'application/json'}),
    if (kDebugMode) getIt<TalkerChopperLogger>(),
    if (kDebugMode) CurlInterceptor(),
  ];

  /// SSL Pinning
  IOClient get _securedClient => IOClient(
    HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (AppConfig.environment == Env.staging || AppConfig.environment == Env.production) {
          final String hash = sha256.convert(cert.pem.codeUnits).toString();

          return TrustedCertificate.values.map((TrustedCertificate cert) => cert.value).toList().contains(hash);
        }

        return true;
      },
  );

  ChopperClient get client =>
      ChopperClient(client: _securedClient, interceptors: _interceptors, converter: _converter, services: _services);
}
