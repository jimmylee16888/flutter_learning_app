import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, bottom: 8),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
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
  const _MoreHost({
    required this.settings,
    required this.mode,
    required this.profileKey,
    required this.onRequestMode,
  });

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

  String _titleForMode(BuildContext context, MoreMode m) {
    final l = context.l10n;
    switch (m) {
      case MoreMode.settings:
        return l.navSettings;
      case MoreMode.user:
        return l.userProfileTitle;
      case MoreMode.stats:
        return l.stats_title;
      case MoreMode.dex:
        return l.navDex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _modeToIndex(mode);

    final pages = <Widget>[
      // Settings：把「使用者設定」卡點擊 -> 交回 RootNav 切換
      SettingsView(
        settings: settings,
        onOpenUserProfile: () => onRequestMode(MoreMode.user),
      ),
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
