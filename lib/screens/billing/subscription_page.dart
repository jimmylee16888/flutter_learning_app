// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/dev_mode.dart';
import '../../l10n/l10n.dart';
import '../../widgets/app_popups.dart'; // 你原本的彈窗工具
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart'
    show GooglePlayPurchaseParam;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_learning_app/services/subscription_service.dart';

const _kIds = {'basic_monthly', 'plus_monthly', 'pro_monthly'};

Future<Map<String, ProductDetails>> loadProducts() async {
  final resp = await InAppPurchase.instance.queryProductDetails(_kIds);
  if (resp.error != null || resp.notFoundIDs.isNotEmpty) {
    throw Exception('Products not ready: ${resp.error} ${resp.notFoundIDs}');
  }
  return {for (final p in resp.productDetails) p.id: p};
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _iap = InAppPurchase.instance;

  VoidCallback? _effListener;

  // 產品快取 / 狀態
  Map<String, ProductDetails> _products = {};
  bool _loading = true;
  String? _error;

  // 購買監聽
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // === 新增：目前有效的方案 id（basic_monthly / plus_monthly / pro_monthly）
  String? _activeProductId;

  // === 新增：訂閱是否有效（簡易版，以 IAP restore/purchased 為準）
  bool get _hasActiveSub => _activeProductId != null;

  @override
  void initState() {
    super.initState();
    _initIAP();
    _bindServiceEffective();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    if (_effListener != null) {
      SubscriptionService.I.effective.removeListener(_effListener!); // NEW
    }
    super.dispose();
  }

  String? _productIdOfPlan(SubscriptionPlan p) {
    // NEW
    switch (p) {
      case SubscriptionPlan.basic:
        return 'basic_monthly';
      case SubscriptionPlan.plus:
        return 'plus_monthly';
      case SubscriptionPlan.pro:
        return 'pro_monthly';
      case SubscriptionPlan.free:
        return null;
    }
  }

  void _bindServiceEffective() {
    final eff = SubscriptionService.I.effective;

    // 先用目前的有效狀態同步一次 UI（重要！）
    {
      final s = eff.value;
      final id = s.isActive ? _productIdOfPlan(s.plan) : null;
      _activeProductId = id; // 這裡可不用 setState（initState 中呼叫）
    }

    // 接著才監聽後續變化
    _effListener = () {
      final s = eff.value;
      final id = s.isActive ? _productIdOfPlan(s.plan) : null;
      if (mounted) setState(() => _activeProductId = id);
    };
    eff.addListener(_effListener!);
  }

  // === 新增：在 Android 開啟 Google Play 訂閱管理頁
  Future<void> _openPlayManage(String? productId) async {
    // 不一定要帶 sku，但帶上更精準
    final pkg = 'com.popcard.app'; // ← 換成你的 applicationId
    final sku = productId ?? '';
    final uri = Uri.parse(
      'https://play.google.com/store/account/subscriptions?sku=$sku&package=$pkg',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // 後備：只開訂閱頁 root
      final uri2 = Uri.parse(
        'https://play.google.com/store/account/subscriptions',
      );
      await launchUrl(uri2, mode: LaunchMode.externalApplication);
    }
  }

  // === 新增：顯示管理彈窗（目前方案 / 狀態）
  void _showManageDialog() {
    final l = context.l10n;
    final id = _activeProductId;
    final p = id == null ? null : _products[id];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.manage_plan),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, size: 20),
                const SizedBox(width: 8),
                Text(_hasActiveSub ? l.ready : l.notSet),
              ],
            ),
            const SizedBox(height: 8),
            if (_hasActiveSub) ...[
              Text('${l.userProfileTile}: ${p?.title ?? id}'),
              const SizedBox(height: 4),
              Text('${l.price_per_month(p?.price ?? '')}'),
              const SizedBox(height: 8),
              Text(
                // 簡訊息：權益由 Google Play 管理
                l.section_payment_invoice,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              Text(
                l.upgrade_card_desc,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.coming_soon_ok),
          ),
          if (_hasActiveSub)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _openPlayManage(_activeProductId);
              },
              child: Text('Google Play'),
            ),
        ],
      ),
    );
  }

  Future<void> _onUpgradeTap(String productId) async {
    final isDev = await DevMode.isEnabled();
    if (!isDev) {
      _showComingSoon(context);
      return;
    }
    await _buy(productId);
  }

  Future<void> _initIAP() async {
    try {
      final products = await loadProducts();

      // 監聽購買事件
      _purchaseSub = _iap.purchaseStream.listen((purchases) async {
        for (final p in purchases) {
          // 僅處理我們關心的訂閱項
          if (!_kIds.contains(p.productID)) continue;

          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            await _iap.completePurchase(p);

            // ★ NEW：告訴 Service「這個商品已有效」（暫行；之後可改為後端驗證通過時才呼叫）
            await SubscriptionService.I.applyClientDetectedActive(p.productID);

            if (mounted) {
              setState(() => _activeProductId = p.productID);

              final isDev = await DevMode.isEnabled();
              if (isDev) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase success')),
                );
              }
            }
          } else if (p.status == PurchaseStatus.error) {
            if (mounted) {
              final isDev = await DevMode.isEnabled();
              if (isDev) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Purchase error: ${p.error}')),
                );
              }
            }
          }
        }
      });

      // 啟動時嘗試恢復一次，抓取先前有效訂閱（測試環境一樣有 restore）
      await _restoreAndDetectActive();

      // ★ 新增：也讓 SubscriptionService 做一次手動 restore
      await SubscriptionService.I.manualRestore(); // NEW

      setState(() {
        _products = products;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // === 新增：還原並偵測目前權益（簡易判斷，正式建議改後端）
  Future<void> _restoreAndDetectActive() async {
    bool sawActive = false;

    final sub = _iap.purchaseStream.listen((ps) {
      if (ps.any(
        (p) =>
            _kIds.contains(p.productID) &&
            (p.status == PurchaseStatus.purchased ||
                p.status == PurchaseStatus.restored),
      )) {
        sawActive = true;
      }
    });

    try {
      await _iap.restorePurchases();
      await Future.delayed(const Duration(seconds: 2)); // 給 stream 回傳時間
    } finally {
      await sub.cancel();
    }

    if (!sawActive) {
      await SubscriptionService.I.clearToFree(); // 回到 free/inactive
      if (mounted) setState(() => _activeProductId = null);
    }
  }

  // 取得在地化價錢（Play）
  String _priceOf(String id, {required String fallback}) {
    final p = _products[id];
    return p?.price ?? fallback;
  }

  Future<void> _buy(String productId) async {
    final p = _products[productId];
    if (p == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product not ready')));
      return;
    }

    final ready = await _iap.isAvailable();
    if (!ready) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Store not available')));
      return;
    }

    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final PurchaseParam param = isAndroid
        ? GooglePlayPurchaseParam(productDetails: p)
        : PurchaseParam(productDetails: p);

    await _iap.buyNonConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 720;

    final plans = <_Plan>[
      _Plan(
        id: 'basic_monthly',
        name: l.plan_basic,
        spaceGB: 5,
        priceLabel: _priceOf('basic_monthly', fallback: 'NT\$30'),
        features: [
          l.feature_external_images,
          l.feature_small_cloud_space,
          l.feature_ad_free,
        ],
        gradient: const [Color(0xFF2A9D8F), Color(0xFF264653)],
      ),
      // 之後要開其它方案再打開
      // _Plan(
      //   id: 'plus_monthly',
      //   name: l.plan_plus,
      //   spaceGB: 10,
      //   priceLabel: _priceOf('plus_monthly', fallback: 'NT\$90'),
      //   features: [l.feature_upload_local_images, l.feature_priority_support],
      //   recommended: true,
      //   gradient: const [Color(0xFF9B4D96), Color(0xFF5E2D79)],
      // ),
      // _Plan(
      //   id: 'pro_monthly',
      //   name: l.plan_pro,
      //   spaceGB: 50,
      //   priceLabel: _priceOf('pro_monthly', fallback: 'NT\$200'),
      //   features: [l.feature_large_storage, l.feature_album_report],
      //   gradient: const [Color(0xFFC95C54), Color(0xFF7B2B2B)],
      // ),
    ];

    // 動態：頂部 Hero 的 CTA
    final heroCta = _hasActiveSub
        ? l.price_per_month(_products[_activeProductId]?.price ?? l.ready)
        : (_products.isEmpty ? l.badge_coming_soon : l.upgrade_now);

    // 動態：Hero 的 onTap
    final heroTap = _hasActiveSub
        ? _showManageDialog
        : () => showComingSoon(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.billing_title), centerTitle: true),
      backgroundColor: cs.surfaceContainerLowest,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 36),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _initIAP();
                    },
                    child: Text(l.ready),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Hero 橫幅
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _GlassCard(
                      blurSigma: 16,
                      backgroundOpacity: 0.22,
                      borderOpacity: 0.24,
                      gradientOverlay: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(.15),
                          cs.secondary.withOpacity(.10),
                        ],
                      ),
                      child: _HeroBanner(
                        title: _hasActiveSub
                            ? '${l.currentPlan} : ${_products[_activeProductId]?.title ?? _activeProductId}'
                            : l.upgrade_card_title,
                        subtitle: _hasActiveSub
                            ? l.section_payment_invoice
                            : l.upgrade_card_desc,
                        cta: heroCta,
                        onTap: heroTap,
                      ),
                    ),
                  ),
                ),

                // 方案卡
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final plan = plans[i];
                      final isCurrent = _activeProductId == plan.id;

                      return _PlanCard(
                        plan: plan,
                        // 如果是目前方案 → 主按鈕禁用並顯示「目前方案」
                        onPrimaryTap: isCurrent
                            ? null
                            : () => _onUpgradeTap(plan.id),
                        primaryText: isCurrent
                            ? l
                                  .currentPlan // 借用或換字串 key: "目前方案"
                            : l.upgrade_now,
                        // 管理：永遠彈出狀態
                        onSecondaryTap: _showManageDialog,
                        secondaryText: l.manage_plan,
                        isCurrent: isCurrent,
                      );
                    }, childCount: plans.length),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: isWide ? 218 : 248,
                    ),
                  ),
                ),

                // 方案說明
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _GlassCard.section(
                      title: l.section_plan_notes,
                      bullets: [
                        l.bullet_free_external,
                        l.bullet_paid_local_upload,
                        l.bullet_future_tiers,
                      ],
                    ),
                  ),
                ),

                // 付款與發票
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _GlassCard.section(
                      title: l.section_payment_invoice,
                      bullets: [
                        l.bullet_pay_cards,
                        l.bullet_einvoice,
                        l.bullet_cancel_anytime,
                      ],
                    ),
                  ),
                ),

                // 條款
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  sliver: SliverToBoxAdapter(
                    child: _GlassCard.section(
                      title: l.section_terms,
                      bullets: [l.bullet_terms, l.bullet_abuse],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 玻璃感容器
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.blurSigma = 12,
    this.backgroundOpacity = .18,
    this.borderOpacity = .18,
    this.gradientOverlay,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  });

  final Widget child;
  final double blurSigma;
  final double backgroundOpacity;
  final double borderOpacity;
  final Gradient? gradientOverlay;
  final EdgeInsets padding;

  factory _GlassCard.section({
    required String title,
    required List<String> bullets,
  }) {
    return _GlassCard(
      blurSigma: 14,
      backgroundOpacity: .20,
      borderOpacity: .20,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: _SectionCardInner(title: title, bullets: bullets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(backgroundOpacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(borderOpacity),
              width: 1,
            ),
            gradient: gradientOverlay,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.5, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: const StadiumBorder(),
            ),
            child: Text(cta),
          ),
        ],
      ),
    );
  }
}

class _SectionCardInner extends StatelessWidget {
  const _SectionCardInner({required this.title, required this.bullets});
  final String title;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        for (final t in bullets)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(t)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Plan {
  final String id; // 新增：方案 id (與商品 id 對應)
  final String name;
  final int spaceGB;
  final String priceLabel;
  final List<String> features;
  final bool recommended;
  final List<Color> gradient;

  const _Plan({
    required this.id,
    required this.name,
    required this.spaceGB,
    required this.priceLabel,
    required this.features,
    required this.gradient,
    this.recommended = false,
  });
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    required this.primaryText,
    required this.secondaryText,
    this.isCurrent = false,
  });

  final _Plan plan;
  final VoidCallback? onPrimaryTap; // 允許為 null（當前方案禁用）
  final VoidCallback onSecondaryTap;
  final String primaryText;
  final String secondaryText;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double btnHeight = 40;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                plan.gradient.first.withOpacity(.28),
                plan.gradient.last.withOpacity(.28),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cs.primary.withOpacity(.25),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${plan.spaceGB} GB',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    plan.priceLabel,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              if (plan.recommended) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiary.withOpacity(.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: cs.tertiary.withOpacity(.28),
                      width: .8,
                    ),
                  ),
                  child: Text(
                    'Recommended',
                    style: TextStyle(
                      color: cs.tertiary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              ...plan.features.map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: cs.onSurface.withOpacity(.75),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t,
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(.86),
                            height: 1.24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: btnHeight,
                      child: FilledButton.tonal(
                        onPressed: onPrimaryTap, // 當前方案 → null (disabled)
                        child: Text(primaryText),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: btnHeight,
                    child: OutlinedButton(
                      onPressed: onSecondaryTap,
                      child: Text(secondaryText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  final l = context.l10n;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.coming_soon_title),
      content: Text(l.coming_soon_body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l.coming_soon_ok),
        ),
      ],
    ),
  );
}
