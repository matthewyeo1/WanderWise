/*
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:ww_code/main.dart'; // Adjust to your main.dart file
import 'package:ww_code/login_screen.dart'; // Adjust to your MyHomePage file

// Mock Firebase classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

// Mock NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFirebaseFirestore mockFirestore;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockFirestore = MockFirebaseFirestore();
    mockObserver = MockNavigatorObserver();

    // Replace FirebaseAuth and GoogleSignIn instances with mocks
    when(mockFirebaseAuth.signInWithEmailAndPassword(
      email: anyNamed('email') ?? '',
      password: anyNamed('password') ?? '',
    )).thenAnswer((_) async => MockUserCredential());

    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => MockGoogleSignInAccount());

    // Replace FirebaseFirestore instance with mock
    when(mockFirestore.collection(any)).thenReturn(MockCollectionReference());
    when(mockFirestore.doc(any)).thenReturn(MockDocumentReference());
  });

  testWidgets('Login with email and password', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MyHomePage(title: 'Test'),
        navigatorObservers: [mockObserver],
      ),
    );

    // Mock text input
    final emailField = find.widgetWithText(TextField, 'Email');
    await tester.enterText(emailField, 'test@example.com');

    final passwordField = find.widgetWithText(TextField, 'Password');
    await tester.enterText(passwordField, 'password123');

    // Trigger login
    final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
    await tester.tap(loginButton);
    await tester.pump();

    // Verify actions based on successful login flow
    verify(mockFirebaseAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    )).called(1);

    // Example: Verify navigation
    expect(find.text('Logged in as userId'), findsOneWidget); // Replace with actual expected text

    // Verify navigation occurred
    expect(mockObserver.pushedRoutes.length, 1); // Example: Expect one route pushed
  });

  // Add more test cases as needed

}*/
