// lib/widgets/photo_quote_card.dart
import 'package:flutter/material.dart';
import '../screens/detail_page.dart';

class PhotoQuoteCard extends StatefulWidget {
  const PhotoQuoteCard({
    super.key,
    required this.image,
    required this.title, // 卡片上的標題
    required this.quote, // 詳細頁的一句話
    this.birthday, // 詳細頁生日（可選）
    this.initiallyLiked = false,
    this.borderRadius = 16,
  });

  final ImageProvider image;
  final String title;
  final String quote;
  final DateTime? birthday;
  final bool initiallyLiked;
  final double borderRadius;

  @override
  State<PhotoQuoteCard> createState() => _PhotoQuoteCardState();
}

class _PhotoQuoteCardState extends State<PhotoQuoteCard> {
  late bool _liked = widget.initiallyLiked;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardDetailPage(
          image: widget.image,
          title: widget.title,
          birthday: widget.birthday,
          quote: widget.quote,
          initiallyLiked: _liked,
        ),
      ),
    );
  }

  void _toggleLike() => setState(() => _liked = !_liked);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: () => _openDetail(context), // ← 點卡片導頁
        child: Stack(
          children: [
            Positioned.fill(
              child: Ink.image(
                image: widget.image,
                fit: BoxFit.cover,
                child: const SizedBox.expand(),
              ),
            ),
            // 下方漸層 + 標題
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // 右上角愛心（只切換，不導頁）
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
                onPressed: _toggleLike,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: _liked
                      ? const Icon(
                          Icons.favorite,
                          key: ValueKey('on'),
                          color: Colors.pinkAccent,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          key: ValueKey('off'),
                          color: Colors.white,
                        ),
                ),
                tooltip: _liked ? '已收藏' : '加入收藏',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
