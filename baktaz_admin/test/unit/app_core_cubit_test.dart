import 'package:baktaz_admin/core/domain/cubit/app_core/app_core_cubit.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/generated_mocks.mocks.dart';

void main() {
  group(AppCoreCubit, () {
    late MockFailureHandler failureHandler;
    late MockIAssetRepository assetRepository;

    setUp(() {
      failureHandler = MockFailureHandler();
      assetRepository = MockIAssetRepository();
    });

    tearDown(() {
      reset(failureHandler);
    });

    group('initialize', () {
      blocSignalTest<AppCoreCubit, AppCoreState>(
        'should complete without emitting states',
        build: () => AppCoreCubit(failureHandler, assetRepository),
        act: (AppCoreCubit cubit) async => cubit.initialize(),
        expect: () => <AppCoreState>[],
      );

      blocSignalTest<AppCoreCubit, AppCoreState>(
        'should handle unexpected error',
        setUp: () {
          when(assetRepository.preloadSVGs()).thenThrow(Exception('error'));
          when(failureHandler.handleException(any, any)).thenReturn(null);
        },
        build: () => AppCoreCubit(failureHandler, assetRepository),
        act: (AppCoreCubit cubit) async => cubit.initialize(),
        verify: (_) {
          verify(failureHandler.handleException(any, any)).called(1);
        },
      );
    });
  });
}
