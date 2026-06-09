import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();

  // ✅ Web Client ID (client_type = 3) from google-services.json
  // Used for oauth_client type 3
  static const String _webClientId =
      "562885198822-siravv97bb6nsun6cnald9ajb1qm76jo.apps.googleusercontent.com";

  // ✅ google_sign_in v7 uses singleton instance
  // Initialization and scopes are handled via initialize()
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // ------------------------------------------------------------
  // Google Sign-In
  // ------------------------------------------------------------
  Future<UserCredential?> signInWithGoogle({bool isOwner = false}) async {
    try {
      // ✅ v7 singleton initialization
      await _googleSignIn.initialize(serverClientId: _webClientId);

      // ✅ optional: to force account picker
      await _googleSignIn.signOut();

      // ✅ v7: use authenticate() instead of signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        return null; // Gracefully handle cancellation
      }

      // ✅ v7: Accessing authentication tokens is synchronous
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception("Google Sign-In failed: idToken is null");
      }

      // ✅ Create credential using idToken (v7 logic)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // ✅ Firebase sign in
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // ✅ Firestore create/update user
      final user = userCredential.user;
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final doc = await userDoc.get();
        final data = doc.data();

        // Check if doc doesn't exist, or it exists but name/email details are missing (e.g. from fcmToken race condition)
        if (!doc.exists || data == null || data['name'] == null) {
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? 'Google User',
            'email': user.email,
            'photoUrl': user.photoURL,
            'role': isOwner ? 'owner' : 'seeker',
            'provider': 'google',
            'createdAt': data?['createdAt'] ?? FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isBanned': data?['isBanned'] ?? false,
          }, SetOptions(merge: true));
        } else {
          await userDoc.update({
            'photoUrl': user.photoURL,
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e, s) {
      debugPrint("Firebase Auth Error: [${e.code}] ${e.message}");
      debugPrint("Stack: $s");
      rethrow;
    } catch (e, s) {
      debugPrint("Google Sign-In Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Anonymous Sign-In
  // ------------------------------------------------------------
  Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();

      final user = userCredential.user;
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final doc = await userDoc.get();

        if (!doc.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name': 'Guest',
            'email': null,
            'photoUrl': null,
            'role': 'seeker',
            'provider': 'anonymous',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isBanned': false,
          });
        } else {
          await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e, s) {
      debugPrint("Firebase Auth (Anonymous) Error: [${e.code}] ${e.message}");
      debugPrint("Stack: $s");
      rethrow;
    } catch (e, s) {
      debugPrint("Anonymous Sign-In Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Check if user is admin (RTDB)
  // ------------------------------------------------------------
  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final snapshot = await _rtdb.child('admin/${user.uid}').get();
      return snapshot.exists;
    } catch (e) {
      debugPrint("isAdmin error: $e");
      return false;
    }
  }

  // ------------------------------------------------------------
  // Check if user is Owner (Firestore role)
  // ------------------------------------------------------------
  Future<bool> isOwner() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['role'] == 'owner';
      }
      return false;
    } catch (e) {
      debugPrint("isOwner error: $e");
      return false;
    }
  }

  // ------------------------------------------------------------
  // Sign Up with Email/Password
  // ------------------------------------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required bool isOwner,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          'role': isOwner ? 'owner' : 'seeker',
          'provider': 'email',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isBanned': false,
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e, s) {
      debugPrint("Firebase Sign-Up Error: [${e.code}] ${e.message}");
      debugPrint("Stack: $s");
      rethrow;
    } catch (e, s) {
      debugPrint("SignUp Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Sign In with Email/Password
  // ------------------------------------------------------------
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // update lastLogin
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException catch (e, s) {
      debugPrint("Firebase Sign-In Error: [${e.code}] ${e.message}");
      debugPrint("Stack: $s");
      rethrow;
    } catch (e, s) {
      debugPrint("SignIn Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Sign Out
  // ------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e, s) {
      debugPrint("Sign Out Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Delete Account
  // ------------------------------------------------------------
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      try {
        // Delete user Firestore document
        await _firestore.collection('users').doc(uid).delete();
        // Delete the user from Firebase Auth
        await user.delete();
        // Sign out from Google sign in if active
        await _googleSignIn.signOut();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          debugPrint("Re-authentication required to delete account.");
        }
        rethrow;
      } catch (e) {
        debugPrint("Error deleting account: $e");
        rethrow;
      }
    }
  }

  // ------------------------------------------------------------
  // Send Password Reset Email
  // ------------------------------------------------------------
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Password Reset Error: [${e.code}] ${e.message}");
      rethrow;
    } catch (e, s) {
      debugPrint("Password Reset Error: $e");
      debugPrint("Stack: $s");
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------
  User? getCurrentUser() => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<Map<String, dynamic>?> userDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }
}
