import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Firebase instances
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Get current logged in user
  User? get currentUser => auth.currentUser;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Check if user finished onboarding
  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['onboardingCompleted'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking onboarding: $e');
      return false;
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Create user account
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingCompleted': false,
        // Gamification fields
        'xp': 0,
        'level': '',
        'lastXPUpdate': FieldValue.serverTimestamp(),
        'totalFlashcardsCompleted': 0,
        'totalQuizzesCompleted': 0,
        'streak': 0,
        'lastActive': FieldValue.serverTimestamp(),
        'accuracy': 0.0,
      });

      return {
        'success': true,
        'user': userCredential.user,
        'isNewUser': true,
      };
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth errors
      String message;

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled.';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      } else {
        message = 'Sign up failed. Please try again.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Sign up error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Check if user completed onboarding
      final hasOnboarded =
          await hasCompletedOnboarding(userCredential.user!.uid);

      return {
        'success': true,
        'user': userCredential.user,
        'isNewUser': !hasOnboarded,
      };
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth errors
      String message;

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else {
        message = 'Sign in failed. Please try again.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Sign in error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Check if user cancelled
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Sign in cancelled.',
        };
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user document exists in Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final isNewUser = !userDoc.exists;

      if (isNewUser) {
        // Create new user document
        await firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'onboardingCompleted': false,
          // Gamification fields
          'xp': 0,
          'level': '',
          'lastXPUpdate': FieldValue.serverTimestamp(),
          'totalFlashcardsCompleted': 0,
          'totalQuizzesCompleted': 0,
          'streak': 0,
          'lastActive': FieldValue.serverTimestamp(),
          'accuracy': 0.0,
        });
      }

      // Check onboarding status
      final hasOnboarded =
          isNewUser ? false : await hasCompletedOnboarding(user.uid);

      return {
        'success': true,
        'user': user,
        'isNewUser': !hasOnboarded,
      };
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'message': 'Google sign in failed. Please try again.'
      };
    }
  }

  // Sign in with Apple (not implemented yet)
  Future<Map<String, dynamic>> signInWithApple() async {
    // TODO: Implement Apple Sign In
    // Requires Apple Developer account setup
    return {
      'success': false,
      'message': 'Apple Sign-In is not yet configured. Coming soon!'
    };
  }

  // Sign out user
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }

  // Send password reset email
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent. Check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth errors
      String message;

      if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else {
        message = 'Failed to send reset email. Please try again.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Password reset error: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.'
      };
    }
  }
}
