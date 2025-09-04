import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  bool isAuthenticated = false;
  String? account;
  String? token;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> init() async {
    final u = _auth.currentUser;
    isAuthenticated = u != null; // ← 已登入就直接進入主畫面
    account = u?.email;
    token = u == null ? null : await u.getIdToken();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_guest'); // 若以前有存訪客旗標，順手清掉
    isAuthenticated = false;
    account = null;
    token = null;
    notifyListeners();
  }

  // 只留 Google 登入（google_sign_in 7.x）
  Future<bool> loginWithGoogle() async {
    isLoading = true;
    notifyListeners();
    try {
      await GoogleSignIn.instance.initialize();
      final gUser = await GoogleSignIn.instance.authenticate();
      if (gUser == null) return false;

      final gAuth = await gUser.authentication; // idToken 為主
      final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

      final userCred = await _auth.signInWithCredential(credential);
      final u = userCred.user!;
      // 建立/更新使用者文件
      await _db.collection('users').doc(u.uid).set({
        'email': u.email,
        'displayName': u.displayName,
        'photoURL': u.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'provider': 'google',
      }, SetOptions(merge: true));

      isAuthenticated = true;
      account = u.email;
      token = await u.getIdToken();
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// // lib/services/auth_controller.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthController extends ChangeNotifier {
//   bool isLoading = false;
//   bool isAuthenticated = false;
//   bool isGuest = false;
//   String? token;
//   String? account;

//   final _auth = FirebaseAuth.instance;
//   final _db = FirebaseFirestore.instance;

//   Future<void> init() async {
//     final prefs = await SharedPreferences.getInstance();
//     // 如果你還想保留本機訪客狀態，可繼續讀這些
//     isGuest = prefs.getBool('auth_guest') ?? false;
//     final u = _auth.currentUser;
//     isAuthenticated = isGuest || u != null;
//     account = u?.email;
//     token = u == null ? null : await u.getIdToken();
//     notifyListeners();
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_guest');
//     token = null;
//     account = null;
//     isGuest = false;
//     isAuthenticated = false;
//     notifyListeners();
//   }

//   // 以 Email/Password 登入（Firebase）
//   Future<bool> loginWithPassword(String email, String pw) async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: pw,
//       );
//       final u = cred.user;
//       if (u == null) return false;

//       // 建立/更新 Firestore 使用者資料
//       await _db.collection('users').doc(u.uid).set({
//         'email': u.email,
//         'displayName': u.displayName,
//         'photoURL': u.photoURL,
//         'lastLoginAt': FieldValue.serverTimestamp(),
//         'provider': 'password',
//       }, SetOptions(merge: true));

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('auth_guest', false);
//       isGuest = false;
//       isAuthenticated = true;
//       account = u.email;
//       token = await u.getIdToken();
//       return true;
//     } catch (_) {
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // 註冊 + 登入（Firebase）
//   Future<bool> registerAndLogin({
//     required String acc,
//     required String pw,
//     required String name,
//     required String gender,
//     required String birthday,
//   }) async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//         email: acc,
//         password: pw,
//       );
//       await cred.user?.updateDisplayName(name);

//       await _db.collection('users').doc(cred.user!.uid).set({
//         'email': acc,
//         'displayName': name,
//         'gender': gender,
//         'birthday': birthday,
//         'createdAt': FieldValue.serverTimestamp(),
//         'provider': 'password',
//       }, SetOptions(merge: true));

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('auth_guest', false);
//       isGuest = false;
//       isAuthenticated = true;
//       account = acc;
//       token = await cred.user!.getIdToken();
//       return true;
//     } catch (_) {
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Google 登入（v7 API）
//   Future<bool> loginWithGoogle() async {
//     isLoading = true;
//     notifyListeners();
//     try {
//       // v7：使用單例並呼叫 authenticate()
//       await GoogleSignIn.instance.initialize();
//       final GoogleSignInAccount? gUser = await GoogleSignIn.instance
//           .authenticate();
//       if (gUser == null) return false;

//       // v7：只有 idToken
//       final gAuth = await gUser.authentication; // 包含 idToken
//       final credential = GoogleAuthProvider.credential(
//         idToken: gAuth.idToken,
//         // accessToken: 已被移除，不要再傳
//       );

//       final userCred = await _auth.signInWithCredential(credential);
//       final u = userCred.user!;

//       await _db.collection('users').doc(u.uid).set({
//         'email': u.email,
//         'displayName': u.displayName,
//         'photoURL': u.photoURL,
//         'lastLoginAt': FieldValue.serverTimestamp(),
//         'provider': 'google',
//       }, SetOptions(merge: true));

//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('auth_guest', false);
//       isGuest = false;
//       isAuthenticated = true;
//       account = u.email;
//       token = await u.getIdToken();
//       return true;
//     } catch (_) {
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> continueAsGuest() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('auth_guest', true);
//     isGuest = true;
//     isAuthenticated = true;
//     token = null;
//     account = null;
//     notifyListeners();
//   }
// }
