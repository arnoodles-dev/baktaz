import 'package:alchemist/alchemist.dart';
import 'package:baktaz_admin/app/helpers/injection/service_locator.dart';
import 'package:baktaz_admin/features/auth/domain/cubit/login/login_cubit.dart';
import 'package:baktaz_admin/features/auth/presentation/views/login_screen.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart';

import '../../../../utils/generated_mocks.mocks.dart';
import '../../../../utils/mock_material_app.dart';

void main() {
  provideDummy(LoginState.initial());

  late MockLoginCubit mockLoginCubit;
  late Signal<LoginState> loginStateSignal;

  setUp(() async {
    mockLoginCubit = MockLoginCubit();
    loginStateSignal = signal(const LoginState(isLoading: false));

    when(mockLoginCubit.state).thenReturn(loginStateSignal);
    when(mockLoginCubit.stateValue).thenAnswer((_) => loginStateSignal.value);
    when(mockLoginCubit.initialize()).thenAnswer((_) async {});
    when(mockLoginCubit.login(any, any)).thenAnswer((_) async {});
    when(mockLoginCubit.onEmailChanged(any)).thenAnswer((Invocation inv) {
      final String email = inv.positionalArguments[0] as String;
      loginStateSignal.value = loginStateSignal.value.copyWith(email: email);
    });

    if (getIt.isRegistered<LoginCubit>()) {
      await getIt.unregister<LoginCubit>();
    }
    getIt.registerFactory<LoginCubit>(() => mockLoginCubit);
  });

  tearDown(() async {
    if (getIt.isRegistered<LoginCubit>()) {
      await getIt.unregister<LoginCubit>();
    }
  });

  Widget buildScreen() => const MockMaterialApp(child: Scaffold(body: LoginScreen()));

  group('LoginScreen Widget Tests', () {
    testWidgets('renders app name, email, password fields and submit button', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(BaktazTextField), findsNWidgets(2));
      expect(find.byType(BaktazButton), findsOneWidget);
    });

    testWidgets('typing email calls onEmailChanged on cubit', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final Finder emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'admin@baktaz.com');
      await tester.pump();

      verify(mockLoginCubit.onEmailChanged('admin@baktaz.com')).called(1);
    });

    testWidgets('tapping login button calls login on cubit', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final Finder emailField = find.byType(TextField).first;
      final Finder passwordField = find.byType(TextField).at(1);
      final Finder loginButton = find.byType(BaktazButton);

      await tester.enterText(emailField, 'admin@baktaz.com');
      await tester.pump();
      await tester.enterText(passwordField, 'secret123');
      await tester.pump();

      await tester.tap(loginButton);
      await tester.pump(const Duration(seconds: 1));

      verify(mockLoginCubit.login('admin@baktaz.com', 'secret123')).called(1);
    });
  });

  group('LoginScreen Golden Tests', () {
    // ignore: discarded_futures
    goldenTest(
      'renders correctly',
      fileName: 'login_screen',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        children: <Widget>[
          GoldenTestScenario(
            name: 'default login layout',
            child: const MockMaterialApp(child: SizedBox(width: 1000, height: 800, child: LoginScreen())),
          ),
        ],
      ),
    );
  });
}
