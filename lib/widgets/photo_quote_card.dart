import 'package:flutter/material.dart';
import '../screens/detail/detail_page.dart';

class PhotoQuoteCard extends StatefulWidget {
  const PhotoQuoteCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.quote,
    this.birthday,
    this.initiallyLiked = false,
    this.borderRadius = 16,
  });

  final String imageUrl;
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
          image: NetworkImage(widget.imageUrl),
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
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.none, // ← 關鍵：不要再裁切
      // shape 也不要給圓角（或乾脆拿掉 shape）
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Stack(
          fit: StackFit.expand, // 保證鋪滿，避免再有 1px 的差異
          children: [
            Image.network(
              widget.imageUrl.isEmpty
                  ? 'https://picsum.photos/seed/placeholder/600/900'
                  : widget.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, p) => p == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
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
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
                onPressed: _toggleLike,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
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
