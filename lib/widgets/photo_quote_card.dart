import 'package:flutter/material.dart';
import '../screens/detail/detail_page.dart';

class PhotoQuoteCard extends StatefulWidget {
  const PhotoQuoteCard({
    super.key,
    required this.image, // ← 改成吃 ImageProvider
    required this.title,
    required this.quote,
    this.birthday,
    this.initiallyLiked = false,
    this.borderRadius = 16,
  });

  /// 通用：可為 FileImage / NetworkImage / MemoryImage
  final ImageProvider image;
  final String title;
  final String quote;
  final DateTime? birthday;
  final bool initiallyLiked;
  final double borderRadius;

  /// 相容舊用法：若你手上只有網址，還是可以用這個建構子
  factory PhotoQuoteCard.fromUrl({
    Key? key,
    required String imageUrl,
    required String title,
    required String quote,
    DateTime? birthday,
    bool initiallyLiked = false,
    double borderRadius = 16,
  }) {
    final url = (imageUrl.isEmpty)
        ? 'https://picsum.photos/seed/placeholder/600/900'
        : imageUrl;
    return PhotoQuoteCard(
      key: key,
      image: NetworkImage(url),
      title: title,
      quote: quote,
      birthday: birthday,
      initiallyLiked: initiallyLiked,
      borderRadius: borderRadius,
    );
  }

  @override
  State<PhotoQuoteCard> createState() => _PhotoQuoteCardState();
}

class _PhotoQuoteCardState extends State<PhotoQuoteCard> {
  late bool _liked = widget.initiallyLiked;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardDetailPage(
          image: widget.image, // ← 直接帶入 ImageProvider
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
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.none, // 不裁切，避免 1px 白邊
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ← 用通用的 ImageProvider 顯示（支援本地或網址）
            Image(
              image: widget.image,
              fit: BoxFit.cover,
              // 若是 NetworkImage，loadingBuilder 會被忽略；這裡保持簡潔
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
