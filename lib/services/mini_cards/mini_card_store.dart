// lib/services/mini_card_store.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/models/card_item.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniCardStore extends ChangeNotifier {
  // owner(通常用藝人名或 card detail 的 title) -> 小卡清單
  final Map<String, List<MiniCardData>> _byOwner = {};

  List<MiniCardData> forOwner(String owner) =>
      List.unmodifiable(_byOwner[owner] ?? const []);

  List<MiniCardData> allCards() =>
      _byOwner.values.expand((e) => e).toList(growable: false);

  void setForOwner(String owner, List<MiniCardData> cards) {
    _byOwner[owner] = List.of(cards);
    notifyListeners();
  }

  /// 讓統計在 app 啟動就有資料：
  /// 1) 先從 `settings.cardItems` 拿到全部 owner 名稱（藝人）
  /// 2) 再掃 SharedPreferences 的 key，把所有 `miniCards:*` 的 owner 也載入（包含可能的孤兒/舊資料）
  Future<void> hydrateFromPrefs({required List<CardItem> artists}) async {
    final sp = await SharedPreferences.getInstance();

    // 先清空，避免重複疊加
    _byOwner.clear();

    // A) 以藝人清單為主
    for (final a in artists) {
      final key = 'miniCards:${a.title}';
      final raw = sp.getString(key);
      if (raw == null || raw.isEmpty) {
        _byOwner[a.title] = <MiniCardData>[];
        continue;
      }
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(MiniCardData.fromJson)
            .toList();
        _byOwner[a.title] = list;
      } catch (_) {
        _byOwner[a.title] = <MiniCardData>[];
      }
    }

    // B) 補抓所有以 miniCards: 開頭的 key（可能不是在藝人清單中的 owner）
    for (final k in sp.getKeys()) {
      if (!k.startsWith('miniCards:')) continue;
      final owner = k.substring('miniCards:'.length);
      if (_byOwner.containsKey(owner)) continue; // 已在 A 載過
      final raw = sp.getString(k);
      if (raw == null || raw.isEmpty) {
        _byOwner[owner] = <MiniCardData>[];
        continue;
      }
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(MiniCardData.fromJson)
            .toList();
        _byOwner[owner] = list;
      } catch (_) {
        _byOwner[owner] = <MiniCardData>[];
      }
    }

    notifyListeners();
  }

  /// （可選）公開目前 owner 清單，之後統計頁若要迭代可用
  Iterable<String> owners() => _byOwner.keys;
}
