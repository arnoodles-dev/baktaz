// ignore: avoid_implementing_value_operators
import 'package:baktaz_flutter/core/domain/cubit/app_life_cycle/app_life_cycle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AppLifeCycleCubit, () {
    late MockTalker talker;
    late AppLifeCycleCubit cubit;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      talker = MockTalker();
      cubit = AppLifeCycleCubit(talker);
    });

    tearDown(() {
      cubit.close();
      reset(talker);
    });

    test('starts with resumed state', () {
      expect(cubit.stateValue, equals(const AppLifeCycleState.resumed()));
    });

    test('emits paused state when lifecycle changes to paused', () {
      cubit.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(cubit.stateValue, equals(const AppLifeCycleState.paused()));
    });

    test('emits inactive state when lifecycle changes to inactive', () {
      cubit.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(cubit.stateValue, equals(const AppLifeCycleState.inactive()));
    });

    test('emits detached state when lifecycle changes to detached', () {
      cubit.didChangeAppLifecycleState(AppLifecycleState.detached);
      expect(cubit.stateValue, equals(const AppLifeCycleState.detached()));
    });

    test('emits hidden state when lifecycle changes to hidden', () {
      cubit.didChangeAppLifecycleState(AppLifecycleState.hidden);
      expect(cubit.stateValue, equals(const AppLifeCycleState.hidden()));
    });

    test('emits resumed state when lifecycle changes to resumed', () {
      cubit
        ..didChangeAppLifecycleState(AppLifecycleState.paused)
        ..didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(cubit.stateValue, equals(const AppLifeCycleState.resumed()));
    });

    test('logs lifecycle state via talker', () {
      cubit.didChangeAppLifecycleState(AppLifecycleState.paused);
      verify(talker.debug(any)).called(1);
    });
  });
}
