// lib/services/card_item/card_item_store.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_learning_app/models/card_item.dart';

/// 專職管理 CardItem 與分類（Categories）的本機快取與持久化。
class CardItemStore extends ChangeNotifier {
  // 與舊版 AppSettings 完全相同的 key，保持向後相容
  static const String _kCategories = 'categories';
  static const String _kCardItems = 'card_items';

  SharedPreferences? _prefs;

  List<String> _categories = <String>[];
  List<CardItem> _items = <CardItem>[];

  List<String> get categories => List.unmodifiable(_categories);
  List<CardItem> get cardItems => List.unmodifiable(_items);

  CardItemStore._();

  /// 載入（從 SharedPreferences 反序列化）
  static Future<CardItemStore> load() async {
    final s = CardItemStore._();
    await s._init();
    return s;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    final catsRaw = _prefs!.getString(_kCategories);
    final itemsRaw = _prefs!.getString(_kCardItems);

    _categories = catsRaw == null
        ? <String>[]
        : (jsonDecode(catsRaw) as List).cast<String>();

    _items = itemsRaw == null
        ? <CardItem>[]
        : (jsonDecode(itemsRaw) as List)
              .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
              .toList();
  }

  Future<void> reload() async {
    await _init();
    notifyListeners();
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kCategories, jsonEncode(_categories));
    await _prefs!.setString(
      _kCardItems,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  // ────────────── 分類 CRUD ──────────────

  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_categories.contains(n)) return;
    _categories = [..._categories, n];
    _persist();
    notifyListeners();
  }

  void removeCategory(String name) {
    _categories = _categories.where((c) => c != name).toList();
    _items = _items
        .map(
          (c) => c.copyWith(
            categories: c.categories.where((x) => x != name).toList(),
          ),
        )
        .toList();
    _persist();
    notifyListeners();
  }

  // ────────────── 卡片 CRUD ──────────────

  void upsertCard(CardItem item) {
    final idx = _items.indexWhere((c) => c.id == item.id);
    if (idx >= 0) {
      _items = List.of(_items)..[idx] = item;
    } else {
      _items = [..._items, item];
    }
    _persist();
    notifyListeners();
  }

  void setCardCategories(String cardId, List<String> cats) {
    final idx = _items.indexWhere((c) => c.id == cardId);
    if (idx < 0) return;
    _items = List.of(_items)..[idx] = _items[idx].copyWith(categories: cats);
    _persist();
    notifyListeners();
  }

  void removeCard(String cardId) {
    _items = _items.where((c) => c.id != cardId).toList();
    _persist();
    notifyListeners();
  }

  // （可選）一次性覆蓋全部集合
  void replaceAll({
    required List<String> categories,
    required List<CardItem> items,
  }) {
    _categories = List.of(categories);
    _items = List.of(items);
    _persist();
    notifyListeners();
  }
}
