import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ww_code/aesthetics/themes.dart';
import 'package:ww_code/user/firebase_auth.dart';
import 'package:ww_code/login_screen.dart';
import 'package:ww_code/forgot_password.dart';
import 'package:ww_code/create_account.dart';
import 'package:ww_code/aesthetics/splashscreen.dart';

class AuthValidator {
  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }
}

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> signOut() async {
    return super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future<void>.value(),
    );
  }
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}



void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyHomePage Widget Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
    });

    Widget createWidgetUnderTest({
      required bool isDarkMode,
      required String userId,
      required FirebaseAuth mockFirebaseAuth,
      required GoogleSignIn mockGoogleSignIn,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(
              userId,
              isDarkMode: isDarkMode,
            ),
          ),
          Provider<AuthService>(
            create: (_) => AuthService(
              auth: mockFirebaseAuth,
              googleSignIn: mockGoogleSignIn,
            ),
          ),
        ],
        child: MaterialApp(
          home: const MyHomePage(),
          routes: {
            '/menu': (context) =>
                Scaffold(body: Center(child: Text('Menu Page'))),
          },
        ),
      );
    }

    testWidgets('renders MyHomePage with email and password TextFields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        userId: 'testUser',
        mockFirebaseAuth: mockFirebaseAuth,
        mockGoogleSignIn: mockGoogleSignIn,
      ));

      expect(find.text('Hello, Wanderer!'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('validates email and password input',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        userId: 'testUser',
        mockFirebaseAuth: mockFirebaseAuth,
        mockGoogleSignIn: mockGoogleSignIn,
      ));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('navigates to Forgot Password Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        userId: 'testUser',
        mockFirebaseAuth: mockFirebaseAuth,
        mockGoogleSignIn: mockGoogleSignIn,
      ));

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('navigates to Create Account Page',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        isDarkMode: false,
        userId: 'testUser',
        mockFirebaseAuth: mockFirebaseAuth,
        mockGoogleSignIn: mockGoogleSignIn,
      ));

      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountPage), findsOneWidget);
    });

    testWidgets('SplashScreen test', (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: SplashScreen())); // Render the SplashScreen

      // Verify that the SplashScreen is displayed
      expect(find.byType(Scaffold),
          findsOneWidget); // Check if Scaffold is present
      expect(find.byType(CircularProgressIndicator),
          findsOneWidget); // Check if CircularProgressIndicator is present
    });
  });

  group('AuthValidator', () {
    late AuthValidator authValidator;

    setUp(() {
      authValidator = AuthValidator();
    });

    test('should return true for valid email', () {
      
      const validEmail = 'test@example.com';

      final result = authValidator.validateEmail(validEmail);

      expect(result, isTrue);
    });

    test('should return false for invalid email', () {
      
      const invalidEmail = 'test@example';

      final result = authValidator.validateEmail(invalidEmail);

      expect(result, isFalse);
    });

    test('should return true for valid password', () {
     
      const validPassword = 'password123';

      final result = authValidator.validatePassword(validPassword);

      expect(result, isTrue);
    });

    test('should return false for invalid password', () {

      const invalidPassword = 'pass';

      final result = authValidator.validatePassword(invalidPassword);

      expect(result, isFalse);
    });
  });
}
