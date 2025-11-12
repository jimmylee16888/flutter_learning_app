// lib/screens/statistics/statistics_view.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:provider/provider.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import '../../models/card_item.dart';
import '../../models/mini_card_data.dart';

import '../../utils/no_cors_image/no_cors_image.dart'; // 你專案裡已有的 NoCorsImage
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  // 0 = 總覽、1..N = 第 i 位藝人
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

    final artists = context.watch<CardItemStore>().cardItems; // List<CardItem>
    final store = context.watch<MiniCardStore>();
    final allCards = store.allCards();

    final CardItem? selectedArtist = _artistPage > 0
        ? artists[_artistPage - 1]
        : null;

    final List<MiniCardData> scopedCards = selectedArtist == null
        ? allCards
        : store.forOwner(selectedArtist.title);

    final artistCount = artists.length;
    final totalCards = allCards.length;

    final (frontLocalCount, frontUrlCount) = _frontCounts(scopedCards);

    final Map<String, int> cardsPerArtist = {
      for (final a in artists) a.title: store.forOwner(a.title).length,
    };
    final top5 = _topN(cardsPerArtist, 5);

    return Scaffold(
      // appBar: AppBar(title: Text(l.stats_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(
            title: l.stats_overview,
            icon: Icons.dashboard_customize_outlined,
          ),
          const SizedBox(height: 12),

          // ===== KPI Dashboard =====
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

          // 被滑到某位藝人時 → 顯示該藝人預覽
          if (_artistPage > 0) ...[
            const SizedBox(height: 8),
            _ArtistPreviewStrip(artist: artists[_artistPage - 1]),
          ],

          const SizedBox(height: 16),

          // 本地 / 網址比例
          _TwoBarCard(
            leftLabel: l.common_local,
            leftValue: frontLocalCount,
            rightLabel: l.common_url,
            rightValue: frontUrlCount,
          ),

          const SizedBox(height: 16),

          // 各藝人前 N 長條圖
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
              unitSuffix: l.common_unit_cards,
              barHeight: 24,
              maxBars: 5,
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
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) => tiles[i],
    );
  }
}

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

/// Page 0 = 總覽；Page 1..N = 每位藝人
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
    final pages = <Widget>[
      _KpiCenter(
        title: title,
        value: '${artists.length}',
        icon: Icons.people_alt_outlined,
      ),
      for (final a in artists)
        _KpiCenter(
          title: a.title,
          value: '${store.forOwner(a.title).length}',
          icon: Icons.person_outline,
        ),
    ];

    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.35),
            ),
            child: LayoutBuilder(
              builder: (_, c) => SizedBox(
                width: c.maxWidth,
                height: c.maxHeight,
                child: PageView(
                  controller: pager,
                  onPageChanged: onPageChanged,
                  children: pages,
                ),
              ),
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

/// KPI 下方：顯示被選到的藝人圖片（Web 僅支援 imageUrl）
class _ArtistPreviewStrip extends StatelessWidget {
  const _ArtistPreviewStrip({required this.artist});
  final CardItem artist;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget avatar;
    final url = artist.imageUrl ?? '';

    if (kIsWeb && url.isNotEmpty) {
      // ✅ Web：即使被 CORS 擋，也不會出長錯誤字串
      avatar = NoCorsImage(
        url,
        width: 64,
        height: 64,
        borderRadius: 10,
        fit: BoxFit.cover,
      );
    } else if (url.isNotEmpty) {
      // ✅ 手機/桌機 App：可用原生 NetworkImage
      avatar = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackBox(cs),
        ),
      );
    } else {
      avatar = _fallbackBox(cs);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            avatar,
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

  Widget _fallbackBox(ColorScheme cs) => Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      color: cs.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.center,
    child: const Icon(Icons.person_outline),
  );
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
