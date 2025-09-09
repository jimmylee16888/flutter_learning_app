import 'package:flutter/material.dart';
import '../app_settings.dart';
import 'card/cards_view.dart' as cv;
import 'explore/explore_view.dart';
import 'settings/settings_view.dart';
import '../l10n/l10n.dart';
import 'social/social_feed_page.dart'; // ← 新增這行

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
      cv.CardsView(settings: widget.settings),
      SocialFeedPage(settings: widget.settings),
      const ExploreView(),
      SettingsView(settings: widget.settings),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    String currentTitle() {
      switch (_index) {
        case 0:
          return l.navCards;
        case 1:
          return 'Social'; // 先寫死字串；要 i18n 可再加 l.navSocial
        case 2:
          return l.navExplore;
        case 3:
        default:
          return l.navSettings;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(currentTitle())),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l.navCards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l.navSocial, // ← 用 i18n
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: l.navExplore,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
