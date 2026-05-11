import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minier_bernard_marcel/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final repository = OperationsRepository();
    await repository.clear();
    await repository.saveCompactRows(false);
  });

  testWidgets('creates a local container record', (tester) async {
    await tester.pumpWidget(const MinierOperationsApp());
    await pumpUntilFound(tester, find.byKey(const Key('nav_containers')));

    await tester.tap(find.byKey(const Key('nav_containers')));
    await pumpAppFrames(tester);

    await tester.tap(find.byKey(const Key('add_record_fab')));
    await pumpAppFrames(tester);

    await tester.enterText(
      find.byKey(const Key('record_title_field')),
      'North dock container',
    );
    await tester.enterText(
      find.byKey(const Key('record_reference_field')),
      'CN-9001',
    );
    await tester.enterText(
      find.byKey(const Key('record_client_field')),
      'Dock team',
    );
    await tester.enterText(
      find.byKey(const Key('record_amount_field')),
      '7400',
    );
    await tester.tap(find.byKey(const Key('record_save_button')));
    await pumpAppFrames(tester);

    expect(find.text('North dock container'), findsOneWidget);
    expect(find.textContaining('CN-9001'), findsOneWidget);
  });

  testWidgets('navigates to revenue analytics and settings', (tester) async {
    await tester.pumpWidget(const MinierOperationsApp());
    await pumpUntilFound(tester, find.byKey(const Key('nav_revenue')));

    await tester.tap(find.byKey(const Key('nav_revenue')));
    await pumpAppFrames(tester);
    expect(find.text('Revenue by status'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_settings')));
    await pumpAppFrames(tester);
    expect(
      find.text('All operational records are stored only on this device.'),
      findsOneWidget,
    );
  });
}

Future<void> pumpAppFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 80; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}
