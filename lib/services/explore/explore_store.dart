import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/explore/explore_item.dart';

/// 探索頁持久化（App: 原生偏好 / Web: localStorage）
/// - JSON -> UTF8 -> gzip -> base64
/// - 另存未壓縮備份（方便在 devtools 直接查看/回溯）
/// - 失敗時安全回傳空陣列
class ExploreStore {
  ExploreStore._();
  static final ExploreStore I = ExploreStore._();

  static const _kKey = 'explore_state_v1.gzb64';
  static const _kBackupKey = 'explore_state_v1.backup_json';

  Future<bool> save(List<ExploreItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1) 先產生未壓縮 JSON（易讀、也能在限額失敗時保底）
      final plain = jsonEncode(items.map((e) => e.toJson()).toList());
      final okBackup = await prefs.setString(_kBackupKey, plain);

      // 2) 正式資料：gzip + base64（節省 localStorage 容量）
      final gz = _gzipEncode(utf8.encode(plain));
      final b64 = base64Encode(gz);
      final okMain = await prefs.setString(_kKey, b64);

      return okBackup && okMain;
    } catch (_) {
      return false;
    }
  }

  Future<List<ExploreItem>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gzb64 = prefs.getString(_kKey);

      if (gzb64 != null && gzb64.isNotEmpty) {
        // 優先讀壓縮版
        final bytes = base64Decode(gzb64);
        final jsonUtf8 = _gzipDecode(bytes);
        final List raw = jsonDecode(utf8.decode(jsonUtf8)) as List;
        return raw.map((e) => ExploreItem.fromJson(e)).toList();
      }

      // 退而求其次：讀未壓縮備份
      final backup = prefs.getString(_kBackupKey);
      if (backup != null && backup.isNotEmpty) {
        final List raw = jsonDecode(backup) as List;
        return raw.map((e) => ExploreItem.fromJson(e)).toList();
      }

      return <ExploreItem>[];
    } catch (_) {
      return <ExploreItem>[];
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    await prefs.remove(_kBackupKey);
  }

  // ===== gzip utils =====
  Uint8List _gzipEncode(List<int> input) => Uint8List.fromList(GZipCodec().encode(input));

  Uint8List _gzipDecode(List<int> input) => Uint8List.fromList(GZipCodec().decode(input));
}
