import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '576851441251-qpku3uqqi3no2v9o9h442bjp2pniubbk.apps.googleusercontent.com',
  );

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        print("Google sign-in canceled.");
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Check if the user exists in the 'users' collection
      await _addUserToFirestore(userCredential.user);

      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // Add user to Firestore if not already exists
  Future<void> _addUserToFirestore(User? user) async {
    if (user == null) return;

    try {
      // Check if the user already exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        print(
            "User does not exist in Firestore, creating new user document...");
        // User does not exist, create a new document with only email, name, and createdAt
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName ??
              '', // 'name' will be the display name from Google
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("User document created in Firestore.");
      }
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Check if the user exists in Firestore
      await _addUserToFirestore(userCredential.user);
      return userCredential;
    } catch (e) {
      print("Error signing in with email: $e");
      return null;
    }
  }

  // Listen to authentication state changes (optional but helpful for managing app state)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
