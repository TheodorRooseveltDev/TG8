import 'package:flutter_test/flutter_test.dart';
import 'package:aviaroll_high/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AviaRollHighApp());

    // Verify splash screen appears
    expect(find.text('BALLOON'), findsOneWidget);
    expect(find.text('TWIST'), findsOneWidget);
  });
}
