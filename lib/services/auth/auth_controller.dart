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
      isAuthenticated = true;
      isOfflineSession = false;
      account = u.email;

      try {
        // ⚠️ 不要強制 refresh，並加上 timeout
        token = await u.getIdToken().timeout(const Duration(seconds: 5));
      } catch (e, st) {
        debugPrint('[AuthController.init] getIdToken failed: $e\n$st');
        token = null; // 拿不到就算了，至少不要卡住
      }
    } else {
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

  Future<(bool ok, String? reason)> loginWithGoogle() async {
    if (isLoading) {
      return (false, 'busy');
    }

    isLoading = true;
    notifyListeners();
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        final userCred = await _auth.signInWithPopup(provider);
        final u = userCred.user!;
        await _postLogin(u, provider: 'google');
        return (true, null);
      } else {
        await GoogleSignIn.instance.initialize();
        final gUser = await GoogleSignIn.instance.authenticate();
        if (gUser == null) return (false, 'cancelled');

        final gAuth = await gUser.authentication;
        final cred = GoogleAuthProvider.credential(idToken: gAuth.idToken);
        final userCred = await _auth.signInWithCredential(cred);
        final u = userCred.user!;
        await _postLogin(u, provider: 'google');
        return (true, null);
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint(
        '[AuthController.loginWithGoogle] FirebaseAuthException: $e\n$st',
      );
      return (false, e.code);
    } catch (e, st) {
      debugPrint('[AuthController.loginWithGoogle] error: $e\n$st');
      return (false, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _postLogin(User u, {required String provider}) async {
    // 1) Firestore 使用者檔：失敗不要擋登入
    try {
      await _db
          .collection('users')
          .doc(u.uid)
          .set({
            'email': u.email,
            'displayName': u.displayName,
            'photoURL': u.photoURL,
            'lastLoginAt': FieldValue.serverTimestamp(),
            'provider': provider,
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));
    } catch (e, st) {
      debugPrint('[AuthController._postLogin] Firestore set failed: $e\n$st');
      // 不 rethrow，允許繼續登入
    }

    // 2) 快取「上次登入使用者」供離線模式（本地操作，應該很穩）
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_uid', u.uid);
    await prefs.setString('last_email', u.email ?? '');
    await prefs.setString('last_displayName', u.displayName ?? '');
    await prefs.setString('last_photoURL', u.photoURL ?? '');
    _lastUid = u.uid;
    _lastEmail = u.email;
    _lastDisplayName = u.displayName;
    _lastPhotoURL = u.photoURL;

    // 3) 更新狀態：先把「已登入」標記起來
    isAuthenticated = true;
    isOfflineSession = false;
    account = u.email;

    // 4) 拿 token：失敗就算了，避免卡住
    try {
      // ⚠️ 這裡改成不強制 refresh，並加 timeout
      token = await u.getIdToken().timeout(const Duration(seconds: 5));
      debugPrint('🔑 Firebase ID Token = $token');
    } catch (e, st) {
      debugPrint('[AuthController._postLogin] getIdToken failed: $e\n$st');
      token = null; // 沒 token 就當成純本機已登入
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

  Future<String?> debugGetIdToken() async {
    final u = _auth.currentUser;
    if (u == null) {
      debugPrint('🔥 debugGetIdToken: 沒有登入使用者');
      return null;
    }
    final t = await u.getIdToken(true); // true = 強制 refresh
    debugPrint('🔑 Firebase ID Token = $t');
    return t;
  }
}
