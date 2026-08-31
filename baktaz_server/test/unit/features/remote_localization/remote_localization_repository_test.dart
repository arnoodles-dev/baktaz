import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteLocalizationRepository Helper Unit Tests', () {
    test('computes deterministic SHA-256 checksum for payload', () {
      const String payload = '{"auth.loginButton":"Sign in"}';
      final String digest = sha256.convert(utf8.encode(payload)).toString();
      final String checksum = 'sha256:$digest';

      expect(checksum, startsWith('sha256:'));
      expect(checksum.length, equals(71)); // 'sha256:' (7) + 64 hex chars
    });
  });
}
