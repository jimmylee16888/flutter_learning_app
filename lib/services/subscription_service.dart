// lib/services/subscription_service.dart
// 單例訂閱服務：整合真實商店狀態、開發者覆寫，並輸出「有效狀態」給 UI 監聽。

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 你的方案等級（由低到高），index 越大等級越高。
enum SubscriptionPlan { free, basic, plus, pro }

/// 產品 ID 對應到方案等級（依你在商店後台的 productId 命名調整）
const Map<String, SubscriptionPlan> kProductToPlan = {
  'basic_monthly': SubscriptionPlan.basic,
  'plus_monthly': SubscriptionPlan.plus,
  'pro_monthly': SubscriptionPlan.pro,
};

/// 訂閱狀態（可序列化，便於本機快取）
class SubscriptionState {
  final SubscriptionPlan plan;
  final bool isActive; // 本機視為有效（最終以後端驗證為準）
  final DateTime? lastVerified; // 最後一次成功後端驗證時間（選用）

  const SubscriptionState({
    required this.plan,
    required this.isActive,
    this.lastVerified,
  });

  /// 是否至少擁有某等級（且 isActive=true）
  bool hasAtLeast(SubscriptionPlan want) =>
      isActive && plan.index >= want.index;

  SubscriptionState copyWith({
    SubscriptionPlan? plan,
    bool? isActive,
    DateTime? lastVerified,
  }) => SubscriptionState(
    plan: plan ?? this.plan,
    isActive: isActive ?? this.isActive,
    lastVerified: lastVerified ?? this.lastVerified,
  );

  Map<String, Object?> toJson() => {
    'plan': plan.index,
    'isActive': isActive,
    'lastVerified': lastVerified?.millisecondsSinceEpoch,
  };

  static SubscriptionState fromJson(Map<String, Object?> j) {
    final idx = (j['plan'] as int?) ?? 0;
    return SubscriptionState(
      plan: SubscriptionPlan.values[idx],
      isActive: j['isActive'] as bool? ?? false,
      lastVerified: (j['lastVerified'] as int?) != null
          ? DateTime.fromMillisecondsSinceEpoch(j['lastVerified'] as int)
          : null,
    );
  }

  static const none = SubscriptionState(
    plan: SubscriptionPlan.free,
    isActive: false,
  );
}

/// 單例服務（支援：真實狀態 + 開發者覆寫 + 有效狀態/effective）
/// - App 啟動於 BootLoader 呼叫 [init]；結束時可呼叫 [dispose]。
/// - **UI 一律讀 [effective]**（如果有覆寫就用覆寫；否則用真實）。
class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService I = SubscriptionService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// 真實的商店/伺服器狀態（不受開發者覆寫影響）
  final ValueNotifier<SubscriptionState> state =
      ValueNotifier<SubscriptionState>(SubscriptionState.none);

  /// 實際提供給 UI 的「有效狀態」：若覆寫開啟，輸出覆寫；否則輸出 [state]
  final ValueNotifier<SubscriptionState> effective =
      ValueNotifier<SubscriptionState>(SubscriptionState.none);

  // ─── 本機快取鍵 ───
  static const _kPrefKey = 'entitlement_cache_v1';

  // ─── 開發者覆寫（持久化） ───
  static const _kDevOverrideEnabled = 'dev_sub_override_enabled';
  static const _kDevOverrideState = 'dev_sub_override_state';

  bool _devEnabled = false;
  SubscriptionState? _devState;

  bool get devOverrideEnabled => _devEnabled;
  SubscriptionState? get devOverrideState => _devState;

  /// 啟動：讀真實狀態快取 → 讀覆寫 → 建立 purchase 監聽 → 嘗試 restore → 推送 effective
  Future<void> init() async {
    await _loadRealFromPrefs();
    await _loadDevOverrideFromPrefs();

    // 先把 effective 推上目前的（覆寫優先）
    _recomputeEffective();

    // 同步監聽 real state 的變化（例如 server 回寫、購買流）
    state.addListener(_recomputeEffective);

    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (e, st) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[SubscriptionService] purchaseStream error: $e');
        }
      },
    );

    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[SubscriptionService] restorePurchases failed: $e');
      }
    }
  }

  Future<void> dispose() async {
    state.removeListener(_recomputeEffective);
    await _sub?.cancel();
  }

  /// 由 UI 觸發的購買入口（成功後會由 purchaseStream 回來自動更新狀態）
  Future<void> buy(ProductDetails product) async {
    final available = await _iap.isAvailable();
    if (!available) throw Exception('Store not available');
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// 便捷判斷（讀 effective）
  bool get isPaid =>
      effective.value.isActive && effective.value.plan != SubscriptionPlan.free;
  bool hasAtLeast(SubscriptionPlan p) => effective.value.hasAtLeast(p);

  // ──────────────────────────────────────────────────────────────────────
  // 購買事件處理（更新「真實」狀態）
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _onPurchases(List<PurchaseDetails> events) async {
    var next = state.value;
    SubscriptionPlan? highest;

    for (final p in events) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final mapped = kProductToPlan[p.productID];
          if (mapped != null) {
            if (highest == null || mapped.index > highest.index) {
              highest = mapped;
            }
          }
          break;
        case PurchaseStatus.canceled:
        case PurchaseStatus.error:
        case PurchaseStatus.pending:
          // 不主動降級；待伺服器驗證
          break;
      }
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } catch (e) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[SubscriptionService] completePurchase error: $e');
          }
        }
      }
    }

    if (highest != null) {
      next = next.copyWith(plan: highest, isActive: true);
      await _setRealAndCache(next);
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // 後端驗證（更新「真實」狀態）
  // ──────────────────────────────────────────────────────────────────────
  Future<void> applyServerEntitlement({
    required SubscriptionPlan plan,
    required bool isActive,
    DateTime? verifiedAt,
  }) async {
    final next = state.value.copyWith(
      plan: plan,
      isActive: isActive,
      lastVerified: verifiedAt ?? DateTime.now(),
    );
    await _setRealAndCache(next);
  }

  Future<void> clearToFree() async {
    await _setRealAndCache(SubscriptionState.none);
  }

  // ──────────────────────────────────────────────────────────────────────
  // 開發者覆寫（更新「有效/effective」）
  // ──────────────────────────────────────────────────────────────────────

  Future<void> setDevOverride({
    required bool enabled,
    required SubscriptionPlan plan,
    required bool isActive,
  }) async {
    _devEnabled = enabled;
    _devState = SubscriptionState(plan: plan, isActive: isActive);

    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kDevOverrideEnabled, _devEnabled);
    await sp.setString(_kDevOverrideState, jsonEncode(_devState!.toJson()));

    _recomputeEffective();
  }

  // ──────────────────────────────────────────────────────────────────────
  // 本機快取：真實狀態
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _loadRealFromPrefs() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kPrefKey);
    if (raw == null) {
      state.value = SubscriptionState.none;
      return;
    }
    try {
      final Map<String, Object?> map = jsonDecode(raw) as Map<String, Object?>;
      state.value = SubscriptionState.fromJson(map);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[SubscriptionService] decode real cache failed: $e');
      }
      state.value = SubscriptionState.none;
    }
  }

  Future<void> _setRealAndCache(SubscriptionState s) async {
    state.value = s;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kPrefKey, jsonEncode(s.toJson()));
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[SubscriptionService] write real cache failed: $e');
      }
    }
    _recomputeEffective();
  }

  // ──────────────────────────────────────────────────────────────────────
  // 本機快取：開發者覆寫
  // ──────────────────────────────────────────────────────────────────────

  Future<void> _loadDevOverrideFromPrefs() async {
    final sp = await SharedPreferences.getInstance();
    _devEnabled = sp.getBool(_kDevOverrideEnabled) ?? false;
    final raw = sp.getString(_kDevOverrideState);
    if (raw != null) {
      try {
        final Map<String, Object?> map =
            jsonDecode(raw) as Map<String, Object?>;
        _devState = SubscriptionState.fromJson(map);
      } catch (e) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('[SubscriptionService] decode dev override failed: $e');
        }
        _devState = null;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // 計算有效狀態（覆寫優先）
  // ──────────────────────────────────────────────────────────────────────

  void _recomputeEffective() {
    if (_devEnabled && _devState != null) {
      effective.value = _devState!;
    } else {
      effective.value = state.value;
    }
  }
}
