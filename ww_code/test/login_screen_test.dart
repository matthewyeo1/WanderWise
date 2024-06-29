import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ww_code/main.dart'; // Update with your actual import
import 'package:ww_code/login_screen.dart'; // Update with your actual import
import 'package:ww_code/aesthetics/themes.dart'; // Update with your actual import

import 'mocks.mocks.dart';

// Mock classes have been generated
// Use MockFirebaseAuth, MockGoogleSignIn, etc. from mocks.mocks.dart

void main() {
  // Unit Test
  group('Login Function - Unit Test', () {
    test('Successful login', () async {
      // Mock FirebaseAuth
      final mockFirebaseAuth = MockFirebaseAuth();
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('12345');

      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => mockUserCredential);

      // Mock Firestore
      final mockFirestore = MockFirebaseFirestore();
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();

      when(mockFirestore.collection('Users')).thenReturn(FakeCollection());
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot['darkMode']).thenReturn(false);

      // Mock ThemeNotifier
      final mockThemeNotifier = MockThemeNotifier();

      // Execute login function
      MyHomePageState pageState = MyHomePageState();
      pageState.emailController.text = 'test@example.com';
      pageState.passwordController.text = 'password';

      await pageState.login(
          mockFirebaseAuth, mockFirestore, mockThemeNotifier);

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com', password: 'password')).called(1);
    });
  });

  // Widget Test
  testWidgets('Login Screen UI - Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (context) => ThemeNotifier(),
        child: MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      ),
    );

    expect(find.text('Hello, Wanderer!'), findsOneWidget);
    expect(find.text('Sign in with your email & password:'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
  });

  // Integration Test
  testWidgets('Login Flow - Integration Test', (WidgetTester tester) async {
    final mockFirebaseAuth = MockFirebaseAuth();
    final mockGoogleSignIn = MockGoogleSignIn();
    final mockFirestore = MockFirebaseFirestore();
    final mockThemeNotifier = MockThemeNotifier();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (context) => mockThemeNotifier,
        child: MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com', password: 'password')).called(1);
  });
}

class FakeCollection extends Fake implements CollectionReference<Map<String, dynamic>> {}

