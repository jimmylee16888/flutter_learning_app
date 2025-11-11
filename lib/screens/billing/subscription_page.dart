// lib/screens/billing/subscription_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/dev_mode.dart';
import '../../l10n/l10n.dart';

import '../../widgets/app_popups.dart';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:in_app_purchase_android/in_app_purchase_android.dart'
    show GooglePlayPurchaseParam;

const _kIds = {'basic_monthly', 'plus_monthly', 'pro_monthly'};

Future<Map<String, ProductDetails>> loadProducts() async {
  final resp = await InAppPurchase.instance.queryProductDetails(_kIds);
  if (resp.error != null || resp.notFoundIDs.isNotEmpty) {
    throw Exception('Products not ready: ${resp.error} ${resp.notFoundIDs}');
  }
  return {for (final p in resp.productDetails) p.id: p};
}

// === 替換這整個 SubscriptionPage 類別 ===
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});
  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _iap = InAppPurchase.instance;

  // 產品快取 / 狀態
  Map<String, ProductDetails> _products = {};
  bool _loading = true;
  String? _error;

  // 購買監聽
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _onUpgradeTap(String productId) async {
    final isDev = await DevMode.isEnabled();
    if (!isDev) {
      // 非開發者 → 只彈 Coming Soon（上架測試用）
      _showComingSoon(context);
      return;
    }
    // 開發者 → 走原本購買流程
    await _buy(productId);
  }

  Future<void> _initIAP() async {
    // 1) 載商品
    try {
      final products = await loadProducts();
      // 2) 監聽購買事件（ack/complete）
      _purchaseSub = _iap.purchaseStream.listen((purchases) async {
        for (final p in purchases) {
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            // TODO: 推薦在此先呼叫後端做 Google 驗證（Developer API）
            // 驗證 OK 後一定要 complete/acknowledge
            await _iap.completePurchase(p);
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Purchase success')));
            }
          } else if (p.status == PurchaseStatus.error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchase error: ${p.error}')),
              );
            }
          }
        }
      });
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

  // 取得在地化價錢（Play）
  String _priceOf(String id, {required String fallback}) {
    final p = _products[id];
    return p?.price ?? fallback; // 產品尚未取回時先顯示佔位
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
        // 3.x Android 用這個，不需要 offerToken / changeSubscriptionParam
        ? GooglePlayPurchaseParam(productDetails: p)
        // 其它平台用一般的
        : PurchaseParam(productDetails: p);

    // 在 3.x 訂閱流程仍走 buyNonConsumable
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 720;

    // === 用 Play 的價格餵進去 ===
    final plans = <_Plan>[
      _Plan(
        name: l.plan_basic,
        spaceGB: 5,
        priceLabel: _priceOf('basic_monthly', fallback: 'NT\$30'),
        features: [
          l.feature_external_images,
          l.feature_small_cloud_space,
          // l.feature_multi_device_sync,
        ],
        gradient: const [Color(0xFF2A9D8F), Color(0xFF264653)],
      ),
      // _Plan(
      //   name: l.plan_plus,
      //   spaceGB: 10,
      //   priceLabel: _priceOf('plus_monthly', fallback: 'NT\$90'),
      //   features: [
      //     l.feature_upload_local_images,
      //     // l.feature_multi_device_sync,
      //     l.feature_priority_support,
      //   ],
      //   recommended: true,
      //   gradient: const [Color(0xFF9B4D96), Color(0xFF5E2D79)],
      // ),
      // _Plan(
      //   name: l.plan_pro,
      //   spaceGB: 50,
      //   priceLabel: _priceOf('pro_monthly', fallback: 'NT\$200'),
      //   features: [
      //     l.feature_large_storage,
      //     l.feature_album_report,
      //     l.feature_roadmap_advance,
      //   ],
      //   gradient: const [Color(0xFFC95C54), Color(0xFF7B2B2B)],
      // ),
    ];

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
                    child: Text(l.ready), // 隨便用一個字串；可換成 "Retry"
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
                        title: l.upgrade_card_title,
                        subtitle: l.upgrade_card_desc,
                        cta: _products.isEmpty
                            ? l.badge_coming_soon
                            : l.upgrade_now,
                        onTap: () => showComingSoon(context),
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
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _PlanCard(
                        plan: plans[i],
                        onPrimaryTap: () {
                          switch (i) {
                            case 0:
                              _onUpgradeTap('basic_monthly');
                              break;
                            case 1:
                              _onUpgradeTap('plus_monthly');
                              break;
                            case 2:
                              _onUpgradeTap('pro_monthly');
                              break;
                          }
                        },
                        onSecondaryTap: () => _showComingSoon(ctx),
                      ),
                      childCount: plans.length,
                    ),
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

/// 玻璃感容器（可套在 hero / section）
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
  final double backgroundOpacity; // 0~1 越小越透明
  final double borderOpacity;
  final Gradient? gradientOverlay;
  final EdgeInsets padding;

  /// 快速建立「段落 + 子彈」的玻璃 section
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
          // 文案
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
  final String name;
  final int spaceGB;
  final String priceLabel; // e.g. "NT$90"
  final List<String> features;
  final bool recommended;
  final List<Color> gradient;

  const _Plan({
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
  });

  final _Plan plan;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    // 預先計算按鈕高度，保證不 overflow
    const double btnHeight = 40;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          // 彩色漸層覆一層透明膜，底下仍舊可見
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
              // 標題 + 容量 + 價格
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
                    l.price_per_month(plan.priceLabel),
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
                    l.plan_badge_recommended,
                    style: TextStyle(
                      color: cs.tertiary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // 功能清單（字體透明度稍降，讓整體更輕盈）
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

              // 按鈕列（固定高度，避免不同語言撐高）
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: btnHeight,
                      child: FilledButton.tonal(
                        onPressed: onPrimaryTap,
                        child: Text(l.upgrade_now),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: btnHeight,
                    child: OutlinedButton(
                      onPressed: onSecondaryTap,
                      child: Text(l.manage_plan),
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
