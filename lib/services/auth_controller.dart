import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_api.dart';

// lib/services/auth_controller.dart（只示範修改重點）
class AuthController extends ChangeNotifier {
  bool isLoading = false;
  bool isAuthenticated = false;
  bool isGuest = false; // ← 新增
  String? token;
  String? account;

  final _api = AuthApi();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    account = prefs.getString('auth_account');
    isGuest = prefs.getBool('auth_guest') ?? false; // ← 新增
    isAuthenticated = token != null || isGuest; // ← 新增
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_account');
    await prefs.remove('auth_guest'); // ← 新增
    token = null;
    account = null;
    isGuest = false; // ← 新增
    isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> loginWithPassword(String acc, String pw) async {
    isLoading = true;
    notifyListeners();
    try {
      final t = await _api.login(account: acc, password: pw);
      if (t != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', t);
        await prefs.setString('auth_account', acc);
        await prefs.setBool('auth_guest', false); // ← 新增
        token = t;
        account = acc;
        isGuest = false; // ← 新增
        isAuthenticated = true;
        return true;
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerAndLogin({
    required String acc,
    required String pw,
    required String name,
    required String gender,
    required String birthday,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final t = await _api.register(
        account: acc,
        password: pw,
        name: name,
        gender: gender,
        birthday: birthday,
      );
      if (t != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', t);
        await prefs.setString('auth_account', acc);
        await prefs.setBool('auth_guest', false); // ← 新增
        token = t;
        account = acc;
        isGuest = false; // ← 新增
        isAuthenticated = true;
        return true;
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    // ← 實作訪客登入
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_account');
    await prefs.setBool('auth_guest', true);
    token = null;
    account = null;
    isGuest = true;
    isAuthenticated = true;
    notifyListeners();
  }

  // 刪除你檔案裡那個「重複的 TODO 版 continueAsGuest()」以免衝突
}
