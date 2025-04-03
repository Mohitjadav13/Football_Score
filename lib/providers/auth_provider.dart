import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  AuthProvider() {
    _init();
  }

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  User? get user => _user;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential.user == null) {
        _isLoading = false;
        notifyListeners();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for that email.',
        );
      }
      _user = userCredential.user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.registerWithEmailAndPassword(email, password, name);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signInWithGoogle();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.sendPasswordResetEmail(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL, File? imageFile}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      String? finalPhotoURL = photoURL;
      if (imageFile != null) {
        finalPhotoURL = await _authService.uploadProfileImage(imageFile);
      }
      
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: finalPhotoURL,
      );
      _user = _authService.currentUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.reauthenticateWithPassword(currentPassword);
      await _authService.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred while updating password.';
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect. Please try again.';
          break;
        case 'weak-password':
          message = 'New password is too weak. Please use a stronger password.';
          break;
        case 'requires-recent-login':
          message = 'Please sign in again before changing your password.';
          break;
      }
      throw Exception(message);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 