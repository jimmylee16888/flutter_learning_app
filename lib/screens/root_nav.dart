// lib/screens/root_nav.dart
import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/l10n.dart';

// 既有頁面
import 'card/cards_view.dart' as cv;
import 'explore/explore_view.dart';
import 'settings/settings_view.dart';

// 新增的社群動態
import 'social/social_feed_page.dart';

// 個人檔案（可編輯）— 使用你現有的設定頁中的編輯頁
import 'user/user_profile_settings_page.dart';

class RootNav extends StatefulWidget {
  const RootNav({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      cv.CardsView(settings: widget.settings), // 0
      SocialFeedPage(settings: widget.settings), // 1
      const ExploreView(), // 2
      UserProfileSettingsPage(settings: widget.settings), // 3 個人檔案（可編輯）
      SettingsView(settings: widget.settings), // 4 只讀設定（不再編輯個資）
    ];
  }

  String _currentTitle(BuildContext context) {
    final l = context.l10n;
    switch (_index) {
      case 0:
        return l.navCards;
      case 1:
        return l.navSocial;
      case 2:
        return l.navExplore;
      case 3:
        return l.userProfileTitle;
      case 4:
      default:
        return l.navSettings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentTitle(context);
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Padding(
        // 讓左下角兩顆 FAB（在社群頁）不會被 NavBar 蓋住
        padding: EdgeInsets.only(bottom: paddingBottom > 0 ? 0 : 0),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
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
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: context.l10n.userProfileTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
