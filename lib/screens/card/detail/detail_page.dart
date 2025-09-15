import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/screens/card/detail/mini_cards/mini_cards_page.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart';
import 'package:provider/provider.dart';
import '../../../l10n/l10n.dart'; // ← i18n

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

  static const _swipeDistanceThreshold = 40.0;
  static const _swipeVelocityThreshold = 600.0;

  static const double previewHeight = 250;

  double _dragDyAccum = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final b = widget.birthday;
    final bdayText = b == null
        ? l.birthdayNotChosen
        : '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';

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
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image(image: widget.image, fit: BoxFit.cover),
              ),
              ListTile(
                leading: const Icon(Icons.cake_outlined),
                title: Text(l.birthday),
                subtitle: Text(bdayText),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  l.quoteTitle,
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

          // Bottom mini-cards preview
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _dragDyAccum = 0,
              onVerticalDragUpdate: (details) =>
                  _dragDyAccum += details.delta.dy,
              onVerticalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (_dragDyAccum <= -_swipeDistanceThreshold ||
                    v <= -_swipeVelocityThreshold) {
                  _openMiniCardsPage();
                }
                _dragDyAccum = 0;
              },
              onTap: _openMiniCardsPage,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: previewHeight,
                        child: _miniCards.isEmpty
                            ? Center(
                                child: Text(
                                  l.noMiniCardsPreviewHint, // 新 key
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )
                            : _BottomMiniCarousel(
                                cards: _miniCards,
                                height: previewHeight,
                                borderRadius: 14,
                                onTapCenter: _openMiniCardsPage,
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.detailSwipeHint, // 新 key
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
                            _pc!.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                            if (isCenter && widget.onTapCenter != null)
                              widget.onTapCenter!();
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
