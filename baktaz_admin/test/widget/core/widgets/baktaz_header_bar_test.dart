import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/core/domain/cubit/theme/theme_cubit.dart';
import 'package:baktaz_admin/core/presentation/widgets/baktaz_header_bar.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart';

import '../../../utils/generated_mocks.mocks.dart';
import '../../../utils/mock_material_app.dart';
import '../../../utils/test_utils.dart';

void main() {
  group(BaktazHeaderBar, () {
    late MockThemeCubit mockThemeCubit;

    setUp(() {
      mockThemeCubit = MockThemeCubit();
    });

    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'baktaz_header_bar'.goldensVersion,
      builder: () {
        when(mockThemeCubit.state).thenReturn(signal(ThemeMode.light));
        when(mockThemeCubit.stateValue).thenReturn(ThemeMode.light);

        return GoldenTestGroup(
          children: <Widget>[
            GoldenTestScenario(
              name: 'light mode with menu button',
              child: MockMaterialApp(
                child: BlocSignalProvider<ThemeCubit>.value(
                  value: mockThemeCubit,
                  child: Scaffold(appBar: BaktazHeaderBar(onMenuTap: () {})),
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'light mode without menu button',
              child: MockMaterialApp(
                child: BlocSignalProvider<ThemeCubit>.value(
                  value: mockThemeCubit,
                  child: const Scaffold(appBar: BaktazHeaderBar()),
                ),
              ),
            ),
          ],
        );
      },
    );
  });
}
