import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/main.dart';

void main() {
  testWidgets('Rider portal basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RiderApp());

    // Verify that our title is present.
    expect(find.text('RIDER PORTAL'), findsOneWidget);
  });
}
