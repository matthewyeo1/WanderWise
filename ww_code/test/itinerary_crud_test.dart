import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // Import if you need to mock dependencies

// Import your files
import 'package:ww_code/edit_itinerary_page.dart';

void main() {
  group('EditItineraryPage', () {
    testWidgets('Initial test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: EditItineraryPage(
          onSave: (item) {},
        ),
      ));

      // Verify initial text and widgets on EditItineraryPage
      expect(find.text('View/Edit Itinerary'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4)); // Adjust as per your UI

      // Example: Test interaction with a text field
      await tester.enterText(find.byType(TextField).first, 'New Title');

      // Example: Tap on save button and verify interaction
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Example: Verify expected result after interaction
      expect(find.text('Saved'), findsOneWidget);
    });
  });
}

