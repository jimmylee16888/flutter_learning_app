// lib/services/friend_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class FriendPrefs {
  static const _kKey = 'followed_friends_ids';

  static Future<Set<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kKey)?.toSet() ?? <String>{};
  }

  static Future<Set<String>> add(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final cur = await load();
    cur.add(userId);
    await sp.setStringList(_kKey, cur.toList());
    return cur;
  }

  static Future<Set<String>> remove(String userId) async {
    final sp = await SharedPreferences.getInstance();
    final cur = await load();
    cur.remove(userId);
    await sp.setStringList(_kKey, cur.toList());
    return cur;
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kKey);
  }

  static Future<void> saveAll(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kKey, ids.toList());
  }
}
