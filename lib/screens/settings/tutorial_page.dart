// lib/screens/tutorial/tutorial_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// 使用教學（玻璃＋彩色漸層，活潑頁籤）
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});
  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

enum GuideTab { cards, social, explore, more, faq }

class _TutorialPageState extends State<TutorialPage> {
  GuideTab _current = GuideTab.cards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tutorial_title),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // 活潑扁平分頁（非膠囊）
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: _GuideTabs(
              current: _current,
              onChanged: (v) => setState(() => _current = v),
            ),
          ),
          // 內容
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _Body(tab: _current, key: ValueKey(_current)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 主體內容：依 tab 顯示單一段落
class _Body extends StatelessWidget {
  const _Body({required this.tab, super.key});
  final GuideTab tab;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case GuideTab.cards:
        return const _CardsSection();
      case GuideTab.social:
        return const _SocialSection();
      case GuideTab.explore:
        return const _ExploreSection();
      case GuideTab.more:
        return const _MoreSection();
      case GuideTab.faq:
        return const _FaqSection();
    }
  }
}

/* ======================= 各分段 ======================= */

class _CardsSection extends StatelessWidget {
  const _CardsSection();
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _DocList(
      children: [
        _Tags([
          t.tutorial_cards_tags_addArtist,
          t.tutorial_cards_tags_addMini,
          t.tutorial_cards_tags_editDelete,
          t.tutorial_cards_tags_info,
        ]),
        _GuideCard(
          icon: Icons.person_add_alt_1_outlined,
          title: t.tutorial_cards_addArtist_title,
          steps: [
            t.tutorial_cards_addArtist_s1,
            t.tutorial_cards_addArtist_s2,
            t.tutorial_cards_addArtist_s3,
          ],
        ),
        _GuideCard(
          icon: Icons.add_photo_alternate_outlined,
          title: t.tutorial_cards_addMini_title,
          steps: [
            t.tutorial_cards_addMini_s1,
            t.tutorial_cards_addMini_s2,
            t.tutorial_cards_addMini_s3,
            t.tutorial_cards_addMini_s4,
          ],
        ),
        _GuideCard(
          icon: Icons.info_outline,
          title: t.tutorial_cards_info_title,
          steps: [
            t.tutorial_cards_info_s1,
            t.tutorial_cards_info_s2,
            t.tutorial_cards_info_s3,
          ],
        ),
        _Note(context.l10n.tutorial_cards_note_json),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection();
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _DocList(
      children: [
        _Tags([
          t.tutorial_social_tags_primary,
          t.tutorial_social_tags_postComment,
          t.tutorial_social_tags_lists,
        ]),
        _GuideCard(
          icon: Icons.remove_red_eye_outlined,
          title: t.tutorial_social_browse_title,
          steps: [t.tutorial_social_browse_s1, t.tutorial_social_browse_s2],
        ),
        _GuideCard(
          icon: Icons.edit_note_outlined,
          title: t.tutorial_social_post_title,
          steps: [t.tutorial_social_post_s1, t.tutorial_social_post_s2],
        ),
        _GuideCard(
          icon: Icons.fact_check_outlined,
          title: t.tutorial_social_list_title,
          steps: [t.tutorial_social_list_s1, t.tutorial_social_list_s2],
        ),
      ],
    );
  }
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection();
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _DocList(
      children: [
        _GuideCard(
          icon: Icons.wallpaper_outlined,
          title: t.tutorial_explore_wall_title,
          steps: [t.tutorial_explore_wall_s1, t.tutorial_explore_wall_s2],
        ),
      ],
    );
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection();
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _DocList(
      children: [
        _GuideCard(
          icon: Icons.settings_suggest_outlined,
          title: t.tutorial_more_settings_title,
          steps: [t.tutorial_more_settings_s1, t.tutorial_more_settings_s2],
        ),
        _GuideCard(
          icon: Icons.insights_outlined,
          title: t.tutorial_more_stats_title,
          steps: [t.tutorial_more_stats_s1, t.tutorial_more_stats_s2],
        ),
        _GuideCard(
          icon: Icons.collections_bookmark_outlined,
          title: t.tutorial_more_dex_title,
          steps: [t.tutorial_more_dex_s1],
        ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return _DocList(
      children: [
        _Faq(
          q: t.tutorial_faq_q1,
          a: t.tutorial_faq_a1,
          icon: Icons.playlist_add_outlined,
        ),
        _Faq(
          q: t.tutorial_faq_q2,
          a: t.tutorial_faq_a2,
          icon: Icons.qr_code_2_outlined,
        ),
        _Faq(
          q: t.tutorial_faq_q3,
          a: t.tutorial_faq_a3,
          icon: Icons.label_outline,
        ),
        _Faq(
          q: t.tutorial_faq_q4,
          a: t.tutorial_faq_a4,
          icon: Icons.translate_outlined,
        ),
        _Faq(
          q: t.tutorial_faq_q5,
          a: t.tutorial_faq_a5,
          icon: Icons.campaign_outlined,
        ),
      ],
    );
  }
}

/* ======================= 組件：文件樣式 ======================= */

/// 文件捲動 + 統一 padding
class _DocList extends StatelessWidget {
  const _DocList({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => children[i],
    );
  }
}

/// 標題列（圖示 + 文字）
class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// 關鍵字小豆豆（扁平）
class _Tags extends StatelessWidget {
  const _Tags(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(t, style: const TextStyle(fontSize: 12.5)),
            ),
          )
          .toList(),
    );
  }
}

/* ======================= 玻璃卡與指南卡（subscription 風） ======================= */

/// 玻璃感容器（與 subscription page 同調）
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.blurSigma = 14,
    this.backgroundOpacity = .18,
    this.borderOpacity = .22,
    this.gradientOverlay,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 12),
    this.radius = 16,
  });

  final Widget child;
  final double blurSigma;
  final double backgroundOpacity; // 越小越透明
  final double borderOpacity;
  final Gradient? gradientOverlay;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(backgroundOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(borderOpacity),
            ),
            gradient: gradientOverlay,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 彩色配色盤（依 Icon 穩定挑一組深色漸層）
class _GuidePalette {
  // 更活潑的配色盤（高彩度／偏霓虹）
  static final List<List<Color>> _pairs = [
    [const Color(0xFF3EC5FF), const Color(0xFF0077FF)], // 天藍 → 電藍
    [const Color(0xFF2AF598), const Color(0xFF08AEEA)], // 薄荷綠 → 湖藍
    [const Color(0xFFFF9A9E), const Color(0xFFF6416C)], // 甜粉 → 熱情洋紅
    [const Color(0xFFB69CFF), const Color(0xFF7C4DFF)], // 薰衣草 → 海拔紫
    [const Color(0xFFFFC371), const Color(0xFFFF5F6D)], // 蜜桃橘 → 珊瑚紅
    [const Color(0xFF6EE7F9), const Color(0xFF1EA7FD)], // 冰藍綠 → 亮天藍
    [const Color(0xFFA8FF78), const Color(0xFF78FFD6)], // 青檸綠 → 薄荷青
  ];

  static List<Color> pickBy(IconData icon) {
    final famHash = (icon.fontFamily ?? '').hashCode;
    final base = (icon.codePoint ^ famHash) & 0x7fffffff; // 非負
    return _pairs[base % _pairs.length];
  }
}

/// 指南卡（玻璃＋半透明彩色漸層＋線條水印）
class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    required this.steps,
    this.colors,
  });

  final IconData icon;
  final String title;
  final List<String> steps;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final pair = colors ?? _GuidePalette.pickBy(icon);
    final c1 = pair[0];
    final c2 = pair[1];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        _GlassCard(
          blurSigma: 14,
          backgroundOpacity: .99,
          borderOpacity: .01,
          gradientOverlay: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c1.withOpacity(.28), c2.withOpacity(.28)],
          ),
          radius: 16,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c2.withOpacity(.30),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withOpacity(.45),
                        width: .8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepDot(index: i + 1, color: c2),
                      const SizedBox(width: 8),
                      Expanded(child: Text(steps[i])),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: Icon(
            icon,
            size: 120,
            color: (isDark ? c2 : c1).withOpacity(isDark ? .18 : .12),
          ),
        ),
      ],
    );
  }
}

/// 序號圓點（白字、彩色邊）
class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.color});
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(.26),
        border: Border.all(color: color, width: 1.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/* ======================= FAQ / Note ======================= */

class _Faq extends StatelessWidget {
  const _Faq({required this.q, required this.a, required this.icon});
  final String q;
  final String a;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          childrenPadding: const EdgeInsets.only(left: 32, right: 0, bottom: 8),
          leading: Icon(icon, color: cs.primary),
          title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
          children: [Text(a)],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        text,
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
      ),
    );
  }
}

/* ======================= 活潑扁平 Tabs ======================= */

class _GuideTabs extends StatelessWidget {
  const _GuideTabs({required this.current, required this.onChanged});
  final GuideTab current;
  final ValueChanged<GuideTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(GuideTab, IconData, String)>[
      (GuideTab.cards, Icons.style_outlined, l10n.tutorial_tab_cards),
      (GuideTab.social, Icons.dynamic_feed_outlined, l10n.tutorial_tab_social),
      (GuideTab.explore, Icons.brush_outlined, l10n.tutorial_tab_explore),
      (GuideTab.more, Icons.more_horiz, l10n.tutorial_tab_more),
      (GuideTab.faq, Icons.help_outline, l10n.tutorial_tab_faq),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final it in items) ...[
            _BouncyTab(
              icon: it.$2,
              label: it.$3,
              selected: current == it.$1,
              onTap: () => onChanged(it.$1),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

/// 扁平但活潑：選中時玻璃亮底 + 微縮放 + 彩色底線
class _BouncyTab extends StatelessWidget {
  const _BouncyTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pair = _GuidePalette.pickBy(icon);
    final c1 = pair[0], c2 = pair[1];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: selected
            ? _glassTabDecoration(context, c1, c2)
            : const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 18,
                    color: selected ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 2,
              width: selected ? 36 : 0,
              decoration: BoxDecoration(
                color: selected ? c2 : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 小面積玻璃底（非整顆膠囊）
  BoxDecoration _glassTabDecoration(BuildContext context, Color c1, Color c2) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1.withOpacity(.18), c2.withOpacity(.18)],
      ),
      border: Border.all(color: cs.outlineVariant.withOpacity(.22), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
