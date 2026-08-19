import 'package:baktaz_flutter/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(ThemeCubit, () {
    late MockILocalStorageRepository localStorageRepository;
    late MockFailureHandler failureHandler;
    late ThemeCubit cubit;

    setUp(() {
      localStorageRepository = MockILocalStorageRepository();
      failureHandler = MockFailureHandler();
      cubit = ThemeCubit(localStorageRepository, failureHandler);
    });

    tearDown(() {
      cubit.close();
      reset(localStorageRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      test('starts with system theme mode as initial state', () {
        expect(cubit.stateValue, equals(ThemeMode.system));
      });

      test('emits dark theme when stored isDarkMode is true', () async {
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.right(true));

        await cubit.initialize();

        expect(cubit.stateValue, equals(ThemeMode.dark));
        verify(localStorageRepository.getIsDarkMode()).called(1);
      });

      test('emits light theme when stored isDarkMode is false', () async {
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.right(false));

        await cubit.initialize();

        expect(cubit.stateValue, equals(ThemeMode.light));
      });

      test('keeps system theme when stored isDarkMode is null', () async {
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.right(null));

        await cubit.initialize();

        expect(cubit.stateValue, equals(ThemeMode.system));
      });

      test('delegates failure to failureHandler when storage read fails', () async {
        const Failure failure = Failure.deviceStorage('read error');
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.left(failure));

        await cubit.initialize();

        verify(failureHandler.handleFailure(failure)).called(1);
        expect(cubit.stateValue, equals(ThemeMode.system));
      });

      test('handles exception thrown by storage read', () async {
        final Exception exception = Exception('boom');
        when(localStorageRepository.getIsDarkMode()).thenThrow(exception);

        await cubit.initialize();

        verify(failureHandler.handleException(exception, any)).called(1);
      });
    });

    group('switchTheme', () {
      test('emits dark when current brightness is light', () async {
        when(localStorageRepository.setIsDarkMode(isDarkMode: true)).thenAnswer((_) => TaskResult<Unit>.right(unit));

        await cubit.switchTheme(Brightness.light);

        expect(cubit.stateValue, equals(ThemeMode.dark));
        verify(localStorageRepository.setIsDarkMode(isDarkMode: true)).called(1);
      });

      test('emits light when current brightness is dark', () async {
        when(localStorageRepository.setIsDarkMode(isDarkMode: false)).thenAnswer((_) => TaskResult<Unit>.right(unit));

        await cubit.switchTheme(Brightness.dark);

        expect(cubit.stateValue, equals(ThemeMode.light));
        verify(localStorageRepository.setIsDarkMode(isDarkMode: false)).called(1);
      });

      test('delegates failure to failureHandler when storage write fails', () async {
        const Failure failure = Failure.deviceStorage('write error');
        when(localStorageRepository.setIsDarkMode(isDarkMode: true)).thenAnswer((_) => TaskResult<Unit>.left(failure));

        await cubit.switchTheme(Brightness.light);

        verify(failureHandler.handleFailure(failure)).called(1);
      });
    });

    group('isDarkMode', () {
      test('returns true when state is dark', () async {
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.right(true));

        await cubit.initialize();

        expect(cubit.isDarkMode, isTrue);
      });

      test('returns false when state is light', () async {
        when(localStorageRepository.getIsDarkMode()).thenAnswer((_) => TaskResult<bool?>.right(false));

        await cubit.initialize();

        expect(cubit.isDarkMode, isFalse);
      });
    });
  });
}
