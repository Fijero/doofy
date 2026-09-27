import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String getLoginCode(String code) {
  switch (code) {
    case 'invalid-credential':
      return 'Invalid credentials';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'Account disabled.';
    case 'too-many-requests':
      return 'Many request, try later';
    default:
      return 'Unexpected error.';
  }
}

String getRegError(String code) {
  switch (code) {
    case 'email-already-in-use':
      return 'Account exists';
    case 'network-request-failed':
      return 'No internet';
    default:
      return 'Unexpected error';
  }
}

String getReAuthError(String code) {
  switch (code) {
    case 'invalid-credential':
      return 'Invalid credential';
    case 'network-request-failed':
      return 'No internet';
    default:
      return 'Unexpected error';
  }
}

class AuthService {
  // instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //   try login
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw getLoginCode(e.code);
    }
  }

  // registering user
  Future<UserCredential?> createUserWithEmailAndPassWord(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Update display name
      await userCredential.user!.updateDisplayName(fullName);

      // 3. Reload user (important)
      await userCredential.user!.reload();

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e);
      throw Exception(getRegError(e.code));
    } catch (e) {
      print(e);
      throw Exception("Something went wrong: $e");
    }
  }
}
