import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();
  final FirestoreService _firestore = FirestoreService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _userModel?.role == 'admin';

  void init() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        _userModel = await _firestore.getUser(user.uid);
        if (_userModel == null) {
          _userModel = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'Student',
            photoUrl: user.photoURL ?? '',
            photoBase64: '',
            createdAt: DateTime.now(),
            lastActive: DateTime.now(),
            gamification: GamificationData(),
          );
          await _firestore.createUser(_userModel!);
        }
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user!.updateDisplayName(name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeOnboarding({
    required String name,
    required String photoBase64,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Not signed in';
        return false;
      }
      await user.updateDisplayName(name);
      await user.reload();
      await _firestore.updateUser(user.uid, {
        'displayName': name,
        'photoBase64': photoBase64,
        'onboarded': true,
        'lastActive': DateTime.now(),
      });
      _userModel = await _firestore.getUser(user.uid);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  bool get hasCompletedOnboarding => _userModel?.onboarded == true;

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _firestore.updateUser(_user!.uid, data);
    _userModel = await _firestore.getUser(_user!.uid);
    notifyListeners();
  }
}
