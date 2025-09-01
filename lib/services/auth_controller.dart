// lib/services/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final GoogleSignIn _google = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  GoogleSignInAccount? _user;
  bool _loading = false;
  bool _guest = false;

  GoogleSignInAccount? get user => _user;
  bool get isLoading => _loading;
  bool get isSignedIn => _user != null;
  bool get isGuest => _guest;
  bool get isAuthenticated => isSignedIn || isGuest;

  Future<void> init() async {
    // 監聽登入狀態
    _google.onCurrentUserChanged.listen((u) {
      _user = u;
      notifyListeners();
    });
    // 嘗試靜默登入
    try {
      _user = await _google.signInSilently();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    if (_loading) return;
    _loading = true;
    _guest = false;
    notifyListeners();
    try {
      _user = await _google.signIn();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _guest = false;
    try {
      await _google.signOut();
    } finally {
      _user = null;
      notifyListeners();
    }
  }

  void continueAsGuest() {
    _guest = true;
    notifyListeners();
  }
}
