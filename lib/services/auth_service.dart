import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;
import 'database_service.dart';

class AuthService {
  final FirebaseAuth? _auth;
  final GoogleSignIn? _googleSignIn;
  final DatabaseService _databaseService = DatabaseService();

  AuthService()
    : _auth = _isFirebaseAvailable() ? FirebaseAuth.instance : null,
      _googleSignIn = _isFirebaseAvailable() ? GoogleSignIn() : null;

  static bool _isFirebaseAvailable() {
    try {
      FirebaseAuth.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<app_user.User?> get user {
    if (_auth == null) {
      return Stream.value(null);
    }

    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        return await _userFromFirebaseUser(firebaseUser);
      }
      return null;
    });
  }

  Future<app_user.User?> _userFromFirebaseUser(User firebaseUser) async {
    try {
      app_user.User? localUser = await _databaseService.getUser(
        firebaseUser.uid,
      );

      if (localUser != null) {
        return localUser;
      } else {
        app_user.User newUser = app_user.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          homeCity: '',
          isGuest: false,
          createdAt: DateTime.now(),
        );

        await _databaseService.insertUser(newUser);
        return newUser;
      }
    } catch (e) {
      print('Error creating user from Firebase user: $e');
      return null;
    }
  }

  Future<app_user.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return null;
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;
      return firebaseUser != null
          ? await _userFromFirebaseUser(firebaseUser)
          : null;
    } catch (e) {
      print('Error signing in with email: $e');
      return null;
    }
  }

  Future<app_user.User?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return null;
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(displayName);
        return await _userFromFirebaseUser(firebaseUser);
      }
      return null;
    } catch (e) {
      print('Error signing up with email: $e');
      return null;
    }
  }

  Future<app_user.User?> signInWithGoogle() async {
    if (_auth == null || _googleSignIn == null) {
      print('Firebase or Google Sign-In is not initialized');
      return null;
    }

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);
        User? firebaseUser = result.user;
        return firebaseUser != null
            ? await _userFromFirebaseUser(firebaseUser)
            : null;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<app_user.User?> signUpWithPhone(
    String phoneNumber,
    String verificationCode,
  ) async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return null;
    }

    try {
      String guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      app_user.User guestUser = app_user.User(
        id: guestId,
        name: 'User ($phoneNumber)',
        email: '',
        homeCity: '',
        isGuest: true,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertUser(guestUser);
      return guestUser;
    } catch (e) {
      print('Error signing up with phone: $e');
      return null;
    }
  }

  Future<app_user.User?> signInAsGuest() async {
    try {
      String guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      app_user.User guestUser = app_user.User(
        id: guestId,
        name: 'Guest User',
        email: '',
        homeCity: '',
        isGuest: true,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertUser(guestUser);
      return guestUser;
    } catch (e) {
      print('Error creating guest user: $e');
      return null;
    }
  }

  Future<app_user.User?> getCurrentUser() async {
    if (_auth == null) {
      return null;
    }

    try {
      User? firebaseUser = _auth.currentUser;
      return firebaseUser != null
          ? await _userFromFirebaseUser(firebaseUser)
          : null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      if (_auth != null) {
        await _auth.signOut();
      }
      if (_googleSignIn != null) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> deleteUser() async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return false;
    }

    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _databaseService.deleteUser(firebaseUser.uid);
        await firebaseUser.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return false;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_auth == null) {
      print('Firebase is not initialized');
      return false;
    }

    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        if (displayName != null) {
          await firebaseUser.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await firebaseUser.updatePhotoURL(photoURL);
        }

        // Update in local database as well
        app_user.User? localUser = await _databaseService.getUser(
          firebaseUser.uid,
        );
        if (localUser != null) {
          app_user.User updatedUser = app_user.User(
            id: localUser.id,
            email: localUser.email,
            name: displayName ?? localUser.name,
            homeCity: localUser.homeCity,
            preferredCurrency: localUser.preferredCurrency,
            isGuest: localUser.isGuest,
            createdAt: localUser.createdAt,
          );
          await _databaseService.updateUser(updatedUser);
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
