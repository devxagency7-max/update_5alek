import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _authService.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _subscribeToUserData(user.uid);
        _fetchUserRoles();
      } else {
        _userDataSubscription?.cancel();
        _userDataSubscription = null;
        _user = null;
        _userData = null;
        _isAdmin = false;
        _isOwner = false;
      }
      notifyListeners();
    });
  }

  User? _user;
  Map<String, dynamic>? _userData;
  bool _isAdmin = false;
  bool _isOwner = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>?>? _userDataSubscription;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isAdmin => _isAdmin;
  bool get isOwner => _isOwner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _user != null && _user!.isAnonymous;

  // Initialize Auth State (Check current user on startup)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = _authService.getCurrentUser();
      if (_user != null) {
        _subscribeToUserData(_user!.uid);
        await _fetchUserRoles();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Keeps `_userData` in sync with the Firestore user document in real time,
  // so a freshly created document (e.g. on first Google sign-in) is picked up
  // as soon as it's written instead of racing a one-shot read against it.
  void _subscribeToUserData(String uid) {
    _userDataSubscription?.cancel();
    _userDataSubscription = _authService.userDataStream(uid).listen((data) {
      _userData = data;
      notifyListeners();
    });
  }

  Future<void> _fetchUserRoles() async {
    try {
      _isAdmin = await _authService.isAdmin();
      _isOwner = await _authService.isOwner();
    } catch (e) {
      debugPrint('Error fetching user roles: $e');
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _user = _authService.getCurrentUser();
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle({bool isOwner = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle(
        isOwner: isOwner,
      );
      if (userCredential != null) {
        _user = _authService.getCurrentUser();
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInAnonymously();
      if (userCredential != null) {
        _user = _authService.getCurrentUser();
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required bool isOwner,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        isOwner: isOwner,
      );
      _user = _authService.getCurrentUser();
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
      _userData = null;
      _isAdmin = false;
      _isOwner = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.deleteAccount();
      _user = null;
      _userData = null;
      _isAdmin = false;
      _isOwner = false;
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.toString();
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
