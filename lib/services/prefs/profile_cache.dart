// lib/services/profile_cache.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCache {
  // keys
  static const _kTags = 'profile.followed_tags';
  static const _kFriends = 'profile.following_user_ids';
  static const _kAlbums = 'profile.albums'; // 先留著：相簿（未來可放 JSON）

  // ===== Tags =====
  static Future<void> saveFollowedTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kTags, tags);
  }

  static Future<List<String>> loadFollowedTags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kTags) ?? <String>[];
  }

  // ===== Friends =====
  static Future<void> saveFriends(Set<String> userIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFriends, userIds.toList());
  }

  static Future<Set<String>> loadFriends() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kFriends) ?? <String>[]).toSet();
  }

  // ===== Albums（預留，之後可存 JSON 字串陣列）=====
  static Future<void> saveAlbums(List<String> albumsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kAlbums, albumsJson);
  }

  static Future<List<String>> loadAlbums() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kAlbums) ?? <String>[];
  }
}
