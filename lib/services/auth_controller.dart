import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;

  /// 是否視為「已進入 App」
  /// - 線上：Firebase 成功登入
  /// - 離線：沿用上次登入帳號（不拿 token）
  bool isAuthenticated = false;

  /// 是否為離線 Session（用上次帳號）
  bool isOfflineSession = false;

  /// 當前帳號（離線也會用上次的 email 顯示）
  String? account;

  /// Firebase token（離線為 null）
  String? token;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // ====== 快取的「上次登入使用者」資訊 ======
  String? _lastUid;
  String? _lastEmail;
  String? _lastDisplayName;
  String? _lastPhotoURL;

  String? get lastEmail => _lastEmail;
  String? get lastDisplayName => _lastDisplayName;
  bool get canOfflineSignIn => _lastUid != null;

  /// App 啟動時呼叫：還原快取與線上登入狀態
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lastUid = prefs.getString('last_uid');
    _lastEmail = prefs.getString('last_email');
    _lastDisplayName = prefs.getString('last_displayName');
    _lastPhotoURL = prefs.getString('last_photoURL');

    final u = _auth.currentUser;
    if (u != null) {
      // 線上已登入
      isAuthenticated = true;
      isOfflineSession = false;
      account = u.email;
      token = await u.getIdToken();
    } else {
      // 尚未線上登入，但仍可能有「上次登入帳號」可用來離線進入
      isAuthenticated = false;
      isOfflineSession = false;
      account = null;
      token = null;
    }
    notifyListeners();
  }

  /// 登出：清除線上 Session；保留「上次帳號」以便日後離線登入
  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      isAuthenticated = false;
      isOfflineSession = false;
      account = null;
      token = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Google 登入（google_sign_in 7.x）
  // Future<bool> loginWithGoogle() async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     await GoogleSignIn.instance.initialize();
  //     final gUser = await GoogleSignIn.instance.authenticate();
  //     if (gUser == null) return false;

  //     final gAuth = await gUser.authentication; // v7: 主要取 idToken
  //     final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

  //     final userCred = await _auth.signInWithCredential(credential);
  //     final u = userCred.user!;
  //     // 同步寫入 Firestore
  //     await _db.collection('users').doc(u.uid).set({
  //       'email': u.email,
  //       'displayName': u.displayName,
  //       'photoURL': u.photoURL,
  //       'lastLoginAt': FieldValue.serverTimestamp(),
  //       'provider': 'google',
  //     }, SetOptions(merge: true));

  //     // 快取「上次登入使用者」資訊（供離線登入使用）
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('last_uid', u.uid);
  //     await prefs.setString('last_email', u.email ?? '');
  //     await prefs.setString('last_displayName', u.displayName ?? '');
  //     await prefs.setString('last_photoURL', u.photoURL ?? '');
  //     _lastUid = u.uid;
  //     _lastEmail = u.email;
  //     _lastDisplayName = u.displayName;
  //     _lastPhotoURL = u.photoURL;

  //     isAuthenticated = true;
  //     isOfflineSession = false;
  //     account = u.email;
  //     token = await u.getIdToken();
  //     return true;
  //   } catch (_) {
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<(bool ok, String? reason)> loginWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      await GoogleSignIn.instance.initialize();
      final gUser = await GoogleSignIn.instance.authenticate(); // v7 API
      if (gUser == null) return (false, 'cancelled');

      final gAuth = await gUser.authentication; // v7: 沒有 accessToken
      final cred = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        // accessToken: 不要再填，v7 沒有了
      );

      final userCred = await _auth.signInWithCredential(cred);
      final u = userCred.user!;

      // …後續快取/FireStore 寫入（同你現在的流程）
      return (true, null);
    } on FirebaseAuthException catch (e) {
      return (false, e.code);
    } catch (e) {
      return (false, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ 離線沿用上次登入帳號進入（不觸發 Firebase）
  Future<bool> continueOfflineWithLastUser() async {
    if (_lastUid == null) return false;
    isLoading = true;
    notifyListeners();
    try {
      isAuthenticated = true;
      isOfflineSession = true;
      account = _lastEmail; // 顯示用
      token = null; // 離線沒有 token
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
