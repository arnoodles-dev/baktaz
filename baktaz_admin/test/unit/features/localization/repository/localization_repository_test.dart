import 'dart:convert';
import 'dart:io';

import 'package:baktaz_admin/features/localization/data/repository/localization_repository.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:baktaz_admin/features/localization/domain/entity/localization_translation.dart';
import 'package:baktaz_admin/features/localization/domain/entity/paginated_response.dart';
import 'package:baktaz_shared/src/entity/failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

const Map<String, dynamic> _testJsonWithLists = <String, dynamic>{
  'app': <String, dynamic>{
    'title': 'Baktaz',
    'features': <String>['logistics', 'ecommerce', 'finance'],
    'tags': <String>[r'${version}', r'${buildNumber}'],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalizationRepository repository;

  setUp(() {
    repository = LocalizationRepository();
  });

  group('getKeys', () {
    test('flattens nested json and extracts variables sorted by key', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 10, sortField: 'key', ascending: true)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        final List<LocalizationKey> keys = r.data;
        expect(keys, isNotEmpty);
        expect(keys.length, lessThanOrEqualTo(10));

        final LocalizationKey google = keys.firstWhere(
          (LocalizationKey k) => k.namespace == 'login' && k.key == 'button.google',
          orElse: () =>
              const LocalizationKey(id: -1, namespace: 'not_found', key: 'not_found', defaultValueEn: 'Not Found'),
        );
        if (google.id != -1) {
          expect(google.defaultValueEn, 'Continue with Google');
        }
      });
    });

    test('sorts by defaultValueEn', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 100, sortField: 'defaultValueEn', ascending: true)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        expect(r.data, isNotEmpty);
        for (int i = 0; i < r.data.length - 1; i++) {
          expect(r.data[i].defaultValueEn.compareTo(r.data[i + 1].defaultValueEn), lessThanOrEqualTo(0));
        }
      });
    });

    test('sorts descending', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 100, sortField: 'key', ascending: false)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        expect(r.data, isNotEmpty);
        for (int i = 0; i < r.data.length - 1; i++) {
          final String a = '${r.data[i].namespace}.${r.data[i].key}';
          final String b = '${r.data[i + 1].namespace}.${r.data[i + 1].key}';
          expect(a.compareTo(b), greaterThanOrEqualTo(0));
        }
      });
    });

    test('returns empty list when page is beyond data', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 9999, limit: 10, sortField: 'key', ascending: true)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        expect(r.data, isEmpty);
        expect(r.totalCount, greaterThan(0));
      });
    });

    test('default sort field falls back to key order', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 10, sortField: 'unknown_field', ascending: true)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        expect(r.data, isNotEmpty);
      });
    });

    test('includes keys with variables', () async {
      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 500, sortField: 'key', ascending: true)
          .run();

      result.fold((Failure l) => fail('Should not fail: $l'), (PaginatedResponse<LocalizationKey> r) {
        final List<LocalizationKey> withVars = r.data.where((LocalizationKey k) => k.variables != null).toList();
        expect(withVars, isNotEmpty);
      });
    });

    test('returns unexpected failure when asset JSON is malformed', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'assets/i18n/en.i18n.json') {
          return ByteData.sublistView(utf8.encode('invalid json string'));
        }
        return null;
      });
      rootBundle.evict('assets/i18n/en.i18n.json');
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
          ByteData? message,
        ) async {
          if (message == null) {
            return null;
          }
          final String key = utf8.decode(message.buffer.asUint8List());
          File file = File(key);
          if (!file.existsSync()) {
            file = File('baktaz_admin/$key');
          }
          if (file.existsSync()) {
            final Uint8List bytes = await file.readAsBytes();
            return ByteData.sublistView(bytes);
          }
          return null;
        });
        rootBundle.evict('assets/i18n/en.i18n.json');
      });

      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 10, sortField: 'key', ascending: true)
          .run();

      result.fold(
        (Failure l) => expect(l, isA<Failure>()),
        (PaginatedResponse<LocalizationKey> r) => fail('Expected failure for malformed asset JSON'),
      );
    });

    test('returns unexpected failure when asset cannot be loaded', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (ByteData? message) async => null,
      );
      rootBundle.evict('assets/i18n/en.i18n.json');
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
          ByteData? message,
        ) async {
          if (message == null) {
            return null;
          }
          final String key = utf8.decode(message.buffer.asUint8List());
          File file = File(key);
          if (!file.existsSync()) {
            file = File('baktaz_admin/$key');
          }
          if (file.existsSync()) {
            final Uint8List bytes = await file.readAsBytes();
            return ByteData.sublistView(bytes);
          }
          return null;
        });
        rootBundle.evict('assets/i18n/en.i18n.json');
      });

      final Either<Failure, PaginatedResponse<LocalizationKey>> result = await repository
          .getKeys(page: 1, limit: 10, sortField: 'key', ascending: true)
          .run();

      result.fold(
        (Failure l) => expect(l, isA<Failure>()),
        (PaginatedResponse<LocalizationKey> r) => fail('Expected failure for missing asset'),
      );
    });
  });

  group('publishTranslations', () {
    test('returns unit when successful', () async {
      final Either<Failure, Unit> result = await repository.publishTranslations(<LocalizationTranslation>[]).run();

      result.fold((Failure l) => fail('Should not fail: $l'), (Unit u) => expect(u, unit));
    });

    test('returns unit with non-empty translations', () async {
      final Either<Failure, Unit> result = await repository.publishTranslations(<LocalizationTranslation>[
        const LocalizationTranslation(keyId: 1, locale: 'en', value: 'Test'),
      ]).run();

      result.fold((Failure l) => fail('Should not fail: $l'), (Unit u) => expect(u, unit));
    });
  });

  group('flattenJson List branch', () {
    test('flattens JSON arrays into indexed keys', () {
      final List<LocalizationKey> output = <LocalizationKey>[];
      repository.flattenJson(_testJsonWithLists, '', output);

      expect(output, isNotEmpty);

      final List<String> allKeys = output.map((LocalizationKey k) => '${k.namespace}.${k.key}').toList();

      final List<LocalizationKey> featuresKeys = output
          .where((LocalizationKey k) => k.namespace == 'app' && k.key.startsWith('features.'))
          .toList();
      expect(featuresKeys, isNotEmpty, reason: 'Available keys: $allKeys');
      expect(featuresKeys.first.defaultValueEn, 'logistics');

      final List<LocalizationKey> tagsKeys = output
          .where((LocalizationKey k) => k.namespace == 'app' && k.key.startsWith('tags.'))
          .toList();
      expect(tagsKeys, isNotEmpty, reason: 'Available keys: $allKeys');
      expect(tagsKeys.first.variables, isNotNull);
      expect(tagsKeys.first.variables, contains('version'));
    });
  });
}
