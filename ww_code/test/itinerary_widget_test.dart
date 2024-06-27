import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your files
import 'package:ww_code/map_itinerary_page.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_user_id';
}

void main() {
  group('MapItineraryPage', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    });

    testWidgets('Initial test', (WidgetTester tester) async {
      // Mock Firebase initialization
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) {
        return Stream.value(mockUser);
      });

      await tester.pumpWidget(MaterialApp(
        home: MapItineraryPage(),
      ));

      // Verify initial text and widgets on MapItineraryPage
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('My Itinerary'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Example: Tap on My Itinerary tab and verify the behavior
      await tester.tap(find.byIcon(Icons.list));
      await tester.pump();

      expect(find.text('Create itineraries with friends'), findsOneWidget);
    });
  });
}
