import 'package:flutter_test/flutter_test.dart';

import 'package:cgm_monitor/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CgmMonitorApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('CGM Monitor'), findsOneWidget);
  });
}
