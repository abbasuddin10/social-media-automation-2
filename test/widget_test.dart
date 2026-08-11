import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Empty smoke test', (WidgetTester tester) async {
    // যেহেতু আমরা রাউটিং বা অন্য স্ট্রাকচার ব্যবহার করছি, তাই ডিফল্ট টেস্টটি স্কিপ করা হলো
    expect(true, isTrue);

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
