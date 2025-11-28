import 'dart:convert';
import 'dart:math';

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

  // 記住目前底部 carousel 停在哪一張卡
  int _currentMiniIndex = 0;

  static const _kSwipeDistance = 40.0;
  static const _kSwipeVelocity = 600.0;
  double _dragDyAccum = 0;

  static const double _kPreviewHeight = 300;

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
    final baseImage = _CoverBox(
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

    // 整理「基本資訊」變成 badge 用的 item
    final infoItems = <_InfoItem>[
      _InfoItem(icon: Icons.cake_outlined, label: l.birthday, value: bdayText),
      if ((widget.stageName ?? '').trim().isNotEmpty)
        _InfoItem(
          icon: Icons.tag_faces_outlined,
          label: l.fieldStageNameLabel,
          value: widget.stageName!.trim(),
        ),
      if ((widget.group ?? '').trim().isNotEmpty)
        _InfoItem(
          icon: Icons.group_outlined,
          label: l.fieldGroupLabel,
          value: widget.group!.trim(),
        ),
      if ((widget.origin ?? '').trim().isNotEmpty)
        _InfoItem(
          icon: Icons.location_on_outlined,
          label: l.fieldOriginLabel,
          value: widget.origin!.trim(),
        ),
      if ((widget.note ?? '').trim().isNotEmpty)
        _InfoItem(
          icon: Icons.edit_note_outlined,
          label: l.fieldNoteLabel,
          value: widget.note!.trim(),
        ),
    ];

    // Quote 區域
    final quoteText = widget.quote.trim().isEmpty
        ? l.noQuotePlaceholder
        : '“${widget.quote.trim()}”';

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

      // 上方區域：固定結構，不整頁滑動
      body: Column(
        children: [
          // 大圖 + 漂浮 badge
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                baseImage,
                if (infoItems.isNotEmpty)
                  IgnorePointer(child: _InfoBadgeMarquee(items: infoItems)),
              ],
            ),
          ),

          // Quote 區域（給粉絲的一句話）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 8),
                  Expanded(
                    // 若文字很多，只在這一小塊可捲動，上方大圖不動
                    child: SingleChildScrollView(
                      child: Text(
                        quoteText,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 底部 mini-cards preview（完全沒有玻璃/邊框/分隔線）
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _dragDyAccum = 0,
        onVerticalDragUpdate: (details) => _dragDyAccum += details.delta.dy,
        onVerticalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (_dragDyAccum <= -_kSwipeDistance || v <= -_kSwipeVelocity) {
            // 👇 用目前 carousel 的 index 當 initialIndex
            _openMiniCardsPage(initialIndex: _currentMiniIndex);
          }
          _dragDyAccum = 0;
        },
        onTap: () {
          _openMiniCardsPage(initialIndex: _currentMiniIndex);
        },
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
                        // 👇 等等會在這裡接收目前 index
                        onCurrentIndexChanged: (i) {
                          _currentMiniIndex = i;
                        },
                      ),
                    )
                  : _BottomPreviewBody(
                      miniCards: _miniCards,
                      previewHeight: _kPreviewHeight,
                      onOpenMiniCards: _openMiniCardsPage,
                      onCurrentIndexChanged: (i) {
                        _currentMiniIndex = i;
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------- 資訊 badge 用的小模型 -------

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}

// ------- 單顆 badge 從右到左漂過（一次只出現一個） -------

class _InfoBadgeMarquee extends StatefulWidget {
  const _InfoBadgeMarquee({required this.items});

  final List<_InfoItem> items;

  @override
  State<_InfoBadgeMarquee> createState() => _InfoBadgeMarqueeState();
}

class _InfoBadgeMarqueeState extends State<_InfoBadgeMarquee>
    with SingleTickerProviderStateMixin {
  // 速度：時間越長移動越慢
  static const _travelDuration = Duration(seconds: 14);

  // 控制「從多遠的右邊進來、飄到多遠的左邊」
  static const double _startX = 2.0; // 自己寬度的 2 倍右側
  static const double _endX = -2.0; // 自己寬度的 2 倍左側

  final _rand = Random();

  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  int _index = 0; // 目前顯示哪個欄位
  double _alignY = 0.0; // 這一輪的垂直位置 (-1 ~ 1)

  double _randomY() {
    // 限制在中間大約 60% 高度 [-0.7, 0.7]
    return _rand.nextDouble() * 1.4 - 0.7;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _travelDuration);

    _offset = Tween<Offset>(
      begin: Offset(_startX, 0.0), // 從更遠的右邊開始
      end: Offset(_endX, 0.0), // 飄到更遠的左邊才消失
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          if (widget.items.isNotEmpty) {
            _index = (_index + 1) % widget.items.length; // 換下一個欄位
          }
          _alignY = _randomY(); // 每一輪換一個高度
        });
        _controller.forward(from: 0); // 無限重播
      }
    });

    if (widget.items.isNotEmpty) {
      _alignY = _randomY();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant _InfoBadgeMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.isEmpty) {
      _controller.stop();
    } else if (oldWidget.items.length != widget.items.length) {
      // 避免長度變化導致 index 越界
      _index = _index % widget.items.length;
      _alignY = _randomY();
      if (!_controller.isAnimating) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBadge(_InfoItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(width: 4),
          Text(
            '·',
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
          ),
          const SizedBox(width: 4),
          Text(
            item.value,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final item = widget.items[_index % widget.items.length];

    return SizedBox.expand(
      child: Align(
        alignment: Alignment(0, _alignY), // 這一輪的隨機高度
        child: SlideTransition(position: _offset, child: _buildBadge(item)),
      ),
    );
  }
}

// ------- Bottom Preview（無玻璃效果 / 無邊框） -------

class _BottomPreviewBody extends StatelessWidget {
  const _BottomPreviewBody({
    required this.miniCards,
    required this.previewHeight,
    required this.onOpenMiniCards,
    this.onCurrentIndexChanged,
  });

  final List<MiniCardData> miniCards;
  final double previewHeight;
  final Future<void> Function({int initialIndex}) onOpenMiniCards;

  final ValueChanged<int>? onCurrentIndexChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: Colors.transparent,
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
                    // 👇 新增：往下傳給 carousel
                    onIndexChanged: onCurrentIndexChanged,
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.detailSwipeHint,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 15),
        ],
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
    this.onIndexChanged,
  });

  final List<MiniCardData> cards;
  final double height;
  final double borderRadius;
  final void Function({int initialIndex})? onTapCenter;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

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

        _pc ??=
            PageController(
              initialPage: widget.initialIndex.clamp(
                0,
                (widget.cards.length - 1).clamp(0, 999),
              ),
              viewportFraction: vf,
            )..addListener(() {
              final p = _pc!.page ?? _page;
              if ((p - _page).abs() > 0.01) {
                setState(() => _page = p);
                // 👇 回報目前顯示的那張卡片 index
                final idx = p.round().clamp(0, widget.cards.length - 1);
                if (widget.onIndexChanged != null) {
                  widget.onIndexChanged!(idx);
                }
              }
            });

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
