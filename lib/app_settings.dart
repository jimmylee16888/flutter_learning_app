// lib/widgets/app_settings.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_item.dart';

class AppSettings extends ChangeNotifier {
  // ====== Storage keys ======
  static const _kThemeMode = 'app_theme_mode';
  static const _kLocale = 'app_locale'; // e.g. 'zh_TW' / 'en'
  static const _kCategories = 'categories';
  static const _kCardItems = 'card_items';

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

  AppSettings._();

  /// 供 main.dart 呼叫：讀取所有設定
  static Future<AppSettings> load() async {
    final s = AppSettings._();
    await s._init();
    return s;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    // ---- ThemeMode ----
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

    // ---- Locale ----
    final loc = _prefs!.getString(_kLocale);
    if (loc != null && loc.isNotEmpty) {
      // 支援 'zh_TW' / 'en' / 'ja' 等
      final parts = loc.split('_');
      _locale = parts.length == 2
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
    }

    // ---- Collections (categories & cards) ----
    final cats = _prefs!.getString(_kCategories);
    final cards = _prefs!.getString(_kCardItems);

    _categories = cats == null ? [] : (jsonDecode(cats) as List).cast<String>();

    _cardItems = cards == null
        ? []
        : (jsonDecode(cards) as List)
              .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
              .toList();
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
      final tag = l.countryCode == null || l.countryCode!.isEmpty
          ? l.languageCode
          : '${l.languageCode}_${l.countryCode}';
      _prefs?.setString(_kLocale, tag);
    }
    notifyListeners();
  }

  // ====== 分類與卡片：載入 / 儲存 ======
  Future<void> loadCollections() async {
    // 若需要在 App 生命週期某處手動刷新
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
    // 同步將卡片中被刪除的分類清掉
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
