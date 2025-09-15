// lib/services/image_prefs.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 永久保存 postId -> image file path 的對應
class ImagePrefs {
  static const _kKey = 'post_image_paths_v1';

  static Future<Map<String, String>> loadMap() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kKey);
    if (s == null || s.isEmpty) return {};
    final map = Map<String, dynamic>.from(jsonDecode(s));
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<void> saveMap(Map<String, String> m) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, jsonEncode(m));
  }

  static Future<void> setPath(String postId, String path) async {
    final m = await loadMap();
    m[postId] = path;
    await saveMap(m);
  }

  static Future<void> remove(String postId) async {
    final m = await loadMap();
    m.remove(postId);
    await saveMap(m);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKey);
  }
}
