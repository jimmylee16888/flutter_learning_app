// lib/screens/settings/about_developer_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart'; // ← 取用 AppSettings（若未掛上也不會崩）
import '../../l10n/l10n.dart';
import 'settings_view.dart'; // kDeveloperName... kDeveloperEmail...
import 'easter_egg/version_showcase_page.dart';
import '../../models/card_item.dart';
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';

// dev mode 相關
import '../../services/dev_mode.dart'; // ← 新增

class AboutDeveloperPage extends StatefulWidget {
  const AboutDeveloperPage({super.key});

  @override
  State<AboutDeveloperPage> createState() => _AboutDeveloperPageState();
}

class _AboutDeveloperPageState extends State<AboutDeveloperPage> {
  String _versionText = '';
  bool _devEnabled = false; // ← 新增

  Timer? _holdTimer;
  DateTime? _holdStartAt;
  static const Duration _devHold = Duration(seconds: 10);

  // 版本彩蛋：連點 7 次（將間隔放寬到 1.2 秒）
  static const int _tapThreshold = 7;
  static const Duration _resetAfter = Duration(milliseconds: 1200);
  int _tapCount = 0;
  DateTime? _lastTapAt;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadDevMode();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onHoldStart(LongPressStartDetails d) {
    _holdStartAt = DateTime.now();

    _holdTimer?.cancel();
    _holdTimer = Timer(_devHold, () async {
      // 時間到 → 切換 DevMode
      final next = await DevMode.toggle();
      if (!mounted) return;
      setState(() => _devEnabled = next);

      // 觸覺回饋（可選）
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next ? '✅ 開發者模式已開啟' : '🛑 開發者模式已關閉')),
      );
    });
  }

  // 長按結束：若未滿 10 秒就取消，並提示還差多久
  void _onHoldEnd(LongPressEndDetails d) {
    if (_holdTimer?.isActive == true) {
      final held = DateTime.now().difference(_holdStartAt!);
      final remain = _devHold - held;
      _holdTimer?.cancel();

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('長按不足 10 秒（還差 ${remain.inSeconds} 秒）')),
      // );
    }
    _holdStartAt = null;
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version;
      final b = info.buildNumber;
      final text = b.isNotEmpty ? '$v+$b' : v;
      if (!mounted) return;
      setState(() => _versionText = text);
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('PackageInfo error: $e\n$s');
      }
    }
  }

  Future<void> _loadDevMode() async {
    final on = await DevMode.isEnabled();
    if (!mounted) return;
    setState(() => _devEnabled = on);
  }

  // void _openShowcase() {
  //   // 取得卡片清單（若 Provider 未掛上，改成空清單也照樣進頁）
  //   List<CardItem> cards;
  //   try {
  //     cards = List<CardItem>.from(context.read<AppSettings>().cardItems);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       debugPrint('AppSettings Provider not found, use empty cards. $e');
  //     }
  //     cards = const [];
  //   }

  //   if (kDebugMode) {
  //     debugPrint(
  //       'NAV -> VersionShowcasePage (cards: ${cards.length}, version: $_versionText)',
  //     );
  //   }

  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => VersionShowcasePage(
  //         versionText: _versionText.isEmpty ? '—' : _versionText,
  //         cards: cards,
  //       ),
  //     ),
  //   );
  // }
  // lib/screens/settings/about_developer_page.dart

  void _openShowcase() {
    // 1) 先用 MiniCardStore 的小卡（你在 main.dart 有掛 Provider 且已 hydrate）
    List<CardItem> cards = [];
    try {
      final store = context.read<MiniCardStore>();
      final minis = store.allCards(); // List<MiniCardData>

      cards = minis.map((m) {
        // 取圖邏輯：front 優先，其次 back
        final imgUrl = (m.imageUrl?.isNotEmpty == true)
            ? m.imageUrl
            : (m.backImageUrl?.isNotEmpty == true ? m.backImageUrl : null);
        final lp = (m.localPath?.isNotEmpty == true)
            ? m.localPath
            : (m.backLocalPath?.isNotEmpty == true ? m.backLocalPath : null);

        return CardItem(
          id: m.id,
          title: m.name ?? (m.serial ?? 'Card'),
          imageUrl: imgUrl,
          localPath: lp,
          quote: m.note,
          categories: m.tags,
          birthday: null,
        );
      }).toList();
    } catch (_) {
      // 沒掛 MiniCardStore 也沒關係，下面會退回 AppSettings
    }

    // 2) 若沒取到，再退回 AppSettings（舊的藝人卡）
    if (cards.isEmpty) {
      try {
        final cs = context.read<CardItemStore>();
        cards = List<CardItem>.from(cs.cardItems);
      } catch (_) {}
    }

    // 3) 進版本展示頁（就算空清單也會顯示版本與 fallback）
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VersionShowcasePage(
          versionText: _versionText.isEmpty ? '—' : _versionText,
          codeName: 'Wave', // ← 底部要顯示的名稱
          cards: cards,
        ),
      ),
    );
  }

  void _onVersionTapped() {
    final now = DateTime.now();
    if (_lastTapAt == null || now.difference(_lastTapAt!) > _resetAfter) {
      _tapCount = 0;
    }
    _lastTapAt = now;
    _tapCount++;

    if (_tapCount >= _tapThreshold) {
      _tapCount = 0;
      if (!mounted) return;
      _openShowcase();
    } else {
      final left = _tapThreshold - _tapCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('再點 $left 下可開啟版本彩蛋！'),
          duration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
                    backgroundColor: color.surfaceVariant,
                    child: const Icon(Icons.person_outline, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.nameWithPinyin(
                            kDeveloperName,
                            kDeveloperNamePinyin,
                          ),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.developerRole,
                          style: text.bodyMedium?.copyWith(
                            color: color.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('Flutter')),
                            // Chip(label: Text('Open Source')),
                            Chip(label: Text('Side Project')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Hello card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waving_hand),
                      const SizedBox(width: 8),
                      Text(l.helloDeveloperTitle, style: text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    l.helloDeveloperBody,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— $kDeveloperName',
                      style: text.bodySmall?.copyWith(color: color.outline),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Contact / Version（版本可點擊觸發彩蛋；長按直接進）
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(l.emailLabel),
                  subtitle: const Text(kDeveloperEmail),
                  onTap: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: kDeveloperEmail),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied')),
                      );
                    }
                  },
                ),
                const Divider(height: 0),
                GestureDetector(
                  onTap: _onVersionTapped, // 快速連點 7 下 → 進彩蛋
                  onLongPressStart: _onHoldStart, // 長按開始 → 開始 10 秒倒數
                  onLongPressEnd: _onHoldEnd, // 長按結束 → 不足 10 秒則提示還差多久
                  child: ListTile(
                    leading: Icon(
                      _devEnabled ? Icons.bug_report : Icons.code_outlined,
                    ),
                    title: Text(l.versionLabel),
                    subtitle: Text(
                      [_versionText.isEmpty ? '—' : _versionText].join('\n'),
                    ),
                    trailing: _devEnabled
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiary.withOpacity(.18),
                            ),
                            child: const Text('DEVELOPER'),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
