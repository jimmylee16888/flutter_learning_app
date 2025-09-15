// lib/screens/statistics/statistics_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:provider/provider.dart';
import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import '../../models/card_item.dart';
import '../../models/mini_card_data.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  // 0 = 總覽頁、1..N = 第 i 位藝人
  late final PageController _artistPager;
  int _artistPage = 0;

  @override
  void initState() {
    super.initState();
    _artistPager = PageController();
  }

  @override
  void dispose() {
    _artistPager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // 來源
    final artists = widget.settings.cardItems; // List<CardItem>
    final store = context.watch<MiniCardStore>(); // owner -> List<MiniCardData>
    final allCards = store.allCards();

    // 目前是否選到某位藝人（_artistPage: 0=總覽，>0=第 n 位藝人）
    final CardItem? selectedArtist = _artistPage > 0
        ? artists[_artistPage - 1]
        : null;

    // 依選取的藝人決定要統計哪一批卡
    final List<MiniCardData> scopedCards = selectedArtist == null
        ? allCards
        : store.forOwner(selectedArtist.title);

    // KPI（總覽數字仍用全域）
    final artistCount = artists.length;
    final totalCards = allCards.length;

    // 本地/網址（跟著選取的藝人或全域）
    final (frontLocalCount, frontUrlCount) = _frontCounts(scopedCards);

    // 顯示在卡片上的區塊標題（若有選藝人，標題後面加上名字）
    final frontSourceTitle = selectedArtist == null
        ? l.stats_front_source
        : '${l.stats_front_source} · ${selectedArtist.title}';

    // 各藝人小卡數（用 owner=藝人名）
    final Map<String, int> cardsPerArtist = {
      for (final a in artists) a.title: store.forOwner(a.title).length,
    };
    final top5 = _topN(cardsPerArtist, 5);

    return Scaffold(
      appBar: AppBar(title: Text(l.stats_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            title: l.stats_overview,
            icon: Icons.dashboard_customize_outlined,
          ),
          const SizedBox(height: 12),

          // ===== Dashboard KPI（方形卡片） =====
          _KPIGridDashboard(
            tiles: [
              // 左上：藝人數 可左右滑動（Summary + 每位藝人）
              _KPIArtistPagerTile(
                title: l.stats_artist_count,
                artists: artists,
                store: store,
                pager: _artistPager,
                onPageChanged: (p) => setState(() => _artistPage = p),
              ),
              // 右上：小卡總數
              _KPISimpleTile(
                title: l.stats_card_total,
                value: '$totalCards',
                icon: Icons.style_outlined,
              ),
              // 左下：正面來源 - 本地
              _KPISimpleTile(
                title: l.common_local,
                value: '$frontLocalCount',
                icon: Icons.sd_card,
              ),
              // 右下：正面來源 - 網址
              _KPISimpleTile(
                title: l.common_url,
                value: '$frontUrlCount',
                icon: Icons.link_outlined,
              ),
            ],
          ),

          // 當藝人卡片被滑到某位藝人（_artistPage > 0）→ 顯示照片區
          if (_artistPage > 0) ...[
            const SizedBox(height: 8),
            _ArtistPreviewStrip(artist: artists[_artistPage - 1]),
          ],

          const SizedBox(height: 16),

          // _Header(
          //   title: frontSourceTitle, // ← 改這行
          //   icon: Icons.filter_none_outlined,
          // ),
          const SizedBox(height: 8),
          _TwoBarCard(
            leftLabel: l.common_local,
            leftValue: frontLocalCount, // ← 已改成 scoped 結果
            rightLabel: l.common_url,
            rightValue: frontUrlCount, // ← 已改成 scoped 結果
          ),

          const SizedBox(height: 16),

          if (cardsPerArtist.isNotEmpty) ...[
            _Header(
              title: l.stats_cards_per_artist_topN(5),
              icon: Icons.leaderboard_outlined,
            ),
            const SizedBox(height: 8),
            _BarChartCard(
              data: {
                for (final e in top5)
                  (e.$1.isEmpty ? l.common_unnamed : e.$1): e.$2,
              },
              unitSuffix: l.common_unit_cards, // "張/枚"
              barHeight: 24,
              maxBars: 5,
              // 不同顏色：用一組友善的色盤
              colorPalette: _nicePalette(context),
            ),
          ],
        ],
      ),
    );
  }

  List<(String, int)> _topN(Map<String, int> m, int n) {
    final list = m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list.take(n).map((e) => (e.key, e.value)).toList();
  }

  // 計算一批卡片的正面來源（本地 / 網址）
  (int, int) _frontCounts(List<MiniCardData> list) {
    final local = list
        .where(
          (c) => (c.imageUrl ?? '').isEmpty && (c.localPath ?? '').isNotEmpty,
        )
        .length;
    final url = list.where((c) => (c.imageUrl ?? '').isNotEmpty).length;
    return (local, url);
  }

  List<Color> _nicePalette(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 取幾個與主題協調的色階
    return [
      cs.primary,
      cs.tertiary,
      cs.secondary,
      cs.primaryContainer,
      cs.tertiaryContainer,
      cs.secondaryContainer,
    ];
  }
}

/// =====================
/// Dashboard：KPI 方形卡片
/// =====================

class _KPIGridDashboard extends StatelessWidget {
  const _KPIGridDashboard({required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 一排 2 個
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1, // 正方形
      ),
      itemBuilder: (_, i) => tiles[i],
    );
  }
}

/// 一般 KPI 方塊（中上小圖示、數字大、標題小）
class _KPISimpleTile extends StatelessWidget {
  const _KPISimpleTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: cs.primary),
            const Spacer(),
            Text(
              value,
              style: text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 0.95,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: text.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// 可左右滑動的「藝人數量」KPI 卡：
/// Page 0 為總覽（顯示總數），Page 1..N 為每位藝人（顯示該藝人擁有的小卡數）。
class _KPIArtistPagerTile extends StatelessWidget {
  const _KPIArtistPagerTile({
    required this.title,
    required this.artists,
    required this.store,
    required this.pager,
    required this.onPageChanged,
  });

  final String title;
  final List<CardItem> artists;
  final MiniCardStore store;
  final PageController pager;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final pages = <Widget>[];

    // Page 0：總覽
    pages.add(
      _KpiCenter(
        title: title,
        value: '${artists.length}',
        icon: Icons.people_alt_outlined,
      ),
    );

    // Page 1..N：每位藝人
    for (final a in artists) {
      final count = store.forOwner(a.title).length;
      pages.add(
        _KpiCenter(title: a.title, value: '$count', icon: Icons.person_outline),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: cs.surfaceVariant.withOpacity(0.35),
            child: PageView(
              controller: pager,
              onPageChanged: onPageChanged,
              children: pages,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiCenter extends StatelessWidget {
  const _KpiCenter({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: cs.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: text.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 0.95,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI 下方的「藝人預覽」：顯示被滑到的那位藝人的照片 + 名字
class _ArtistPreviewStrip extends StatelessWidget {
  const _ArtistPreviewStrip({required this.artist});
  final CardItem artist;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final ImageProvider? img = _artistImageProvider(artist);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img == null
                  ? Container(
                      width: 64,
                      height: 64,
                      color: cs.surfaceVariant,
                      child: const Icon(Icons.person_outline),
                    )
                  : Image(image: img, width: 64, height: 64, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                artist.title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.swipe_left_alt_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _artistImageProvider(CardItem a) {
    if ((a.localPath ?? '').isNotEmpty) {
      final f = File(a.localPath!);
      if (f.existsSync()) return FileImage(f);
    }
    if ((a.imageUrl ?? '').isNotEmpty) {
      return NetworkImage(a.imageUrl!);
    }
    return null;
  }
}

/// =====================
/// 其他統計區塊
/// =====================

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(title, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// 左右兩條簡易 bar（本地/網址）
class _TwoBarCard extends StatelessWidget {
  const _TwoBarCard({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final int leftValue;
  final String rightLabel;
  final int rightValue;

  @override
  Widget build(BuildContext context) {
    final total = (leftValue + rightValue).clamp(1, 1 << 30);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            _HBar(label: leftLabel, value: leftValue, total: total),
            const SizedBox(height: 10),
            _HBar(label: rightLabel, value: rightValue, total: total),
          ],
        ),
      ),
    );
  }
}

class _HBar extends StatelessWidget {
  const _HBar({required this.label, required this.value, required this.total});
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final frac = (value / total).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label  •  $value', style: text.bodySmall),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: w,
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  height: 12,
                  width: w * frac,
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Top-N 長條圖（每條不同色）
class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.data,
    required this.unitSuffix,
    this.barHeight = 22,
    this.maxBars = 5,
    this.labelStyle,
    this.colorPalette,
  });

  final Map<String, int> data; // label -> value
  final String unitSuffix;
  final double barHeight;
  final int maxBars;
  final TextStyle? labelStyle;
  final List<Color>? colorPalette;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(height: 80, child: Center(child: Text('—'))),
      );
    }
    final entries = data.entries.toList();
    final maxVal =
        (entries.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b))
            .clamp(1, 1 << 30);
    final palette = (colorPalette == null || colorPalette!.isEmpty)
        ? [Theme.of(context).colorScheme.primary]
        : colorPalette!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          children: [
            for (int i = 0; i < entries.take(maxBars).length; i++) ...[
              _BarRow(
                label: entries[i].key,
                value: entries[i].value,
                maxValue: maxVal,
                barHeight: barHeight,
                unitSuffix: unitSuffix,
                color: palette[i % palette.length],
                labelStyle: labelStyle,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.barHeight,
    required this.unitSuffix,
    required this.color,
    this.labelStyle,
  });

  final String label;
  final int value;
  final int maxValue;
  final double barHeight;
  final String unitSuffix;
  final Color color;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final frac = (value / maxValue).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: labelStyle ?? text.bodyMedium),
                ),
                const SizedBox(width: 8),
                Text('$value $unitSuffix', style: text.labelMedium),
              ],
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: barHeight,
                  width: w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  height: barHeight,
                  width: w * frac,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
