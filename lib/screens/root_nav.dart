import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/screens/billing/subscription_page.dart';

import '../app_settings.dart';
import '../l10n/l10n.dart';

// 既有頁面
import 'card/cards_view.dart' as cv;
import 'explore/explore_view.dart';
import 'settings/settings_view.dart';
// 社群
import 'social/social_feed_page.dart';
// 使用者設定（放在 More）
import 'user/user_profile_settings_page.dart';
// 統計頁
import 'statistics/statistics_view.dart';
// 圖鑑頁
import 'dex/dex_view.dart';

import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

// 訂閱方案列舉：先寫死用
enum SubscriptionPlan { free, basic, pro, plus }

IconData subscriptionIconOf(SubscriptionPlan p) {
  switch (p) {
    case SubscriptionPlan.free:
      return Icons.card_giftcard_outlined; // ← 換新 icon
    case SubscriptionPlan.basic:
      return Icons.star_border;
    case SubscriptionPlan.pro:
      return Icons.workspace_premium_outlined;
    case SubscriptionPlan.plus:
      return Icons.diamond_outlined;
  }
}

String subscriptionLabelOf(BuildContext context, SubscriptionPlan p) {
  final l = context.l10n;
  switch (p) {
    case SubscriptionPlan.free:
      return l.plan_free;
    case SubscriptionPlan.basic:
      return l.plan_basic;
    case SubscriptionPlan.pro:
      return l.plan_pro;
    case SubscriptionPlan.plus:
      return l.plan_plus;
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<RootNav> createState() => _RootNavState();
}

// More 容器顯示哪個子頁
enum MoreMode { settings, user, stats, dex }

class _RootNavState extends State<RootNav> {
  // 頁籤索引：0 Cards、1 Social、2 Explore、3 More
  static const int _kMoreHostIndex = 3;

  // 目前方案（先寫死）
  final SubscriptionPlan _currentPlan = SubscriptionPlan.free; // ← 先寫死

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _moreSheetCtrl;

  int _index = 0;
  MoreMode _moreMode = MoreMode.settings; // 預設 Settings

  final GlobalKey _socialKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final double navBarHeight = kIsWeb ? 90 : 64; // Web 稍微高一點

    return WillPopScope(
      onWillPop: () async {
        // Android 返回鍵：若 More sheet 開著就先關閉
        if (_moreSheetCtrl != null) {
          _closeMoreSheetIfOpen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: kIsWeb
            ? null
            : AppBar(
                centerTitle: true,
                toolbarHeight: 3,
                automaticallyImplyLeading: false, // 不顯示返回鍵
              ),

        // ====== 內容區外層包 GestureDetector：點任何非 More 區域即收回 ======
        body: GestureDetector(
          behavior: HitTestBehavior.translucent, // 透明區也吃點擊
          onTap: () {
            if (_moreSheetCtrl != null) _closeMoreSheetIfOpen();
          },
          onPanDown: (_) {
            // 手指一碰畫面就收（避免只在 onTap 才觸發）
            if (_moreSheetCtrl != null) _closeMoreSheetIfOpen();
          },
          child: IndexedStack(
            index: _index,
            children: [
              cv.CardsView(settings: widget.settings), // 0
              SocialFeedPage(key: _socialKey, settings: widget.settings), // 1
              const ExploreView(), // 2
              _MoreHost(
                // 3
                settings: widget.settings,
                mode: _moreMode,
                profileKey: _profileKey,
                onRequestMode: _handleRequestMode, // 讓 Settings 內部要求切頁
              ),
            ],
          ),
        ),

        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: paddingBottom > 0 ? 0 : 0),
          child: NavigationBar(
            height: navBarHeight,
            selectedIndex: _index == _kMoreHostIndex ? 3 : _index,
            onDestinationSelected: (i) async {
              // 切頁前，先把小選單收起來
              await _closeMoreSheetIfOpen();

              if (i == 0 || i == 2) {
                setState(() => _index = i);
                return;
              }
              if (i == 1) {
                setState(() => _index = 1);
                final s = _socialKey.currentState as dynamic;
                await s?.refreshOnEnter();
                return;
              }
              if (i == 3) {
                await _openMoreMenu(context);
                return;
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.grid_view_outlined),
                selectedIcon: const Icon(Icons.grid_view),
                label: context.l10n.navCards,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: context.l10n.navSocial,
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: context.l10n.navExplore,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz_outlined),
                selectedIcon: const Icon(Icons.more_horiz),
                label: context.l10n.navMore,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Bottom sheet (不覆蓋 NavigationBar) ======

  Future<void> _openMoreMenu(BuildContext context) async {
    final l = context.l10n;

    await _closeMoreSheetIfOpen();

    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState == null) return;

    final controller = scaffoldState.showBottomSheet(
      (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          top: false,
          child: Material(
            elevation: 8,
            color: cs.surface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, bottom: 8),
                    decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(999)),
                  ),
                  SubscriptionFishbowlTile(
                    plan: _currentPlan,
                    onTap: () async {
                      await _closeMoreSheetIfOpen();
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPage()));
                    },
                  ),
                  // Settings
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(l.navSettings),
                    onTap: () => _onPickMore(MoreMode.settings),
                  ),
                  // User Profile
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(l.userProfileTitle),
                    onTap: () => _onPickMore(MoreMode.user),
                  ),
                  // Statistics
                  ListTile(
                    leading: const Icon(Icons.insights_outlined),
                    title: Text(l.stats_title),
                    onTap: () => _onPickMore(MoreMode.stats),
                  ),
                  // Dex
                  ListTile(
                    leading: const Icon(Icons.auto_awesome_mosaic_outlined),
                    title: Text(l.navDex),
                    onTap: () => _onPickMore(MoreMode.dex),
                  ),

                  // Billing / Subscription
                  // ListTile(
                  //   leading: Icon(subscriptionIconOf(_currentPlan)),
                  //   title: Text('訂閱與付款（${subscriptionLabelOf(_currentPlan)}）'),
                  //   onTap: () async {
                  //     await _closeMoreSheetIfOpen();
                  //     if (!mounted) return;
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (_) => const SubscriptionPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    setState(() {
      _moreSheetCtrl = controller; // 保存 controller
    });

    _moreSheetCtrl?.closed.then((_) {
      if (mounted) {
        setState(() => _moreSheetCtrl = null);
      } else {
        _moreSheetCtrl = null;
      }
    });
  }

  Future<void> _closeMoreSheetIfOpen() async {
    final c = _moreSheetCtrl;
    if (c != null) {
      c.close(); // 等關閉動畫完整結束，避免 race
      _moreSheetCtrl = null;
    }
  }

  Future<void> _onPickMore(MoreMode picked) async {
    await _closeMoreSheetIfOpen();
    await _handleRequestMode(picked);
  }

  Future<void> _handleRequestMode(MoreMode m) async {
    setState(() {
      _moreMode = m;
      _index = _kMoreHostIndex;
    });
    if (m == MoreMode.user) {
      final p = _profileKey.currentState as dynamic;
      await p?.refreshOnEnter();
    }
  }
}

// ================= More 容器 =================

class _MoreHost extends StatelessWidget {
  const _MoreHost({required this.settings, required this.mode, required this.profileKey, required this.onRequestMode});

  final AppSettings settings;
  final MoreMode mode; // 直接帶入當前 mode
  final GlobalKey profileKey;
  final void Function(MoreMode) onRequestMode; // 讓內部頁面可要求切換

  int _modeToIndex(MoreMode m) {
    switch (m) {
      case MoreMode.settings:
        return 0;
      case MoreMode.user:
        return 1;
      case MoreMode.stats:
        return 2;
      case MoreMode.dex:
        return 3;
    }
  }

  // String _titleForMode(BuildContext context, MoreMode m) {
  //   final l = context.l10n;
  //   switch (m) {
  //     case MoreMode.settings:
  //       return l.navSettings;
  //     case MoreMode.user:
  //       return l.userProfileTitle;
  //     case MoreMode.stats:
  //       return l.stats_title;
  //     case MoreMode.dex:
  //       return l.navDex;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final index = _modeToIndex(mode);

    final pages = <Widget>[
      // Settings：把「使用者設定」卡點擊 -> 交回 RootNav 切換
      SettingsView(settings: settings, onOpenUserProfile: () => onRequestMode(MoreMode.user)),
      // User profile
      UserProfileSettingsPage(key: profileKey, settings: settings),
      // Statistics
      StatisticsView(settings: settings),
      // Dex
      const DexView(),
    ];

    if (kIsWeb) {
      return IndexedStack(index: index, children: pages);
    }
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              centerTitle: true,
              toolbarHeight: 3,
              automaticallyImplyLeading: false, // 不顯示返回鍵
            ),
      body: IndexedStack(index: index, children: pages),
    );
  }
}

class _PlanPalette {
  final List<Color> gradient;
  final Color fg; // 前景：文字/箭頭/圖示
  final Color badgeBg; // Badge 背景
  const _PlanPalette(this.gradient, this.fg, this.badgeBg);
}

_PlanPalette _paletteFor(SubscriptionPlan p) {
  switch (p) {
    case SubscriptionPlan.free:
      // 薄荷清爽
      return const _PlanPalette([Color(0xFFB2F5EA), Color(0xFF81E6D9)], Color(0xFF004D40), Color(0xFF26A69A));
    case SubscriptionPlan.basic:
      // 橘黃朝氣
      return const _PlanPalette([Color(0xFFFFE082), Color(0xFFFFC107)], Color(0xFF4E342E), Color(0xFFFFA000));
    case SubscriptionPlan.pro:
      // 藍紫專業
      return const _PlanPalette([Color(0xFFB39DDB), Color(0xFF7E57C2)], Color(0xFF1A237E), Color(0xFF5E35B1));
    case SubscriptionPlan.plus:
      // 粉桃高級
      return const _PlanPalette([Color(0xFFFFCDD2), Color(0xFFF48FB1)], Color(0xFF880E4F), Color(0xFFD81B60));
  }
}

class _SubscriptionBadgeTile extends StatelessWidget {
  const _SubscriptionBadgeTile({required this.plan, required this.onTap});

  final SubscriptionPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = subscriptionLabelOf(context, plan);
    final icon = subscriptionIconOf(plan);

    final palette = _paletteFor(plan);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          leading: Badge(
            backgroundColor: palette.badgeBg,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // 上下更窄
            offset: const Offset(-2, 0),
            label: const Text(
              '', // 先給空，下面用 Stack 疊文字（可保留，也可直接用這個 label）
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: palette.fg),
                // 也可以僅用 Badge 的 label，不疊這層；這裡示範保持小巧
                Positioned(
                  right: -6,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: palette.badgeBg, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11, // 字稍大
                        fontWeight: FontWeight.w700,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            l.billing_title, // i18n
            style: TextStyle(color: palette.fg, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            l.billing_current_plan(label),
            style: TextStyle(color: palette.fg.withOpacity(0.85), fontSize: 13.5),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: palette.fg),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

// ==== REPLACE from here: SubscriptionFishbowlTile with themed bowl ====

class SubscriptionFishbowlTile extends StatefulWidget {
  const SubscriptionFishbowlTile({super.key, required this.plan, required this.onTap});
  final SubscriptionPlan plan;
  final VoidCallback onTap;

  @override
  State<SubscriptionFishbowlTile> createState() => _SubscriptionFishbowlTileState();
}

class _SubscriptionFishbowlTileState extends State<SubscriptionFishbowlTile> with SingleTickerProviderStateMixin {
  double _tiltRad = 0.0; // 水平面旋轉（弧度）
  late final AnimationController _anim; // 同時驅動漂浮與波浪
  StreamSubscription? _accSub;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat();

    _accSub = accelerometerEvents.listen((e) {
      final angle = math.atan2(e.x, -e.y).clamp(-math.pi / 18, math.pi / 18);
      setState(() => _tiltRad = angle.toDouble());
    });
  }

  @override
  void dispose() {
    _accSub?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = subscriptionLabelOf(context, widget.plan);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 依方案取對應「尊榮主題」
    final t = _themeForPlan(widget.plan, isDark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: t.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.40 : 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              return Stack(
                children: [
                  // 玻璃外框（Plus 等級加金邊）
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GlassPainter(
                        (t.goldEdge ?? false)
                            ? const Color(0xFFFFD54F).withOpacity(isDark ? .55 : .45)
                            : t.fg.withOpacity(isDark ? .22 : .18),
                      ),
                    ),
                  ),

                  // ======= 水體（會傾斜）＋ 波浪 =======
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.hardEdge,
                      child: Transform.rotate(
                        angle: _tiltRad,
                        child: Transform.scale(
                          alignment: Alignment.bottomCenter,
                          scaleX: 1.2,
                          scaleY: 1.3,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: t.waterHeightFactor,
                              widthFactor: 2.2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 水底色
                                    Container(color: t.waterColor),
                                    // 波浪層們
                                    CustomPaint(
                                      painter: _WavePainter(
                                        progress: _anim.value,
                                        amplitude: t.waveAmp1,
                                        wavelength: t.waveLen1,
                                        speed: 1.0,
                                        color: Colors.white.withOpacity(t.waveAlpha1),
                                      ),
                                    ),
                                    CustomPaint(
                                      painter: _WavePainter(
                                        progress: (_anim.value + .35) % 1.0,
                                        amplitude: t.waveAmp2,
                                        wavelength: t.waveLen2,
                                        speed: 1.6,
                                        color: Colors.white.withOpacity(t.waveAlpha2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ======= 浮動尊榮物件（依方案變化） =======
                  ..._buildTierItems(t, _anim, _tiltRad),

                  // 左上徽章 + 圖示
                  Positioned(
                    left: 12,
                    top: 10,
                    child: Badge(
                      backgroundColor: t.badgeBg,
                      label: Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                      child: Icon(subscriptionIconOf(widget.plan), color: t.fg),
                    ),
                  ),

                  // 文案
                  Positioned(
                    left: 16,
                    bottom: 14,
                    right: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.billing_title,
                          style: TextStyle(color: t.fg, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.billing_current_plan(label),
                          style: TextStyle(color: t.fg.withOpacity(0.9), fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),

                  // 右側箭頭
                  Positioned(
                    right: 10,
                    bottom: 12,
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: t.fg),
                  ),

                  // Plus / Pro：星芒微光
                  if (t.sparkles > 0)
                    Positioned.fill(
                      child: _SparklesLayer(
                        anim: _anim,
                        count: t.sparkles,
                        color: (t.goldEdge ?? false)
                            ? const Color(0xFFFFF59D).withOpacity(0.9)
                            : Colors.white.withOpacity(0.8),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTierItems(_BowlTheme t, Animation<double> anim, double tilt) {
    final items = <Widget>[];

    for (final it in t.items) {
      if (it.type == _BowlItemType.emoji) {
        items.add(
          _FloatingEmoji(
            emoji: it.emoji!,
            baseBottom: it.bottom + math.sin(anim.value * 2 * math.pi) * it.floatAmp,
            anim: anim,
            tilt: tilt * it.tiltFactor,
            fgShadow: it.shadow,
          ),
        );
      } else if (it.type == _BowlItemType.beachBall) {
        items.add(
          _BeachBall(
            bottom: it.bottom + math.sin(anim.value * 2 * math.pi) * it.floatAmp,
            right: it.right,
            tilt: tilt * it.tiltFactor,
            size: it.size,
            shadow: it.shadow,
          ),
        );
      }
    }

    return items;
  }
}

// ---- Theme model & presets ----

enum _BowlItemType { emoji, beachBall }

class _BowlItem {
  final _BowlItemType type;
  final String? emoji; // for emoji type
  final double bottom;
  final double right;
  final double size;
  final double floatAmp;
  final double tiltFactor;
  final bool shadow;

  const _BowlItem.emoji({
    required this.emoji,
    required this.bottom,
    required this.right,
    this.size = 22,
    this.floatAmp = 2.0,
    this.tiltFactor = 0.4,
    this.shadow = true,
  }) : type = _BowlItemType.emoji;

  const _BowlItem.ball({
    required this.bottom,
    required this.right,
    this.size = 18,
    this.floatAmp = 2.5,
    this.tiltFactor = 0.35,
    this.shadow = true,
  }) : type = _BowlItemType.beachBall,
       emoji = null;
}

class _BowlTheme {
  final List<Color> gradient;
  final Color fg;
  final Color badgeBg;

  final Color waterColor;
  final double waterHeightFactor;

  final double waveAmp1;
  final double waveAmp2;
  final double waveLen1;
  final double waveLen2;
  final double waveAlpha1;
  final double waveAlpha2;

  final bool? goldEdge; // plus 用金邊
  final int sparkles; // 星芒粒子數
  final List<_BowlItem> items;

  const _BowlTheme({
    required this.gradient,
    required this.fg,
    required this.badgeBg,
    required this.waterColor,
    required this.waterHeightFactor,
    required this.waveAmp1,
    required this.waveAmp2,
    required this.waveLen1,
    required this.waveLen2,
    required this.waveAlpha1,
    required this.waveAlpha2,
    this.goldEdge,
    this.sparkles = 0,
    this.items = const [],
  });
}

_BowlTheme _themeForPlan(SubscriptionPlan p, bool isDark) {
  switch (p) {
    case SubscriptionPlan.free:
      return _BowlTheme(
        gradient: isDark ? const [Color(0xFF2E7D71), Color(0xFF1B5E57)] : const [Color(0xFFB2F5EA), Color(0xFF81E6D9)],
        fg: isDark ? Colors.white : const Color(0xFF004D40),
        badgeBg: const Color(0xFF26A69A),
        waterColor: (isDark ? const Color(0xFF1B5E57) : const Color(0xFFA7F3D0)).withOpacity(isDark ? 0.28 : 0.22),
        waterHeightFactor: 0.60,
        waveAmp1: 4.5,
        waveAmp2: 3.0,
        waveLen1: 120.0,
        waveLen2: 90.0,
        waveAlpha1: isDark ? .16 : .20,
        waveAlpha2: isDark ? .10 : .14,
        sparkles: 0,
        items: const [
          _BowlItem.emoji(emoji: '🦆', bottom: 38, right: 18),
          _BowlItem.ball(bottom: 26, right: 54),
        ],
      );

    case SubscriptionPlan.basic:
      return _BowlTheme(
        gradient: isDark ? const [Color(0xFF6D4C00), Color(0xFF8D6E00)] : const [Color(0xFFFFE082), Color(0xFFFFC107)],
        fg: isDark ? const Color(0xFFFFF3E0) : const Color(0xFF4E342E),
        badgeBg: const Color(0xFFFFA000),
        waterColor: (isDark ? const Color(0xFF5D4037) : const Color(0xFFFFECB3)).withOpacity(isDark ? 0.30 : 0.22),
        waterHeightFactor: 0.62,
        waveAmp1: 5.0,
        waveAmp2: 3.2,
        waveLen1: 115.0,
        waveLen2: 88.0,
        waveAlpha1: isDark ? .18 : .22,
        waveAlpha2: isDark ? .12 : .16,
        sparkles: 2,
        items: const [
          _BowlItem.emoji(emoji: '🐠', bottom: 36, right: 26, floatAmp: 2.6),
          _BowlItem.emoji(emoji: '🪸', bottom: 18, right: 64, floatAmp: 1.2, tiltFactor: 0.2, shadow: false),
        ],
      );

    case SubscriptionPlan.pro:
      return _BowlTheme(
        gradient: isDark ? const [Color(0xFF3B1E6D), Color(0xFF6B3FA4)] : const [Color(0xFFB39DDB), Color(0xFF7E57C2)],
        fg: isDark ? Colors.white : const Color(0xFF1A237E),
        badgeBg: const Color(0xFF5E35B1),
        waterColor: (isDark ? const Color(0xFF4527A0) : const Color(0xFFC7B6F5)).withOpacity(isDark ? 0.32 : 0.24),
        waterHeightFactor: 0.64,
        waveAmp1: 5.4,
        waveAmp2: 3.4,
        waveLen1: 110.0,
        waveLen2: 85.0,
        waveAlpha1: isDark ? .20 : .24,
        waveAlpha2: isDark ? .12 : .16,
        sparkles: 6,
        items: const [
          _BowlItem.emoji(emoji: '🐟', bottom: 36, right: 32, floatAmp: 3.0),
          _BowlItem.emoji(emoji: '💎', bottom: 22, right: 66, floatAmp: 1.6, size: 20, tiltFactor: 0.15),
        ],
      );

    case SubscriptionPlan.plus:
      return _BowlTheme(
        gradient: isDark ? const [Color(0xFF2A1648), Color(0xFF4A2A7A)] : const [Color(0xFFE1BEE7), Color(0xFFD1C4E9)],
        fg: isDark ? Colors.white : const Color(0xFF2C1B45),
        badgeBg: const Color(0xFFD81B60),
        waterColor: (isDark ? const Color(0xFF311B92) : const Color(0xFFEADCFB)).withOpacity(isDark ? 0.36 : 0.26),
        waterHeightFactor: 0.68, // 水更「厚」
        waveAmp1: 6.0,
        waveAmp2: 3.8,
        waveLen1: 105.0,
        waveLen2: 82.0,
        waveAlpha1: isDark ? .24 : .26,
        waveAlpha2: isDark ? .14 : .18,
        goldEdge: true,
        sparkles: 12, // 更多星芒
        items: const [
          _BowlItem.emoji(emoji: '👑', bottom: 40, right: 28, floatAmp: 2.2, size: 24),
          _BowlItem.emoji(emoji: '💎', bottom: 26, right: 60, floatAmp: 1.8, size: 22, tiltFactor: 0.2),
        ],
      );
  }
}

// ---- Sparkles: 星芒微光層 ----
class _SparklesLayer extends StatelessWidget {
  const _SparklesLayer({required this.anim, required this.count, required this.color});
  final Animation<double> anim;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SparklesPainter(progress: anim.value, count: count, color: color),
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  _SparklesPainter({required this.progress, required this.count, required this.color});
  final double progress;
  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7); // 固定種子，位置穩定、亮度閃爍
    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = (rnd.nextDouble() * size.height * .55) + size.height * .25;
      final phase = (progress + i * 0.13) % 1.0;
      final alpha = (0.4 + 0.6 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi)));
      final r = 1.2 + (i % 3) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(alpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) =>
      old.progress != progress || old.count != count || old.color != color;
}

// ==== REPLACE until here ====

class _GlassPainter extends CustomPainter {
  final Color stroke;
  _GlassPainter(this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = stroke;
    canvas.drawRRect(r, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldDelegate) => oldDelegate.stroke != stroke;
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.progress, // 0~1
    required this.amplitude, // 波幅(像素)
    required this.wavelength, // 波長(像素)
    required this.speed, // 速度倍率
    required this.color,
  });

  final double progress;
  final double amplitude;
  final double wavelength;
  final double speed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path();
    final midY = size.height * .45; // 基線
    final phase = progress * 2 * math.pi * speed;

    p.moveTo(0, size.height);
    p.lineTo(0, midY);

    for (double x = 0; x <= size.width; x += 1) {
      final y = midY + math.sin((x / wavelength) * 2 * math.pi + phase) * amplitude;
      p.lineTo(x, y);
    }

    p.lineTo(size.width, size.height);
    p.close();

    final paint = Paint()..color = color;
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.amplitude != amplitude ||
      old.wavelength != wavelength ||
      old.speed != speed;
}

class _FloatingEmoji extends StatelessWidget {
  const _FloatingEmoji({
    required this.emoji,
    required this.baseBottom,
    required this.anim,
    required this.tilt,
    this.fgShadow = false,
  });

  final String emoji;
  final double baseBottom;
  final Animation<double> anim;
  final double tilt;
  final bool fgShadow;

  @override
  Widget build(BuildContext context) {
    final bobY = math.sin(anim.value * 2 * math.pi) * 2.0;
    return Positioned(
      right: 18,
      bottom: baseBottom + bobY,
      child: Transform.rotate(
        angle: tilt * 0.4,
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 22,
            shadows: fgShadow
                ? [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: const Offset(0, 1))]
                : const [],
          ),
        ),
      ),
    );
  }
}

/// 自繪海灘球（紅黃藍白的扇形）
class _BeachBall extends StatelessWidget {
  const _BeachBall({
    super.key,
    required this.bottom,
    required this.right,
    required this.tilt,
    this.size = 18,
    this.shadow = true,
  });

  final double bottom;
  final double right;
  final double tilt;
  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: tilt,
        child: CustomPaint(
          size: Size.square(size),
          painter: _BeachBallPainter(shadow: shadow),
        ),
      ),
    );
  }
}

class _BeachBallPainter extends CustomPainter {
  _BeachBallPainter({this.shadow = true});
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    if (shadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(center, r * .9, shadowPaint);
    }

    // 4 片彩色扇形
    final slices = <Color>[
      const Color(0xFFE53935), // 紅
      const Color(0xFFFFEB3B), // 黃
      const Color(0xFF1E88E5), // 藍
      const Color(0xFFFFFFFF), // 白
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      paint.color = slices[i];
      canvas.drawArc(Rect.fromCircle(center: center, radius: r * .9), i * (math.pi / 2), math.pi / 2, true, paint);
    }

    // 白色高光
    final hl = Paint()..color = Colors.white.withOpacity(.8);
    canvas.drawCircle(center, r * .18, hl);
  }

  @override
  bool shouldRepaint(covariant _BeachBallPainter oldDelegate) => false;
}
