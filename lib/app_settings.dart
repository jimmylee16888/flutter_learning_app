// lib/app_settings.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 全域偏好設定（不含卡片/分類邏輯）。
///
/// 職責：
/// - 主題（ThemeMode）
/// - 語系（Locale）
/// - 使用者資訊（暱稱、生日）
/// - 舊版追蹤標籤快取（Deprecated：請改用 TagFollowController）
///
/// ✅ 已移除：categories / card_items 的讀寫與 CRUD，避免與 CardItemStore 衝突。
class AppSettings extends ChangeNotifier {
  // ───────────── Storage Keys ─────────────
  static const _kThemeMode = 'app_theme_mode';
  static const _kLocale = 'app_locale';

  // 使用者資訊
  static const _kNickname = 'user_nickname';
  static const _kBirthdayISO = 'user_birthday_iso'; // yyyy-MM-dd

  // ★ 追蹤標籤（歷史相容；新版本請改用 TagFollowController）
  static const _kFollowedTags = 'followed_tags'; // JSON array<string>
  static const int followedTagsMax = 30;

  SharedPreferences? _prefs;

  // ───────────── Theme / Locale ─────────────
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale? _locale;
  Locale? get locale => _locale;

  // ───────────── 使用者資訊 ─────────────
  String? _nickname;
  DateTime? _birthday;

  String? get nickname => _nickname;
  DateTime? get birthday => _birthday;

  // ───────────── 追蹤標籤（舊邏輯） ─────────────
  List<String> _followedTags = const [];
  List<String> get followedTags => List.unmodifiable(_followedTags);

  AppSettings._();

  /// 初始化載入所有偏好設定。
  static Future<AppSettings> load() async {
    final s = AppSettings._();
    await s._init();
    return s;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    // ThemeMode
    final tm = _prefs!.getString(_kThemeMode);
    switch (tm) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    // Locale
    final loc = _prefs!.getString(_kLocale);
    if (loc != null && loc.isNotEmpty) {
      final parts = loc.split('_');
      _locale = parts.length == 2
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
    } else {
      _locale = null;
    }

    // 使用者資訊
    _nickname = _prefs!.getString(_kNickname);

    final bIso = _prefs!.getString(_kBirthdayISO);
    if (bIso != null && bIso.isNotEmpty) {
      try {
        final p = bIso.split('-').map(int.parse).toList();
        _birthday = DateTime(p[0], p[1], p[2]);
      } catch (_) {
        _birthday = null;
      }
    } else {
      _birthday = null;
    }

    // ★ 追蹤標籤：相容讀取與遷移
    // 可能的舊格式：StringList；新格式：JSON String
    final dynamic raw = _prefs!.get(_kFollowedTags); // 不指定型別以檢查現況
    if (raw is List<String>) {
      // 舊資料：StringList -> 正規化 -> 寫回 JSON String
      final norm = _normalizeTags(raw);
      _followedTags = norm;
      await _prefs!.setString(_kFollowedTags, jsonEncode(norm));
    } else if (raw is String) {
      // 新資料：JSON 字串
      try {
        final arr = (jsonDecode(raw) as List).map((e) => '$e');
        _followedTags = _normalizeTags(arr);
      } catch (_) {
        _followedTags = const [];
      }
    } else {
      _followedTags = const [];
    }
  }

  // ───────────── Setters ─────────────

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs?.setString(_kThemeMode, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
    notifyListeners();
  }

  void setLocale(Locale? l) {
    _locale = l;
    if (l == null) {
      _prefs?.remove(_kLocale);
    } else {
      final tag = (l.countryCode == null || l.countryCode!.isEmpty)
          ? l.languageCode
          : '${l.languageCode}_${l.countryCode}';
      _prefs?.setString(_kLocale, tag);
    }
    notifyListeners();
  }

  void setNickname(String? name) {
    _nickname = (name ?? '').trim().isEmpty ? null : name!.trim();
    if (_nickname == null) {
      _prefs?.remove(_kNickname);
    } else {
      _prefs?.setString(_kNickname, _nickname!);
    }
    notifyListeners();
  }

  void setBirthday(DateTime? date) {
    _birthday = date;
    if (date == null) {
      _prefs?.remove(_kBirthdayISO);
    } else {
      final iso =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      _prefs?.setString(_kBirthdayISO, iso);
    }
    notifyListeners();
  }

  // ───────────── 追蹤標籤（Deprecated：僅維持相容） ─────────────

  /// 以**本機**為準覆蓋標籤快取。
  /// 新邏輯請改用 TagFollowController。
  @Deprecated('Use TagFollowController instead')
  void setFollowedTags(List<String> tags) {
    _followedTags = _normalizeTags(tags);
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
  }

  /// 新增單一標籤到**本機**快取。新邏輯請改用 TagFollowController.add()
  @Deprecated('Use TagFollowController instead')
  bool addFollowedTag(String tag) {
    final t = tag.trim().toLowerCase();
    if (t.isEmpty) return false;
    if (_followedTags.contains(t)) return false;
    if (_followedTags.length >= followedTagsMax) return false;
    _followedTags = [..._followedTags, t];
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
    return true;
  }

  /// 從**本機**快取移除標籤。新邏輯請改用 TagFollowController.remove()
  @Deprecated('Use TagFollowController instead')
  void removeFollowedTag(String tag) {
    final t = tag.trim().toLowerCase();
    _followedTags = _followedTags.where((e) => e != t).toList();
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
  }

  // ───────────── Helpers ─────────────

  /// 將原始清單正規化（去空白 → 小寫 → 去重 → 限制數量）
  List<String> _normalizeTags(Iterable<String> source) {
    final normSet = <String>{};
    for (final raw in source) {
      if (normSet.length >= followedTagsMax) break;
      final t = raw.trim().toLowerCase();
      if (t.isNotEmpty) normSet.add(t);
    }
    return normSet.toList();
  }
}
