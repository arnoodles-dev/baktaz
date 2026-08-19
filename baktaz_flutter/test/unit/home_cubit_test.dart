import 'package:baktaz_flutter/features/account/domain/entity/model/address.dart';
import 'package:baktaz_flutter/features/account/domain/entity/model/profile.dart';
import 'package:baktaz_flutter/features/home/domain/cubit/home/home_cubit.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../fixtures/client_fixtures.dart';
import '../utils/generated_mocks.mocks.dart';

void main() {
  group(HomeCubit, () {
    late MockIAccountRepository accountRepository;
    late MockFailureHandler failureHandler;

    setUp(() {
      accountRepository = MockIAccountRepository();
      failureHandler = MockFailureHandler();

      provideDummy<TaskResult<Address?>>(TaskResult<Address?>.right(null));
      provideDummy<TaskResult<Profile>>(TaskResult<Profile>.right(mockProfile));
    });

    tearDown(() {
      reset(accountRepository);
      reset(failureHandler);
    });

    group('initialize', () {
      test('emits loading then done when both succeed with null address', () async {
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(null));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);

        // Allow async initialization to settle
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final HomeState state = cubit.stateValue;
        expect(state.queryStatus, isA<QueryStatus>());
        expect(state.profile, equals(mockProfile));
        expect(state.address, isNull);
        verify(accountRepository.getDefaultAddress()).called(1);
        verify(accountRepository.getProfile()).called(1);
        await cubit.close();
      });

      test('emits address and profile when both succeed with valid address', () async {
        final Address address = Address(id: UniqueId(), street: '123 Main St', locality: 'Springfield');
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(address));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final HomeState state = cubit.stateValue;
        expect(state.address, equals(address));
        expect(state.profile, equals(mockProfile));
        await cubit.close();
      });

      test('emits failure side effect when getDefaultAddress fails', () async {
        const Failure failure = Failure.serverpod('Address fetch failed');
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.left(failure));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));

        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);
        final List<HomeStateSideEffect> effects = <HomeStateSideEffect>[];
        cubit.sideEffectStream.listen(effects.add);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(effects, isNotEmpty);
        expect(effects.first, isA<HomeStateException>());
        verify(failureHandler.handleFailure(failure)).called(greaterThanOrEqualTo(1));
        await cubit.close();
      });

      test('emits failure side effect when getProfile fails', () async {
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(null));
        const Failure failure = Failure.serverpod('Profile fetch failed');
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.left(failure));

        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);
        final List<HomeStateSideEffect> effects = <HomeStateSideEffect>[];
        cubit.sideEffectStream.listen(effects.add);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(effects.any((HomeStateSideEffect e) => e is HomeStateException), isTrue);
        verify(failureHandler.handleFailure(failure)).called(greaterThanOrEqualTo(1));
        await cubit.close();
      });

      test('calls handleException on unexpected exception', () async {
        when(accountRepository.getDefaultAddress()).thenThrow(Exception('unexpected'));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        verify(failureHandler.handleException(any, any)).called(greaterThanOrEqualTo(1));
        await cubit.close();
      });
    });

    group('sideEffectStream', () {
      test('emits HomeStateException when address fetch fails', () async {
        const Failure failure = Failure.serverpod('Address error');
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.left(failure));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);

        final List<HomeStateSideEffect> effects = <HomeStateSideEffect>[];
        cubit.sideEffectStream.listen(effects.add);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(effects.any((HomeStateSideEffect e) => e is HomeStateException), isTrue);
        await cubit.close();
      });

      test('emits initializeAddress when address is null', () async {
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(null));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);

        final List<HomeStateSideEffect> effects = <HomeStateSideEffect>[];
        cubit.sideEffectStream.listen(effects.add);

        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(effects.any((HomeStateSideEffect e) => e is HomeStateInitializeAddress), isTrue);
        await cubit.close();
      });
    });

    group('safeEmitPresentation', () {
      test('does not emit when cubit is closed', () async {
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(null));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);
        await cubit.close();

        // Should not throw
        cubit.safeEmitPresentation(const HomeStateSideEffect.initializeAddress());
      });
    });

    group('close', () {
      test('closes side effect stream controller', () async {
        when(accountRepository.getDefaultAddress()).thenReturn(TaskResult<Address?>.right(null));
        when(accountRepository.getProfile()).thenReturn(TaskResult<Profile>.right(mockProfile));
        final HomeCubit cubit = HomeCubit(accountRepository, failureHandler);
        await cubit.close();

        expect(cubit.isClosed, isTrue);
      });
    });
  });
}
