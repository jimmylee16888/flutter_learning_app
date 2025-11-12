import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_learning_app/models/card_item.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';

class MiniCardStore extends ChangeNotifier {
  static const String kUncategorized = 'Uncategorized';

  /// owner（通常 = CardItem.title） -> 小卡清單
  final Map<String, List<MiniCardData>> _byOwner = {};

  // ===== 讀取 =====

  /// 讀取某位 owner（唯讀）
  List<MiniCardData> forOwner(String owner) =>
      List.unmodifiable(_byOwner[owner] ?? const []);

  /// 讀取所有小卡（唯讀）
  List<MiniCardData> allCards() =>
      _byOwner.values.expand((e) => e).toList(growable: false);

  /// 提供給圖鑑的總清單別名
  List<MiniCardData> get cards => allCards();

  /// 目前 owner 清單
  Iterable<String> owners() => _byOwner.keys;

  /// 找出此 mini card 的 owner（若不存在回 null）
  String? _ownerOf(String cardId) {
    for (final e in _byOwner.entries) {
      if (e.value.any((c) => c.id == cardId)) return e.key;
    }
    return null;
  }

  // ===== 寫入 / 更新（僅在 idol 為空時回填）=====

  /// 覆蓋某位 owner 的清單並通知（不改動各項 idol）
  void setForOwner(String owner, List<MiniCardData> cards) {
    _byOwner[owner] = List.of(cards);
    notifyListeners();
  }

  /// 新增單張 MiniCard 到指定 Card 底下（idol 只在為空時回填 owner）
  Future<void> addMiniCard({
    required CardItem card,
    required MiniCardData mini,
  }) async {
    final fixed = mini.copyWith(
      idol: (mini.idol == null || mini.idol!.trim().isEmpty)
          ? card.title
          : mini.idol,
    );
    final list = _byOwner.putIfAbsent(card.title, () => <MiniCardData>[]);
    list.add(fixed);
    await _persistOwner(card.title);
    notifyListeners();
  }

  /// 一次新增多張（idol 只在為空時回填 owner）
  Future<void> addMiniCards({
    required CardItem card,
    required List<MiniCardData> minis,
  }) async {
    final list = _byOwner.putIfAbsent(card.title, () => <MiniCardData>[]);
    final beforeLen = list.length;

    list.addAll(
      minis.map(
        (m) => m.copyWith(
          idol: (m.idol == null || m.idol!.trim().isEmpty)
              ? card.title
              : m.idol,
        ),
      ),
    );

    if (list.length != beforeLen) {
      await _persistOwner(card.title);
      notifyListeners();
    }
  }

  /// 更新 mini 卡內容（idol 只在為空時回填 owner）
  Future<void> updateMini({
    required CardItem card,
    required MiniCardData mini,
  }) async {
    final list = _byOwner.putIfAbsent(card.title, () => <MiniCardData>[]);
    final idx = list.indexWhere((x) => x.id == mini.id);

    final next = mini.copyWith(
      idol: (mini.idol == null || mini.idol!.trim().isEmpty)
          ? card.title
          : mini.idol,
    );

    bool changed = false;
    if (idx >= 0) {
      changed = _replaceIfChanged(list, idx, next);
    } else {
      list.add(next);
      changed = true;
    }

    if (changed) {
      await _persistOwner(card.title);
      notifyListeners();
    }
  }

  /// 將 mini 卡從 A 卡搬到 B 卡（會同步更新 idol = toCard.title）
  Future<void> moveMini({
    required CardItem fromCard,
    required CardItem toCard,
    required String miniId,
  }) async {
    final from = _byOwner[fromCard.title];
    if (from == null) return;
    final i = from.indexWhere((m) => m.id == miniId);
    if (i < 0) return;

    final m = from.removeAt(i);
    await _persistOwner(fromCard.title);

    final moved = m.copyWith(idol: toCard.title); // 搬家 → 覆蓋為新 owner
    final toList = _byOwner.putIfAbsent(toCard.title, () => <MiniCardData>[]);
    toList.add(moved);
    await _persistOwner(toCard.title);

    notifyListeners();
  }

  /// 兼容舊有呼叫：只帶 MiniCard 更新
  /// 規則：
  /// - 先找當前 owner；若找不到 -> 丟到 Uncategorized。
  /// - idol 只在為空時回填為該 owner 名稱。
  Future<void> updateCard(MiniCardData next) async {
    String owner = _ownerOf(next.id) ?? kUncategorized;
    final list = _byOwner.putIfAbsent(owner, () => <MiniCardData>[]);

    final idx = list.indexWhere((c) => c.id == next.id);
    final fixed = next.copyWith(
      idol: (next.idol == null || next.idol!.trim().isEmpty)
          ? owner
          : next.idol,
    );

    bool changed = false;
    if (idx >= 0) {
      changed = _replaceIfChanged(list, idx, fixed);
    } else {
      list.add(fixed);
      changed = true;
    }

    if (changed) {
      await _persistOwner(owner);
      notifyListeners();
    }
  }

  /// 批次更新（保持各自 owner；idol 只在為空時回填 owner）
  Future<void> updateCardsBatch(Iterable<MiniCardData> updates) async {
    final Map<String, MiniCardData> byId = {for (final c in updates) c.id: c};
    final Set<String> dirtyOwners = {};

    // 現有項目更新
    for (final entry in _byOwner.entries) {
      final owner = entry.key;
      final list = entry.value;
      bool touched = false;

      for (var i = 0; i < list.length; i++) {
        final id = list[i].id;
        final next = byId[id];
        if (next != null) {
          final fixed = next.copyWith(
            idol: (next.idol == null || next.idol!.trim().isEmpty)
                ? owner
                : next.idol,
          );
          if (_replaceIfChanged(list, i, fixed)) touched = true;
        }
      }
      if (touched) dirtyOwners.add(owner);
    }

    // 新來但尚未歸戶的卡 → 放到 Uncategorized（idol 只在為空時補）
    final knownIds = _byOwner.values.expand((e) => e).map((e) => e.id).toSet();
    final newcomers = updates.where((c) => !knownIds.contains(c.id)).toList();
    if (newcomers.isNotEmpty) {
      final list = _byOwner.putIfAbsent(kUncategorized, () => <MiniCardData>[]);
      final before = list.length;
      list.addAll(
        newcomers.map(
          (m) => m.copyWith(
            idol: (m.idol == null || m.idol!.trim().isEmpty)
                ? kUncategorized
                : m.idol,
          ),
        ),
      );
      if (list.length != before) dirtyOwners.add(kUncategorized);
    }

    // 寫回變動的 owner
    for (final owner in dirtyOwners) {
      await _persistOwner(owner);
    }
    if (dirtyOwners.isNotEmpty) notifyListeners();
  }

  /// ⭐ 依 idol（= owner）整組覆蓋該群卡片；會：
  /// 1) 以 next 覆蓋 _byOwner[idol]
  /// 2) 確保每張卡的 idol 欄位 = idol
  /// 3) 以 id 去重
  /// 4) 寫回 SharedPreferences 並 notify
  Future<int> replaceCardsForIdol({
    required String idol,
    required List<MiniCardData> next,
  }) async {
    final key = idol.trim().isEmpty ? kUncategorized : idol.trim();

    // 先正規化：補 idol、去重 by id
    final seen = <String>{};
    final fixed = <MiniCardData>[];
    for (final m in next) {
      final ensured = (m.idol?.trim().isNotEmpty ?? false)
          ? (m.idol == key ? m : m.copyWith(idol: key))
          : m.copyWith(idol: key);
      if (seen.add(ensured.id)) fixed.add(ensured);
    }

    _byOwner[key] = fixed;

    await _persistOwner(key);
    notifyListeners();
    return fixed.length;
  }

  // ===== 持久化 =====

  /// 把某 owner 的清單序列化回 SharedPreferences
  Future<void> _persistOwner(String owner) async {
    final sp = await SharedPreferences.getInstance();
    final list = _byOwner[owner] ?? const <MiniCardData>[];
    final jsonList = list.map((e) => e.toJson()).toList();
    await sp.setString('miniCards:$owner', jsonEncode(jsonList));
  }

  /// 啟動載入：
  /// 1) 先以 artists（CardItem 列表）建立所有 owner
  /// 2) 再掃 SharedPreferences，把所有 `miniCards:*` 的 owner 也載入
  Future<void> hydrateFromPrefs({required List<CardItem> artists}) async {
    final sp = await SharedPreferences.getInstance();

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
            .map(
              (m) => m.idol?.trim().isEmpty ?? true
                  ? m.copyWith(idol: a.title) // 只在空值回填
                  : m,
            )
            .toList();
        _byOwner[a.title] = list;
      } catch (_) {
        _byOwner[a.title] = <MiniCardData>[];
      }
    }

    // B) 補抓 prefs 中可能存在、但不在 artists 清單的 owner
    for (final k in sp.getKeys()) {
      if (!k.startsWith('miniCards:')) continue;
      final owner = k.substring('miniCards:'.length);
      if (_byOwner.containsKey(owner)) continue;
      final raw = sp.getString(k);
      if (raw == null || raw.isEmpty) {
        _byOwner[owner] = <MiniCardData>[];
        continue;
      }
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(MiniCardData.fromJson)
            .map(
              (m) => m.idol?.trim().isEmpty ?? true
                  ? m.copyWith(idol: owner) // 只在空值回填
                  : m,
            )
            .toList();
        _byOwner[owner] = list;
      } catch (_) {
        _byOwner[owner] = <MiniCardData>[];
      }
    }

    notifyListeners();
  }

  // ===== 便利工具 =====

  /// 一次性遷移：把沒有 idol 的資料統一補上為對應 owner 名稱
  Future<void> backfillIdolFromOwnerTitle() async {
    for (final entry in _byOwner.entries) {
      final ownerTitle = entry.key;
      final list = entry.value;
      bool touched = false;
      for (var i = 0; i < list.length; i++) {
        final m = list[i];
        if ((m.idol ?? '').trim().isEmpty) {
          list[i] = m.copyWith(idol: ownerTitle);
          touched = true;
        }
      }
      if (touched) {
        await _persistOwner(ownerTitle);
      }
    }
    notifyListeners();
  }

  /// 兼容舊版：自動回填 idol（僅把 idol 為空的資料補成 owner 名稱）
  /// - 參數 artists / prefer 會被忽略（保留簽名以相容舊呼叫）
  /// - 回傳實際被回填的卡片數量
  Future<int> autofillIdolTags({
    required List<CardItem> artists,
    List<String> prefer = const [],
  }) async {
    int filled = 0;
    for (final entry in _byOwner.entries) {
      final ownerTitle = entry.key;
      final list = entry.value;
      bool touched = false;

      for (var i = 0; i < list.length; i++) {
        final m = list[i];
        final missing = (m.idol == null) || m.idol!.trim().isEmpty;
        if (missing) {
          list[i] = m.copyWith(idol: ownerTitle);
          filled++;
          touched = true;
        }
      }

      if (touched) {
        await _persistOwner(ownerTitle);
      }
    }
    if (filled > 0) notifyListeners();
    return filled;
  }

  // ===== 私有小工具 =====

  bool _miniEquals(MiniCardData a, MiniCardData b) {
    // 依你的資料結構挑重要欄位，至少包含 idol / id 及常用欄位
    return a.id == b.id &&
        a.idol == b.idol &&
        a.name == b.name &&
        a.serial == b.serial &&
        a.imageUrl == b.imageUrl &&
        a.localPath == b.localPath;
  }

  /// 若資料真的有變動才替換，回傳是否變動
  bool _replaceIfChanged(List<MiniCardData> list, int idx, MiniCardData next) {
    if (_miniEquals(list[idx], next)) return false;
    list[idx] = next;
    return true;
  }
}
