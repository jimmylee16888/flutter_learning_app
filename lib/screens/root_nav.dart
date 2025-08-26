import 'package:flutter/material.dart';
import '../app_settings.dart';
import 'cards_view.dart';
import 'explore_view.dart';
import 'settings_view.dart';

class RootNav extends StatefulWidget {
  const RootNav({
    super.key,
    required this.cards,
    required this.settings, // ← 建構子接進來
  });

  final List<Widget> cards;
  final AppSettings settings;

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  // 用 late final，在 initState 只指定一次即可
  late final List<Widget> _pages;

  final _titles = const ['Cards', 'Explore', 'Settings'];

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      CardsView(cards: widget.cards),
      const ExploreView(),
      SettingsView(settings: widget.settings), // ← 傳入 settings
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      // IndexedStack 可保留各分頁狀態
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Cards',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
