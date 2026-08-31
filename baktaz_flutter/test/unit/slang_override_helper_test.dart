import 'package:baktaz_flutter/app/generated/localization.g.dart';
import 'package:baktaz_flutter/app/utils/slang_override_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(SlangOverrideHelper, () {
    group('parseOverridesJson', () {
      test('returns empty map when json is null or empty', () {
        expect(SlangOverrideHelper.parseOverridesJson(null), isEmpty);
        expect(SlangOverrideHelper.parseOverridesJson(''), isEmpty);
        expect(SlangOverrideHelper.parseOverridesJson('   '), isEmpty);
      });

      test('returns empty map when json is malformed', () {
        expect(SlangOverrideHelper.parseOverridesJson('{invalid json}'), isEmpty);
      });

      test('returns empty map when json root is not a map', () {
        expect(SlangOverrideHelper.parseOverridesJson('["a", "b"]'), isEmpty);
        expect(SlangOverrideHelper.parseOverridesJson('"string"'), isEmpty);
      });

      test('returns parsed map when valid JSON map is provided', () {
        const String jsonStr = '{"common.error.generic":"Custom Error","auth.loginButton":"Sign In Now"}';
        final Map<String, dynamic> result = SlangOverrideHelper.parseOverridesJson(jsonStr);

        expect(result, <String, dynamic>{
          'common.error.generic': 'Custom Error',
          'auth.loginButton': 'Sign In Now',
        });
      });
    });

    group('applyOverridesJson', () {
      test('returns base I18n instance when json is null or empty', () {
        final I18n i18nNull = SlangOverrideHelper.applyOverridesJson(
          jsonContent: null,
          locale: AppLocale.en,
        );
        expect(i18nNull, isA<I18n>());

        final I18n i18nEmpty = SlangOverrideHelper.applyOverridesJson(
          jsonContent: '',
          locale: AppLocale.en,
        );
        expect(i18nEmpty, isA<I18n>());
      });

      test('returns base I18n instance when json is malformed', () {
        final I18n i18n = SlangOverrideHelper.applyOverridesJson(
          jsonContent: '{malformed json}',
          locale: AppLocale.en,
        );
        expect(i18n, isA<I18n>());
      });

      test('returns overridden I18n instance when valid override JSON string is provided', () {
        const String jsonStr = '{"common.error.generic":"Custom Error Message"}';
        final I18n i18n = SlangOverrideHelper.applyOverridesJson(
          jsonContent: jsonStr,
          locale: AppLocale.en,
        );

        expect(i18n, isA<I18n>());
        expect(i18n.common.error.generic, equals('Custom Error Message'));
      });
    });

    group('applyOverridesMap', () {
      test('returns base I18n instance when map is empty', () {
        final I18n i18n = SlangOverrideHelper.applyOverridesMap(
          map: <String, dynamic>{},
          locale: AppLocale.en,
        );
        expect(i18n, isA<I18n>());
      });

      test('returns overridden I18n instance when valid flat map is provided', () {
        final Map<String, dynamic> map = <String, dynamic>{
          'common.error.generic': 'Flat Map Error',
        };
        final I18n i18n = SlangOverrideHelper.applyOverridesMap(
          map: map,
          locale: AppLocale.en,
        );

        expect(i18n, isA<I18n>());
        expect(i18n.common.error.generic, equals('Flat Map Error'));
      });
    });
  });
}
