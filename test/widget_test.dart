// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:flutter_application_1/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);

//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();

//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your main file so we can access MyApp
import 'package:flutter_application_1/main.dart'; 

void main() {
  testWidgets('SUTDeal app smoke test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 2. Verify that the App Title "SUTDeal" is shown.
    expect(find.text('🎓 SUTDeal'), findsOneWidget);

    // 3. Verify that the "Browse" tab is visible.
    expect(find.text('Browse'), findsOneWidget);

    // 4. Verify that the "My Items" tab is visible.
    expect(find.text('My Items'), findsOneWidget);

    // 5. Tap the '+' (Floating Action Button) to post an item.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Start the animation
    await tester.pump(const Duration(seconds: 1)); // Wait for dialog animation

    // 6. Verify that the "Post Item for Sale" dialog appears.
    expect(find.text('Post Item for Sale'), findsOneWidget);
    expect(find.text('Item Title'), findsOneWidget);

    // 7. Tap "Cancel" to close the dialog.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle(); // Wait for dialog to close

    // 8. Verify dialog is gone.
    expect(find.text('Post Item for Sale'), findsNothing);
  });
}