import 'package:baktaz_admin/app/generated/localization.g.dart';
import 'package:baktaz_admin/core/domain/cubit/app_localization/app_localization_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizationCubit', () {
    group('initialize', () {
      blocTest<AppLocalizationCubit, I18n>(
        'should emit an I18n state',
        build: AppLocalizationCubit.new,
        act: (AppLocalizationCubit cubit) => cubit.initialize(),
        expect: () => <dynamic>[isA<I18n>()],
      );
    });
  });
}
