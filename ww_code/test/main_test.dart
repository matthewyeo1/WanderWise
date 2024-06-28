import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:ww_code/main.dart' as app;
import 'package:ww_code/aesthetics/themes.dart';
import 'package:ww_code/aesthetics/splashscreen.dart';
import 'package:ww_code/login_screen.dart';

// Mock FirebaseAuth and FirebaseFirestore
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  // Initialize mock services
  MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
  MockFirebaseFirestore mockFirebaseFirestore = MockFirebaseFirestore();

  // Ensure Firebase is initialized before tests run
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  // Define test cases
  group('Main App Tests', () {
    testWidgets('App Initialization Test', (WidgetTester tester) async {
      // Mock FirebaseAuth and FirebaseFirestore instances
      when(mockFirebaseAuth.currentUser).thenReturn(null); // Mock no user initially
      when(mockFirebaseFirestore.settings).thenReturn(Settings(persistenceEnabled: true));

      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeNotifier('', isDarkMode: false)),
          ],
          child: const app.MyApp(),
        ),
      );

      // Verify initial state or widget presence
      expect(find.byType(MaterialApp), findsOneWidget); // Ensure MaterialApp is present
      expect(find.byType(SplashScreen), findsOneWidget); // Ensure SplashScreen is shown
    });

    testWidgets('Theme Loading Test', (WidgetTester tester) async {
      // Mock FirebaseAuth and FirebaseFirestore instances
      when(mockFirebaseAuth.currentUser).thenReturn(MockUser()); // Mock a signed-in user
      when(mockFirebaseFirestore.settings).thenReturn(Settings(persistenceEnabled: true));

      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeNotifier('mockUserId', isDarkMode: false)),
          ],
          child: const app.MyApp(),
        ),
      );

      // Verify theme loading behavior
      // Example: expect certain theme-related widget based on loaded preferences
    });

    testWidgets('Navigation Test', (WidgetTester tester) async {
      // Mock FirebaseAuth and FirebaseFirestore instances
      when(mockFirebaseAuth.currentUser).thenReturn(null); // Mock no user initially
      when(mockFirebaseFirestore.settings).thenReturn(Settings(persistenceEnabled: true));

      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeNotifier('', isDarkMode: false)),
          ],
          child: const app.MyApp(),
        ),
      );

      // Example navigation test: simulate navigation to login screen and verify behavior
      await tester.tap(find.byType(InkWell).first); // Tap on a widget that navigates to login screen
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget); // Ensure LoginScreen is navigated to
    });

    // Add more tests as needed for different app behaviors
  });
}

// Mock User class for FirebaseAuth mock
class MockUser extends Mock implements User {}
