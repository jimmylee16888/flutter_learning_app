import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:flutter_learning_app/services/prefs/profile_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagFollowController extends ChangeNotifier {
  TagFollowController({required this.api});

  final SocialApi api;

  static const int maxTags = 30;
  static const _legacyKey = 'tag_followed'; // 舊版本機 key，僅做一次性搬遷用

  List<String> _followed = [];
  bool _loading = false;

  List<String> get followed => List.unmodifiable(_followed);
  bool get loading => _loading;

  // --- helpers ---
  List<String> _normalize(Iterable<String> src) {
    final s = <String>{};
    for (final raw in src) {
      if (s.length >= maxTags) break;
      final t = raw.trim().toLowerCase();
      if (t.isNotEmpty) s.add(t);
    }
    return s.toList();
  }

  Future<void> _migrateLegacyIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getStringList(_legacyKey) ?? const <String>[];
    if (legacy.isEmpty) return;

    final toMigrate = _normalize(legacy);
    for (final t in toMigrate) {
      try {
        await api.addFollowedTag(t);
      } catch (_) {
        // 忽略單筆失敗，繼續搬遷
      }
    }
    // 以後都走後端與 ProfileCache
    await prefs.remove(_legacyKey);
  }

  // --- lifecycle ---
  Future<void> bootstrap() async {
    _loading = true;
    notifyListeners();
    try {
      // 優先拿後端
      var server = await api.fetchFollowedTags();

      // 後端空 → 試著搬遷舊本機資料
      if (server.isEmpty) {
        await _migrateLegacyIfAny();
        server = await api.fetchFollowedTags();
      }

      if (server.isEmpty) {
        // 還是空 → 用本地快取（可能是離線或新帳號）
        _followed = await ProfileCache.loadFollowedTags();
      } else {
        _followed = _normalize(server);
        await ProfileCache.saveFollowedTags(_followed);
      }
    } catch (_) {
      // 後端失敗（離線等）→ 用本地快取
      _followed = await ProfileCache.loadFollowedTags();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      final server = await api.fetchFollowedTags();
      _followed = _normalize(server);
      await ProfileCache.saveFollowedTags(_followed);
      notifyListeners();
    } catch (_) {
      // 靜默失敗：保持現況（通常是離線）
    }
  }

  Future<void> add(String tag) async {
    final t = tag.trim().toLowerCase();
    if (t.isEmpty) return;

    // 已存在或超過上限（本地側先擋一次）
    if (_followed.contains(t) || _followed.length >= maxTags) return;

    try {
      final server = await api.addFollowedTag(t);
      _followed = _normalize(server);
      await ProfileCache.saveFollowedTags(_followed);
      notifyListeners();
    } catch (_) {
      // 離線 fallback：只動本地快取，待之後 refresh() 同步
      final local = await ProfileCache.loadFollowedTags();
      final merged = _normalize([...local, t]);
      _followed = merged;
      await ProfileCache.saveFollowedTags(_followed);
      notifyListeners();
    }
  }

  Future<void> remove(String tag) async {
    final t = tag.trim().toLowerCase();
    if (t.isEmpty) return;

    try {
      final server = await api.removeFollowedTag(t);
      _followed = _normalize(server);
      await ProfileCache.saveFollowedTags(_followed);
      notifyListeners();
    } catch (_) {
      // 離線 fallback：本地先移除
      final local = await ProfileCache.loadFollowedTags();
      final next = _normalize(local.where((e) => e != t));
      _followed = next;
      await ProfileCache.saveFollowedTags(_followed);
      notifyListeners();
    }
  }
}
