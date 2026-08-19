import 'package:baktaz_flutter/core/domain/cubit/hidable/hidable_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(HidableCubit, () {
    late HidableCubit cubit;

    setUp(() {
      cubit = HidableCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('has true as initial state', () {
      expect(cubit.stateValue, isTrue);
    });

    test('emits false when setVisibility(false)', () {
      cubit.setVisibility(isVisible: false);
      expect(cubit.stateValue, isFalse);
    });

    test('emits true when setVisibility(true) after false', () {
      cubit
        ..setVisibility(isVisible: false)
        ..setVisibility(isVisible: true);
      expect(cubit.stateValue, isTrue);
    });
  });
}
