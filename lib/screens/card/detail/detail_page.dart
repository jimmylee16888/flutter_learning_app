// lib/screens/card/detail/card_detail_page.dart

import 'dart:convert';
import 'dart:ui' show ImageFilter; // 👈 磨砂玻璃用
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:flutter_learning_app/screens/card/detail/mini_cards/mini_cards_page.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';
import 'package:flutter_learning_app/utils/no_cors_image/no_cors_image.dart';
import 'package:provider/provider.dart';
import '../../../l10n/l10n.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    this.image, // 非 Web 或本地用
    this.imageWidget, // Web 外站用（NoCorsImage）
    required this.title,
    this.birthday,
    required this.quote,
    this.initiallyLiked = false,

    // 新欄位
    this.stageName,
    this.group,
    this.origin,
    this.note,
  }) : assert(image != null || imageWidget != null);

  final ImageProvider? image;
  final Widget? imageWidget;
  final String title;
  final DateTime? birthday;
  final String quote;
  final bool initiallyLiked;

  final String? stageName;
  final String? group;
  final String? origin;
  final String? note;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late bool _liked = widget.initiallyLiked;
  List<MiniCardData> _miniCards = [];

  static const _kSwipeDistance = 40.0;
  static const _kSwipeVelocity = 600.0;
  double _dragDyAccum = 0;

  String get _cardsKey => 'miniCards:${widget.title}';
  String get _likedKey => 'liked:${widget.title}';

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    final sp = await SharedPreferences.getInstance();
    _liked = sp.getBool(_likedKey) ?? widget.initiallyLiked;

    final raw = sp.getString(_cardsKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(MiniCardData.fromJson)
          .toList();
      _miniCards = list;
      if (mounted) {
        context.read<MiniCardStore>().setForOwner(widget.title, _miniCards);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveLiked() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_likedKey, _liked);
  }

  Future<void> _saveCards() async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(_miniCards.map((e) => e.toJson()).toList());
    await sp.setString(_cardsKey, raw);
  }

  Future<void> _openMiniCardsPage({int initialIndex = 0}) async {
    final updated = await Navigator.of(context).push<List<MiniCardData>>(
      MaterialPageRoute(
        builder: (_) => MiniCardsPage(
          title: widget.title,
          cards: List.of(_miniCards),
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
    if (updated != null) {
      setState(() => _miniCards = updated);
      await _saveCards();
      if (mounted) {
        context.read<MiniCardStore>().setForOwner(widget.title, updated);
      }
    }
  }

  static const double _kPreviewHeight = 300;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final b = widget.birthday;
    final bdayText = b == null
        ? l.birthdayNotChosen
        : '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';

    // 置頂大圖（固定 4:3，統一 cover）
    final topImage = _CoverBox(
      aspectRatio: 4 / 3,
      child:
          widget.imageWidget ??
          Image(
            image: widget.image!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 48),
            ),
          ),
    );

    // 只在有值時顯示一行 ListTile
    Widget? buildInfoTile({
      required IconData icon,
      required String label,
      String? value,
    }) {
      final v = value?.trim();
      if (v == null || v.isEmpty) return null;
      return ListTile(
        dense: true,
        leading: Icon(icon, size: 20),
        title: Text(label),
        subtitle: Text(v),
      );
    }

    final infoTiles = <Widget>[
      // 生日一定顯示
      ListTile(
        dense: true,
        leading: const Icon(Icons.cake_outlined, size: 20),
        title: Text(l.birthday),
        subtitle: Text(bdayText),
      ),
      if (buildInfoTile(
            icon: Icons.tag_faces_outlined,
            label: l.fieldStageNameLabel,
            value: widget.stageName,
          ) !=
          null)
        buildInfoTile(
          icon: Icons.tag_faces_outlined,
          label: l.fieldStageNameLabel,
          value: widget.stageName,
        )!,
      if (buildInfoTile(
            icon: Icons.group_outlined,
            label: l.fieldGroupLabel,
            value: widget.group,
          ) !=
          null)
        buildInfoTile(
          icon: Icons.group_outlined,
          label: l.fieldGroupLabel,
          value: widget.group,
        )!,
      if (buildInfoTile(
            icon: Icons.location_on_outlined,
            label: l.fieldOriginLabel,
            value: widget.origin,
          ) !=
          null)
        buildInfoTile(
          icon: Icons.location_on_outlined,
          label: l.fieldOriginLabel,
          value: widget.origin,
        )!,
      if (buildInfoTile(
            icon: Icons.edit_note_outlined,
            label: l.fieldNoteLabel,
            value: widget.note,
          ) !=
          null)
        buildInfoTile(
          icon: Icons.edit_note_outlined,
          label: l.fieldNoteLabel,
          value: widget.note,
        )!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: _liked ? l.favorited : l.favorite,
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              setState(() => _liked = !_liked);
              await _saveLiked();
            },
          ),
        ],
      ),

      // 主內容：大圖 + 資訊卡 + quote
      body: ListView(
        padding: const EdgeInsets.only(bottom: _kPreviewHeight + 36),
        children: [
          topImage,
          const SizedBox(height: 12),
          // 👉 這張就是你說的「基本資訊」卡片：
          //    永遠四個角都是圓角，不再跟捲動狀態有關
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18), // 永遠圓角
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.4),
                  width: 0.6,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 頂部小標題
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 18, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          l.profileSectionTitle, // 例如「基本資訊」
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 1),

                  // 各個資訊欄位
                  ...infoTiles,

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quote 區
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 24,
                  color: cs.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(l.quoteTitle, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Text(
              widget.quote.trim().isEmpty
                  ? l
                        .noQuotePlaceholder // 沒填 quote 的話顯示簡單提示
                  : '“${widget.quote.trim()}”',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),

      // 底部 mini-cards preview
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _dragDyAccum = 0,
        onVerticalDragUpdate: (details) => _dragDyAccum += details.delta.dy,
        onVerticalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (_dragDyAccum <= -_kSwipeDistance || v <= -_kSwipeVelocity) {
            _openMiniCardsPage();
          }
          _dragDyAccum = 0;
        },
        onTap: _openMiniCardsPage,
        child: SafeArea(
          top: false,
          child: RepaintBoundary(
            child: Material(
              color: Colors.transparent,
              child: kIsWeb
                  ? PointerInterceptor(
                      child: _BottomPreviewBody(
                        miniCards: _miniCards,
                        previewHeight: _kPreviewHeight,
                        onOpenMiniCards: _openMiniCardsPage,
                      ),
                    )
                  : _BottomPreviewBody(
                      miniCards: _miniCards,
                      previewHeight: _kPreviewHeight,
                      onOpenMiniCards: _openMiniCardsPage,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------- Bottom Preview -------

class _BottomPreviewBody extends StatelessWidget {
  const _BottomPreviewBody({
    required this.miniCards,
    required this.previewHeight,
    required this.onOpenMiniCards,
  });

  final List<MiniCardData> miniCards;
  final double previewHeight;
  final Future<void> Function({int initialIndex}) onOpenMiniCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 「磨砂玻璃＋漸層」的小卡區
    // 👉 依你的需求：這裡 *不需要圓角*，所以 BorderRadius.zero
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.surface.withOpacity(0.0),
                cs.surface.withOpacity(0.30),
                cs.surface.withOpacity(0.80),
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withOpacity(0.35),
                width: 0.6,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: previewHeight,
                child: miniCards.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.noMiniCardsPreviewHint,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : _BottomMiniCarousel(
                        cards: miniCards,
                        height: previewHeight,
                        borderRadius: 14,
                        onTapCenter: ({int initialIndex = 0}) =>
                            onOpenMiniCards(initialIndex: initialIndex),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.detailSwipeHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomMiniCarousel extends StatefulWidget {
  const _BottomMiniCarousel({
    required this.cards,
    required this.height,
    this.borderRadius = 12,
    this.onTapCenter,
    this.initialIndex = 0,
  });

  final List<MiniCardData> cards;
  final double height;
  final double borderRadius;
  final void Function({int initialIndex})? onTapCenter;
  final int initialIndex;

  @override
  State<_BottomMiniCarousel> createState() => _BottomMiniCarouselState();
}

class _BottomMiniCarouselState extends State<_BottomMiniCarousel> {
  PageController? _pc;
  double _page = 0;

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final cardW = widget.height * 9 / 16;
        final vf = (cardW / width).clamp(0.2, 0.95);

        _pc ??= PageController(
          initialPage: widget.initialIndex.clamp(
            0,
            (widget.cards.length - 1).clamp(0, 999),
          ),
          viewportFraction: vf,
        )..addListener(() => setState(() => _page = _pc!.page ?? _page));

        if (_pc!.viewportFraction != vf) {
          final curr = _pc!.hasClients
              ? (_pc!.page ?? _pc!.initialPage.toDouble())
              : _pc!.initialPage.toDouble();

          _pc!.dispose();

          _pc = PageController(
            initialPage: curr.round().clamp(
              0,
              (widget.cards.length - 1).clamp(0, 999),
            ),
            viewportFraction: vf,
          )..addListener(() => setState(() => _page = _pc!.page ?? _page));
        }

        final count = widget.cards.length;
        if (count == 0) return const SizedBox.shrink();

        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pc,
            padEnds: true,
            itemCount: count,
            itemBuilder: (context, i) {
              final data = widget.cards[i];
              final d = ((_page) - i).abs();
              final scale = (1 - d * 0.12).clamp(0.86, 1.0);
              final opacity = (1 - d * 0.6).clamp(0.4, 1.0);

              // 決定縮圖來源
              Widget thumb;
              final hasLocal =
                  (data.localPath ?? '').isNotEmpty &&
                  !(kIsWeb && (data.localPath?.startsWith('url:') ?? false));
              final hasRemote = (data.imageUrl ?? '').isNotEmpty;

              if (kIsWeb && !hasLocal && hasRemote) {
                thumb = NoCorsImage(data.imageUrl!, fit: BoxFit.cover);
              } else if (hasLocal) {
                thumb = Image(
                  image: imageProviderForLocalPath(data.localPath!),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                );
              } else {
                thumb = Image(
                  image: imageProviderOf(data),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                );
              }

              // 強制 9:16 & cover
              thumb = _CoverBox(
                aspectRatio: 9 / 16,
                borderRadius: widget.borderRadius,
                child: thumb,
              );

              // Web 上避免 HtmlElementView 搶事件
              if (kIsWeb) {
                thumb = PointerInterceptor(child: thumb);
              }

              return Center(
                child: AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 150),
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: cardW,
                      height: widget.height,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                        onTap: () async {
                          await _pc!.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                          widget.onTapCenter?.call(initialIndex: i);
                        },
                        child: thumb,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ------- 通用：把任何 child 都「強制成 cover」並裁固定比例 -------

class _CoverBox extends StatelessWidget {
  const _CoverBox({
    required this.child,
    this.aspectRatio = 9 / 16,
    this.borderRadius = 0,
  });

  final Widget child;
  final double aspectRatio;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LayoutBuilder(
        builder: (_, c) {
          // 讓所有來源都被 FittedBox cover
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: c.maxWidth,
                height: c.maxHeight,
                child: child,
              ),
            ),
          );
        },
      ),
    );
    return AspectRatio(aspectRatio: aspectRatio, child: content);
  }
}
