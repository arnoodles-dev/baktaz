import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/features/remote_config/domain/cubit/remote_config/remote_config_cubit.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/config_snapshot_version.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/enum/config_value_type.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config.dart';
import 'package:baktaz_admin/features/remote_config/domain/entity/remote_config_value.dart';
import 'package:baktaz_admin/features/remote_config/presentation/widgets/parameter_table.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/mock_material_app.dart';

void main() {
  provideDummy(const RemoteConfigState(status: QueryStatus.initial()));

  final ConfigSnapshotVersion tVersion = ConfigSnapshotVersion(
    versionNumber: ValueString('1.0.0', fieldName: 'versionNumber'),
    updateTime: DateTime(2026),
    updateUser: EmailAddress('test@example.com'),
  );

  MockRemoteConfigCubit buildCubit(RemoteConfigState mockedState) {
    final MockRemoteConfigCubit cubit = MockRemoteConfigCubit();
    when(cubit.state).thenReturn(signal(mockedState));
    when(cubit.stateValue).thenReturn(mockedState);
    return cubit;
  }

  Widget buildTable({required MockRemoteConfigCubit cubit, void Function(String, RemoteConfigValue, String)? onEdit}) =>
      MockMaterialApp(
        child: BlocSignalProvider<RemoteConfigCubit>.value(
          value: cubit,
          child: ParameterTable(onEdit: onEdit ?? (String k, RemoteConfigValue v, String d) {}),
        ),
      );

  group('ParameterTable Widget Tests', () {
    testWidgets('shows empty state when no parameters', (WidgetTester tester) async {
      final MockRemoteConfigCubit cubit = buildCubit(const RemoteConfigState(status: QueryStatus.initial()));

      await tester.pumpWidget(buildTable(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('shows PENDING badge for new parameters', (WidgetTester tester) async {
      final MockRemoteConfigCubit cubit = buildCubit(
        RemoteConfigState(
          status: const QueryStatus.initial(),
          pendingChanges: <String, RemoteConfigValue>{
            'new_param': RemoteConfigValue(
              defaultValue: ConfigDefaultValue(value: ValueString('val', fieldName: 'defaultValue')),
              valueType: ConfigValueType.string,
            ),
          },
        ),
      );

      await tester.pumpWidget(buildTable(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('shows MODIFIED badge for modified parameters', (WidgetTester tester) async {
      final MockRemoteConfigCubit cubit = buildCubit(
        RemoteConfigState(
          status: const QueryStatus.initial(),
          remoteConfig: RemoteConfig(
            version: tVersion,
            parameters: <String, RemoteConfigValue>{
              'mod_param': RemoteConfigValue(
                defaultValue: ConfigDefaultValue(value: ValueString('old', fieldName: 'defaultValue')),
                valueType: ConfigValueType.string,
              ),
            },
          ),
          pendingChanges: <String, RemoteConfigValue>{
            'mod_param': RemoteConfigValue(
              defaultValue: ConfigDefaultValue(value: ValueString('new', fieldName: 'defaultValue')),
              valueType: ConfigValueType.string,
            ),
          },
        ),
      );

      await tester.pumpWidget(buildTable(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('MODIFIED'), findsOneWidget);
    });

    testWidgets('calls onEdit when edit button is tapped', (WidgetTester tester) async {
      String? editedKey;

      final MockRemoteConfigCubit cubit = buildCubit(
        RemoteConfigState(
          status: const QueryStatus.initial(),
          remoteConfig: RemoteConfig(
            version: tVersion,
            parameters: <String, RemoteConfigValue>{
              'my_param': RemoteConfigValue(
                defaultValue: ConfigDefaultValue(value: ValueString('val', fieldName: 'defaultValue')),
                valueType: ConfigValueType.string,
                description: ValueString('desc', fieldName: 'description'),
              ),
            },
          ),
        ),
      );

      await tester.pumpWidget(
        buildTable(
          cubit: cubit,
          onEdit: (String key, RemoteConfigValue value, String desc) {
            editedKey = key;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(editedKey, 'my_param');
    });

    testWidgets('shows boolean type badge', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1200));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      final MockRemoteConfigCubit cubit = buildCubit(
        RemoteConfigState(
          status: const QueryStatus.initial(),
          remoteConfig: RemoteConfig(
            version: tVersion,
            parameters: <String, RemoteConfigValue>{
              'flag': RemoteConfigValue(
                defaultValue: ConfigDefaultValue(value: ValueString('true', fieldName: 'defaultValue')),
                valueType: ConfigValueType.boolean,
              ),
            },
          ),
        ),
      );

      await tester.pumpWidget(buildTable(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('BOOLEAN'), findsWidgets);
    });
  });

  group('ParameterTable Golden Tests', () {
    final Map<String, RemoteConfigValue> tParameters = <String, RemoteConfigValue>{
      'welcome_message': RemoteConfigValue(
        defaultValue: ConfigDefaultValue(value: ValueString('Welcome to Baktaz!', fieldName: 'defaultValue')),
        valueType: ConfigValueType.string,
        description: ValueString('The main welcome message', fieldName: 'description'),
      ),
    };

    final RemoteConfigState state = RemoteConfigState(
      status: const QueryStatus.initial(),
      remoteConfig: RemoteConfig(version: tVersion, parameters: tParameters),
    );
    final MockRemoteConfigCubit mockCubit = MockRemoteConfigCubit();
    when(mockCubit.state).thenReturn(signal(state));
    when(mockCubit.stateValue).thenReturn(state);

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'parameter_table',
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'with data',
            child: MockMaterialApp(
              child: BlocSignalProvider<RemoteConfigCubit>.value(
                value: mockCubit,
                child: ParameterTable(onEdit: (String k, RemoteConfigValue v, String d) {}),
              ),
            ),
          ),
        ],
      ),
    );
  });
}
