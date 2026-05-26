import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_log_app/main.dart';

void main() {
  testWidgets('MyApp loads LayoutShell with home content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('早上好！, Sjzjams'), findsOneWidget);
    expect(find.text('Your future is in progress'), findsOneWidget);
  });

  testWidgets('Bottom navigation shows all five tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tapping Plan tab shows workout plan header', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('Plan'));
    await tester.pump();

    expect(find.text('Workout Plan'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
  });

  testWidgets('Tapping Profile tab shows user name', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(find.text('Alex Mercer'), findsOneWidget);
    expect(find.text('Your fitness journey'), findsOneWidget);
  });
}
