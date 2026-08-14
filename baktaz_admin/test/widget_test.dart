import 'package:baktaz_admin/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Admin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    expect(find.text('Admin'), findsWidgets);
  });
}
