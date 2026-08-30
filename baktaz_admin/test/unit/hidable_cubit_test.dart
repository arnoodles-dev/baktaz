import 'package:baktaz_admin/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(HidableCubit, () {
    group('setVisibility', () {
      blocSignalTest<HidableCubit, bool>(
        'should emit a true state',
        build: () => HidableCubit()..setVisibility(isVisible: false),
        act: (HidableCubit cubit) => cubit.setVisibility(isVisible: true),
        expect: () => <bool>[true],
      );

      blocSignalTest<HidableCubit, bool>(
        'should emit a false state',
        build: HidableCubit.new,
        act: (HidableCubit cubit) => cubit.setVisibility(isVisible: false),
        expect: () => <bool>[false],
      );
    });
  });
}
