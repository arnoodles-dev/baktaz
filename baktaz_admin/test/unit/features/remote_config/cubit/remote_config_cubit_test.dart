import 'package:baktaz_admin/features/remote_config/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/sort_criteria.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_test/bloc_signals_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../utils/generated_mocks.mocks.dart';

void main() {
  late MockIRemoteConfigRepository mockRepository;
  late MockFailureHandler failureHandler;
  late ConfigSnapshotVersion tVersion;
  late RemoteConfig tConfig;
  late RemoteConfigValue tValue;

  setUp(() {
    tVersion = ConfigSnapshotVersion(
      versionNumber: ValueString('1.0.0', fieldName: 'versionNumber'),
      updateTime: DateTime(2026),
      updateUser: EmailAddress('test@example.com'),
    );
    tValue = RemoteConfigValue(
      valueType: ConfigValueType.string,
      defaultValue: ConfigDefaultValue(value: ValueString('val', fieldName: 'val')),
    );
    tConfig = RemoteConfig(version: tVersion, parameters: <String, RemoteConfigValue>{'key': tValue});
    provideDummy<TaskResult<RemoteConfig>>(TaskEither<Failure, RemoteConfig>.right(tConfig));
    provideDummy<TaskResult<Unit>>(TaskEither<Failure, Unit>.right(unit));
    mockRepository = MockIRemoteConfigRepository();
    failureHandler = MockFailureHandler();
  });

  group('RemoteConfigCubit', () {
    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'loadConfig emits done state when successful',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) => cubit.loadConfig(),
      expect: () => <RemoteConfigState>[
        const RemoteConfigState(status: QueryStatus.loading()),
        RemoteConfigState(status: const QueryStatus.done(), remoteConfig: tConfig),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'updateParameter adds new parameter to pending changes',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) async {
        await cubit.loadConfig();
        final RemoteConfigValue newValue = RemoteConfigValue(
          valueType: ConfigValueType.boolean,
          defaultValue: ConfigDefaultValue(value: ValueString('true', fieldName: 'val')),
        );
        cubit.updateParameter('new_key', newValue);
      },
      skip: 2,
      expect: () => <RemoteConfigState>[
        RemoteConfigState(
          status: const QueryStatus.done(),
          remoteConfig: tConfig,
          pendingChanges: <String, RemoteConfigValue>{
            'new_key': RemoteConfigValue(
              valueType: ConfigValueType.boolean,
              defaultValue: ConfigDefaultValue(value: ValueString('true', fieldName: 'val')),
            ),
          },
        ),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'updateParameter adds to pending when originalValue is null',
      build: () => RemoteConfigCubit.test(mockRepository, failureHandler, RemoteConfigState.initial()),
      act: (RemoteConfigCubit cubit) => cubit.updateParameter('new_key', tValue),
      expect: () => <RemoteConfigState>[
        RemoteConfigState(
          status: const QueryStatus.initial(),
          pendingChanges: <String, RemoteConfigValue>{'new_key': tValue},
        ),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'updateParameter removes from pending when value matches original',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) async {
        await cubit.loadConfig();
        cubit
          ..updateParameter(
            'key',
            RemoteConfigValue(
              valueType: ConfigValueType.string,
              defaultValue: ConfigDefaultValue(value: ValueString('changed', fieldName: 'changed')),
            ),
          )
          ..updateParameter('key', tValue);
      },
      skip: 2,
      expect: () => <RemoteConfigState>[
        RemoteConfigState(
          status: const QueryStatus.done(),
          remoteConfig: tConfig,
          pendingChanges: <String, RemoteConfigValue>{
            'key': RemoteConfigValue(
              valueType: ConfigValueType.string,
              defaultValue: ConfigDefaultValue(value: ValueString('changed', fieldName: 'changed')),
            ),
          },
        ),
        RemoteConfigState(status: const QueryStatus.done(), remoteConfig: tConfig),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'discardChanges clears pending',
      build: () => RemoteConfigCubit.test(
        mockRepository,
        failureHandler,
        RemoteConfigState(
          status: const QueryStatus.initial(),
          pendingChanges: <String, RemoteConfigValue>{
            'k': RemoteConfigValue(
              valueType: ConfigValueType.string,
              defaultValue: ConfigDefaultValue(value: ValueString('v', fieldName: 'v')),
            ),
          },
        ),
      ),
      act: (RemoteConfigCubit cubit) => cubit.discardChanges(),
      expect: () => <RemoteConfigState>[const RemoteConfigState(status: QueryStatus.initial())],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'selectType updates selectedType and resets page',
      build: () => RemoteConfigCubit(mockRepository, failureHandler),
      act: (RemoteConfigCubit cubit) => cubit.selectType(ConfigValueType.number),
      expect: () => <RemoteConfigState>[
        const RemoteConfigState(status: QueryStatus.initial(), selectedType: ConfigValueType.number),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'setPage updates currentPage',
      build: () => RemoteConfigCubit(mockRepository, failureHandler),
      act: (RemoteConfigCubit cubit) => cubit.setPage(3),
      expect: () => <RemoteConfigState>[const RemoteConfigState(status: QueryStatus.initial(), currentPage: 3)],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'selectSortCriteria updates sort and resets page',
      build: () => RemoteConfigCubit(mockRepository, failureHandler),
      act: (RemoteConfigCubit cubit) => cubit.selectSortCriteria(SortCriteria.type),
      expect: () => <RemoteConfigState>[
        const RemoteConfigState(status: QueryStatus.initial(), sortCriteria: SortCriteria.type),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'toggleSortOrder flips isAscending',
      build: () => RemoteConfigCubit(mockRepository, failureHandler),
      act: (RemoteConfigCubit cubit) => cubit.toggleSortOrder(),
      expect: () => <RemoteConfigState>[const RemoteConfigState(status: QueryStatus.initial(), isAscending: false)],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'publishChanges returns early when remoteConfig is null',
      build: () => RemoteConfigCubit(mockRepository, failureHandler),
      act: (RemoteConfigCubit cubit) => cubit.publishChanges(),
      expect: () => <dynamic>[],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'publishChanges saves and clears pending when successful',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        when(mockRepository.publishConfig(any)).thenAnswer((_) => TaskEither<Failure, Unit>.right(unit));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) async {
        await cubit.loadConfig();
        final RemoteConfigValue newValue = RemoteConfigValue(
          valueType: ConfigValueType.string,
          defaultValue: ConfigDefaultValue(value: ValueString('new_val', fieldName: 'new_val')),
        );
        cubit.updateParameter('new_key', newValue);
        await cubit.publishChanges();
      },
      skip: 3,
      expect: () => <RemoteConfigState>[
        RemoteConfigState(
          status: const QueryStatus.done(),
          remoteConfig: RemoteConfig(
            version: tVersion,
            parameters: <String, RemoteConfigValue>{
              'key': tValue,
              'new_key': RemoteConfigValue(
                valueType: ConfigValueType.string,
                defaultValue: ConfigDefaultValue(value: ValueString('new_val', fieldName: 'new_val')),
              ),
            },
          ),
        ),
      ],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'loadConfig emits initial status when repository returns failure',
      build: () {
        when(mockRepository.getRemoteConfig())
            .thenAnswer((_) => TaskEither<Failure, RemoteConfig>.left(const Failure.unexpected('load error')));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) => cubit.loadConfig(),
      expect: () => <RemoteConfigState>[const RemoteConfigState(status: QueryStatus.loading())],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'publishChanges handles failure from repository',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        when(mockRepository.publishConfig(any))
            .thenAnswer((_) => TaskEither<Failure, Unit>.left(const Failure.unexpected('publish error')));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) async {
        await cubit.loadConfig();
        await cubit.publishChanges();
      },
      skip: 2,
      expect: () => <RemoteConfigState>[],
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'loadConfig emits loading state when repository throws exception',
      build: () {
        when(mockRepository.getRemoteConfig()).thenThrow(Exception('network error'));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) => cubit.loadConfig(),
      expect: () => <RemoteConfigState>[const RemoteConfigState(status: QueryStatus.loading())],
      verify: (RemoteConfigCubit cubit) {
        verify(failureHandler.handleException(any, any)).called(1);
      },
    );

    blocSignalTest<RemoteConfigCubit, RemoteConfigState>(
      'publishChanges does not emit state changes when repository throws exception',
      build: () {
        when(mockRepository.getRemoteConfig()).thenAnswer((_) => TaskEither<Failure, RemoteConfig>.right(tConfig));
        when(mockRepository.publishConfig(any)).thenThrow(Exception('network error'));
        return RemoteConfigCubit(mockRepository, failureHandler);
      },
      act: (RemoteConfigCubit cubit) async {
        await cubit.loadConfig();
        await cubit.publishChanges();
      },
      skip: 2,
      expect: () => <RemoteConfigState>[],
      verify: (RemoteConfigCubit cubit) {
        verify(failureHandler.handleException(any, any)).called(1);
      },
    );
  });
}
