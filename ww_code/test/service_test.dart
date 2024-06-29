import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test/test.dart';
//import 'package:travela/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

/// Starts the Unit Test for Travela.
void main() {
  group('DatabaseService', () {
    FakeFirebaseFirestore? fakeFirebaseFirestore;
    //---------------------------- Set Up -------------------------------
    setUp(() {
      fakeFirebaseFirestore = FakeFirebaseFirestore();
    });

    //---------------------------- Tests -------------------------------
    group(
      '[Firestore Stream Operations]',
      () {
        test('streamCollection returns a stream of QuerySnapshots', () async {
          // Arrange
          DatabaseService service =
              DatabaseService(firestore: fakeFirebaseFirestore!);

          // Act
          Stream<QuerySnapshot<Map<String, dynamic>>> result =
              await service.streamCollection('users');

          // Assert
          expect(result, isA<Stream<QuerySnapshot<Map<String, dynamic>>>>());
        });

        test('streamDocument returns a stream of DocumentSnapshots', () async {
          // Arrange
          DatabaseService service =
              DatabaseService(firestore: fakeFirebaseFirestore!);

          // Act
          Stream<DocumentSnapshot<Map<String, dynamic>>> result =
              await service.streamDocument('users', 'userId1');

          // Assert
          expect(
            result,
            isA<Stream<DocumentSnapshot<Map<String, dynamic>>>>(),
          );
        });
      },
    );

    group(
      '[Firestore Get Operations]',
      () {
        test('getCollection returns a CollectionReference', () async {
          // Arrange
          DatabaseService service =
              DatabaseService(firestore: fakeFirebaseFirestore!);

          // Act
          CollectionReference<Map<String, dynamic>> result =
              await service.getCollection('users');

          // Assert
          expect(
            result,
            isA<CollectionReference<Map<String, dynamic>>>(),
          );
        });

        test('getDocument returns a DocumentReference', () async {
          // Arrange
          DatabaseService service =
              DatabaseService(firestore: fakeFirebaseFirestore!);

          // Act
          DocumentReference<Map<String, dynamic>> result =
              await service.getDocument('users', 'userId1');

          // Assert
          expect(
            result,
            isA<DocumentReference<Map<String, dynamic>>>(),
          );
        });
      },
    );
  });

  group('AuthenticationService', () {
    //---------------------------- Set Up -------------------------------
    setUp(() {});

    //---------------------------- Tests -------------------------------
    group(
      '[Google Sign Up Operations]',
      () {
        test('continueWithGoogle adds correct displayName to FirebaseAuth',
            () async {
          // Arrange
          final googleSignIn = MockGoogleSignIn();
          final signinAccount = await googleSignIn.signIn();
          final googleAuth = await signinAccount!.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final user = MockUser(
            isAnonymous: false,
            uid: 'userId',
            email: 'elon@gmail.com',
            displayName: 'Elon',
          );
          final auth = MockFirebaseAuth(mockUser: user);

          // Act
          final result = await auth.signInWithCredential(credential);
          final actualUser = await result.user;
          final actualData = actualUser!.displayName;
          const expectedData = 'Elon';

          // Assert
          expect(actualData, expectedData);
        });

        test('continueWithGoogle adds correct email to FirebaseAuth', () async {
          // Arrange
          final googleSignIn = MockGoogleSignIn();
          final signinAccount = await googleSignIn.signIn();
          final googleAuth = await signinAccount!.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final user = MockUser(
            isAnonymous: false,
            uid: 'userId',
            email: 'elon@gmail.com',
            displayName: 'Elon',
          );
          final auth = MockFirebaseAuth(mockUser: user);

          // Act
          final result = await auth.signInWithCredential(credential);
          final actualUser = await result.user;
          final actualData = actualUser!.email;
          const expectedData = 'elon@gmail.com';

          // Assert
          expect(actualData, expectedData);
        });
      },
    );

    group(
      '[Email Sign Up Operations]',
      () {
        test('signUpWithEmail adds correct displayName to FirebaseAuth',
            () async {
          // Arrange
          final user = MockUser(
            isAnonymous: false,
            uid: 'userId',
            email: 'elon@gmail.com',
            displayName: 'Elon',
          );
          final auth = MockFirebaseAuth(mockUser: user);

          // Act
          final result = await auth.createUserWithEmailAndPassword(
              email: 'elon@gmail.com', password: 'elonPassword');
          final actualUser = await result.user;
          actualUser!.updateDisplayName('Elon');
          final actualData = actualUser.displayName;
          const expectedData = 'Elon';

          // Assert
          expect(actualData, expectedData);
        });

        test('signUpWithEmail adds correct email to FirebaseAuth', () async {
          // Arrange
          final user = MockUser(
            isAnonymous: false,
            uid: 'userId',
            email: 'elon@gmail.com',
            displayName: 'Elon',
          );
          final auth = MockFirebaseAuth(mockUser: user);

          // Act
          final result = await auth.createUserWithEmailAndPassword(
              email: 'elon@gmail.com', password: 'elonPassword');
          final actualUser = await result.user;
          final actualData = actualUser!.email;
          const expectedData = 'elon@gmail.com';

          // Assert
          expect(actualData, expectedData);
        });
      },
    );
  });
}
