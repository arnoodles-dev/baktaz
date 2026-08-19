import 'package:baktaz_flutter/features/account/domain/cubit/account_cubit.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_content_header.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_content.dart';
import 'package:baktaz_flutter/features/account/presentation/widgets/account_details_tile.dart';
import 'package:bloc_signals_flutter/bloc_signals_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:signals_core/signals_core.dart' show signal;

import '../../utils/generated_mocks.mocks.dart';
import '../../utils/mock_material_app.dart';

void main() {
  group(AccountDetailsTile, () {
    testWidgets('renders label and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsTile(label: 'Name', value: 'John Doe'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders empty widget when value is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsTile(label: 'Name', value: null, onValueEmptyText: Text('Not provided')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Not provided'), findsOneWidget);
    });

    testWidgets('renders nothing extra when value and empty widget are null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(body: AccountDetailsTile(label: 'Name', value: null)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
    });
  });

  group(AccountDetailsContent, () {
    testWidgets('renders title and children without edit icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsContent(title: 'Contact Details', children: <Widget>[Text('Child Content')]),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Child Content'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('renders edit icon when onEdit provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MockMaterialApp(
          child: Scaffold(
            body: AccountDetailsContent(
              title: 'Contact Details',
              onEdit: () {},
              children: const <Widget>[Text('Child')],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group(AccountContentHeader, () {
    late MockAccountCubit accountCubit;

    setUp(() {
      accountCubit = MockAccountCubit();
      when(accountCubit.state).thenReturn(signal<AccountState>(AccountState.initial()));
    });

    tearDown(() {
      reset(accountCubit);
    });

    Future<void> pumpHeader(WidgetTester tester, {bool isLoading = false, bool settle = true}) async {
      await tester.pumpWidget(
        BlocSignalProvider<AccountCubit>.value(
          value: accountCubit,
          child: MockMaterialApp(
            child: Scaffold(body: AccountContentHeader(isLoading: isLoading, balance: 1000.5, connect: 5)),
          ),
        ),
      );
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
    }

    testWidgets('renders balance and connects values', (WidgetTester tester) async {
      await pumpHeader(tester);

      expect(find.text('VIP'), findsOneWidget);
      expect(find.textContaining('1,000'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders loading skeleton when isLoading is true', (WidgetTester tester) async {
      await pumpHeader(tester, isLoading: true, settle: false);

      expect(find.text('VIP'), findsOneWidget);
    });

    testWidgets('renders zero values when balance and connect are null', (WidgetTester tester) async {
      await tester.pumpWidget(
        BlocSignalProvider<AccountCubit>.value(
          value: accountCubit,
          child: const MockMaterialApp(
            child: Scaffold(body: AccountContentHeader(isLoading: false, balance: null, connect: null)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('0'), findsWidgets);
    });
  });
}
