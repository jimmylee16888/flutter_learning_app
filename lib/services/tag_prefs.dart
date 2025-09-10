// lib/services/tag_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class TagPrefs {
  static const _kKey = 'tag_followed';
  static const int maxTags = 30;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kKey) ?? const <String>[];
  }

  static Future<List<String>> add(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final t = tag.trim().toLowerCase();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    if (!list.contains(t)) {
      if (list.length >= maxTags) return list; // 超過上限就不加
      list.add(t);
      await prefs.setStringList(_kKey, list);
    }
    return list;
  }

  static Future<List<String>> remove(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final t = tag.trim().toLowerCase();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    list.remove(t);
    await prefs.setStringList(_kKey, list);
    return list;
  }

  /// ✅ 一次覆蓋全部（提供給遷移用）
  static Future<void> replaceAll(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final norm = tags
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .take(maxTags)
        .toList();
    await prefs.setStringList(_kKey, norm);
  }
}
