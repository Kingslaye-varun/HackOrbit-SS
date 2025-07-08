import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/core/services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _errorType; // To distinguish between different error types

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorType => _errorType;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser != null) {
      _user = await _firebaseService.getUserData(currentUser.uid);
      notifyListeners();
    }

    // Listen to auth state changes
    _firebaseService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _user = null;
      } else {
        _user = await _firebaseService.getUserData(user.uid);
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    String? sport,
  }) async {
    _isLoading = true;
    _error = null;
    _errorType = null;
    notifyListeners();

    try {
      await _firebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        sport: sport,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      
      // Categorize the error
      if (e is FirebaseAuthException) {
        // Firebase Auth errors
        _errorType = 'auth';
        switch (e.code) {
          case 'email-already-in-use':
            _error = 'This email is already registered. Please login instead.';
            break;
          case 'weak-password':
            _error = 'Password is too weak. Please use a stronger password.';
            break;
          case 'invalid-email':
            _error = 'Invalid email address format.';
            break;
          default:
            _error = 'Authentication error: ${e.message}';
        }
      } else if (e.toString().contains('SocketException') || 
                e.toString().contains('Connection') || 
                e.toString().contains('timeout')) {
        // Network connection errors
        _errorType = 'network';
        _error = 'Network connection error. Please check your internet connection and try again.';
      } else if (e.toString().contains('MongoDB')) {
        // MongoDB errors
        _errorType = 'database';
        _error = 'Error saving user data. Your account was created but profile data could not be saved. Please try again later.';
      } else {
        // Other errors
        _errorType = 'unknown';
        _error = 'An unexpected error occurred: ${e.toString()}';
      }
      
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    _errorType = null;
    notifyListeners();

    try {
      await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      
      // Categorize the error
      if (e is FirebaseAuthException) {
        // Firebase Auth errors
        _errorType = 'auth';
        switch (e.code) {
          case 'user-not-found':
            _error = 'No account found with this email. Please sign up first.';
            break;
          case 'wrong-password':
            _error = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            _error = 'Invalid email address format.';
            break;
          case 'user-disabled':
            _error = 'This account has been disabled. Please contact support.';
            break;
          default:
            _error = 'Authentication error: ${e.message}';
        }
      } else if (e.toString().contains('SocketException') || 
                e.toString().contains('Connection') || 
                e.toString().contains('timeout')) {
        // Network connection errors
        _errorType = 'network';
        _error = 'Network connection error. Please check your internet connection and try again.';
      } else {
        // Other errors
        _errorType = 'unknown';
        _error = 'An unexpected error occurred: ${e.toString()}';
      }
      
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _errorType = null;
    notifyListeners();
  }
}
