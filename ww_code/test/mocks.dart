import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ww_code/aesthetics/themes.dart';


@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  FirebaseFirestore,
  DocumentReference,
  DocumentSnapshot,
  GoogleSignIn,
  ThemeNotifier,
  CollectionReference,
 
])
void main() {}
