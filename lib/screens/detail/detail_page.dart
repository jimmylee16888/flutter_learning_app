import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/screens/detail/mini_cards/mini_cards_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/mini_card_data.dart';

import 'package:flutter_learning_app/utils/mini_card_io.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    required this.image,
    required this.title,
    this.birthday,
    required this.quote,
    this.initiallyLiked = false,
  });

  final ImageProvider image;
  final String title;
  final DateTime? birthday;
  final String quote;
  final bool initiallyLiked;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late bool _liked = widget.initiallyLiked;
  List<MiniCardData> _miniCards = [];

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
    }
  }

  // —— 這兩個參數可自行微調 —— //
  static const _swipeDistanceThreshold = 40.0; // 上滑距離（像素）
  static const _swipeVelocityThreshold = 600.0; // 上滑速度（像素/秒）

  // —— 下排小卡大小 —— //
  static const double previewHeight = 250; // 想更大就調這個

  double _dragDyAccum = 0;

  @override
  Widget build(BuildContext context) {
    final b = widget.birthday;
    final bdayText = b == null
        ? '—'
        : '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: '收藏',
            icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              setState(() => _liked = !_liked);
              await _saveLiked();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 主要內容
          ListView(
            padding: EdgeInsets.zero,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image(image: widget.image, fit: BoxFit.cover),
              ),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: const Text('生日'),
                subtitle: Text(bdayText),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  '給粉絲的一句話',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: Text(
                  '“${widget.quote}”',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),

          // 底部透明小卡預覽（支援上滑/點擊進入小卡頁）
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _dragDyAccum = 0,
              onVerticalDragUpdate: (details) =>
                  _dragDyAccum += details.delta.dy,
              onVerticalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (_dragDyAccum <= -32 || v <= -500) _openMiniCardsPage();
                _dragDyAccum = 0;
              },
              onTap: _openMiniCardsPage,
              child: SafeArea(
                top: false,
                child: Container(
                  // ← 移除 Padding，讓容器直接全寬
                  width: double.infinity, // ← 佔滿螢幕寬度
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: previewHeight,
                        child: _miniCards.isEmpty
                            ? Center(
                                child: Text(
                                  '尚無小卡，點此或上滑進入「小卡頁」新增',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )
                            : // 1) 在 CardDetailPage 底部 preview 區, 用這個取代原本的 ListView.separated(...)
                              _BottomMiniCarousel(
                                cards: _miniCards,
                                height: previewHeight,
                                borderRadius: 14,
                                onTapCenter: _openMiniCardsPage, // 只有置中卡被點才觸發
                                // initialIndex: 0,              // 想一開始就置中某張，可傳進來
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '上滑進入小卡頁（左、右掃描QR、分享QR）',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 毛玻璃半透明容器
class _Frosted extends StatelessWidget {
  const _Frosted({required this.child, this.borderRadius = 16});
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
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
    this.onTapCenter, //（可選）點擊目前置中卡時要做的事
    this.initialIndex = 0, //（可選）預設顯示哪張
  });

  final List<MiniCardData> cards;
  final double height;
  final double borderRadius;
  final VoidCallback? onTapCenter;
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
        final cardW = widget.height * 9 / 16; // 9:16
        final vf = (cardW / width).clamp(0.2, 0.95); // 每頁寬占比

        // 建立/更新 PageController（保留目前頁）
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
          _pc!..dispose();
          _pc = PageController(
            initialPage: curr.round().clamp(
              0,
              (widget.cards.length - 1).clamp(0, 999),
            ),
            viewportFraction: vf,
          )..addListener(() => setState(() => _page = _pc!.page ?? _page));
        }

        final count = widget.cards.length;
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pc,
            padEnds: true, // 置中第一/最後一張
            itemCount: count,
            itemBuilder: (context, i) {
              final data = widget.cards[i];

              // 中間最大、兩側縮小＋半透明
              final d = ((_page) - i).abs();
              final scale = (1 - d * 0.12).clamp(0.86, 1.0);
              final opacity = (1 - d * 0.6).clamp(0.4, 1.0);
              final isCenter = d < 0.5;

              return Center(
                child: AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 150),
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      width: cardW,
                      height: widget.height,
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                          onTap: () {
                            // 點到就捲到該頁 → 置中
                            _pc!.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                            // 如果已經在中間，再觸發對外動作（例如進小卡頁）
                            if (isCenter && widget.onTapCenter != null) {
                              widget.onTapCenter!();
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                            child: Image(
                              image: imageProviderOf(data),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
