import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/card_item.dart';

class AppSettings extends ChangeNotifier {
  // ====== Storage keys ======
  static const _kThemeMode = 'app_theme_mode';
  static const _kLocale = 'app_locale';
  static const _kCategories = 'categories';
  static const _kCardItems = 'card_items';

  // 使用者資訊
  static const _kNickname = 'user_nickname';
  static const _kBirthdayISO = 'user_birthday_iso'; // yyyy-MM-dd

  // ★ 追蹤標籤（歷史相容；新版本請改用 TagFollowController）
  static const _kFollowedTags = 'followed_tags'; // 目標格式：json array<string>
  static const int followedTagsMax = 30;

  SharedPreferences? _prefs;

  // ====== Theme / Locale ======
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale? _locale;
  Locale? get locale => _locale;

  // ====== 分類 + 卡片 ======
  List<String> _categories = [];
  List<CardItem> _cardItems = [];

  List<String> get categories => List.unmodifiable(_categories);
  List<CardItem> get cardItems => List.unmodifiable(_cardItems);

  // 使用者資訊
  String? _nickname;
  DateTime? _birthday;

  String? get nickname => _nickname;
  DateTime? get birthday => _birthday;

  // ★ 追蹤標籤（僅作為歷史/快取，實際邏輯請用 TagFollowController）
  List<String> _followedTags = [];
  List<String> get followedTags => List.unmodifiable(_followedTags);

  AppSettings._();

  static Future<AppSettings> load() async {
    final s = AppSettings._();
    await s._init();
    return s;
  }

  // 將原始清單正規化（去空白→小寫→去重→限制數量）
  List<String> _normalizeTags(Iterable<String> source) {
    final normSet = <String>{};
    for (final raw in source) {
      if (normSet.length >= followedTagsMax) break;
      final t = raw.trim().toLowerCase();
      if (t.isNotEmpty) normSet.add(t);
    }
    return normSet.toList();
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
    }

    // Collections
    final cats = _prefs!.getString(_kCategories);
    final cards = _prefs!.getString(_kCardItems);
    _categories = cats == null ? [] : (jsonDecode(cats) as List).cast<String>();
    _cardItems = cards == null
        ? []
        : (jsonDecode(cards) as List)
              .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
              .toList();

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
    }

    // ★ 追蹤標籤：相容讀取與遷移
    // 可能的舊格式：StringList；新格式：JSON String
    final dynamic raw = _prefs!.get(_kFollowedTags); // 不指定型別以檢查現況
    if (raw is List<String>) {
      // 舊資料：StringList -> 正規化 -> 寫回 JSON String
      final norm = _normalizeTags(raw);
      _followedTags = norm;
      await _prefs!.setString(_kFollowedTags, jsonEncode(norm));
      // 後續一律用 getString 讀
    } else if (raw is String) {
      // 新資料：JSON 字串
      try {
        final arr = (jsonDecode(raw) as List).map((e) => '$e');
        _followedTags = _normalizeTags(arr);
      } catch (_) {
        _followedTags = [];
      }
    } else {
      // 沒資料或未知型別
      _followedTags = [];
    }
  }

  // ====== Theme / Locale setters ======
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

  // ====== 使用者資訊 ======
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

  // ====== 追蹤標籤（歷史相容：請改用 TagFollowController） ======

  /// 以**本機**為準覆蓋標籤快取。
  /// 新邏輯應使用 TagFollowController 來處理標籤（含後端同步）。
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

  // ====== 分類與卡片：載入 / 儲存 ======
  Future<void> loadCollections() async {
    await _init();
    notifyListeners();
  }

  Future<void> _saveCollections() async {
    await _prefs?.setString(_kCategories, jsonEncode(_categories));
    await _prefs?.setString(
      _kCardItems,
      jsonEncode(_cardItems.map((e) => e.toJson()).toList()),
    );
  }

  // ====== 分類操作 ======
  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_categories.contains(n)) return;
    _categories = [..._categories, n];
    _saveCollections();
    notifyListeners();
  }

  void removeCategory(String name) {
    _categories = _categories.where((c) => c != name).toList();
    _cardItems = _cardItems
        .map(
          (c) => c.copyWith(
            categories: c.categories.where((x) => x != name).toList(),
          ),
        )
        .toList();
    _saveCollections();
    notifyListeners();
  }

  // ====== 卡片操作 ======
  void upsertCard(CardItem item) {
    final idx = _cardItems.indexWhere((c) => c.id == item.id);
    if (idx >= 0) {
      _cardItems = List.of(_cardItems)..[idx] = item;
    } else {
      _cardItems = [..._cardItems, item];
    }
    _saveCollections();
    notifyListeners();
  }

  void setCardCategories(String cardId, List<String> cats) {
    final idx = _cardItems.indexWhere((c) => c.id == cardId);
    if (idx < 0) return;
    _cardItems = List.of(_cardItems)
      ..[idx] = _cardItems[idx].copyWith(categories: cats);
    _saveCollections();
    notifyListeners();
  }

  void removeCard(String cardId) {
    _cardItems = _cardItems.where((c) => c.id != cardId).toList();
    _saveCollections();
    notifyListeners();
  }
}
