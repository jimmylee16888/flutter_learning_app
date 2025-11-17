import 'package:flutter/material.dart';
import '../screens/card/detail/detail_page.dart';

class PhotoQuoteCard extends StatefulWidget {
  const PhotoQuoteCard({
    super.key,
    this.image, // 可為 null
    this.imageWidget, // 可為 null（Web 用 NoCorsImage 時會傳這個）
    required this.title,
    required this.quote,
    this.birthday,
    this.stageName, // ✅ 新增
    this.group, // ✅ 新增
    this.origin, // ✅ 新增
    this.note, // ✅ 新增
    this.initiallyLiked = false,
    this.borderRadius = 16,
    this.onLikeChanged, // ← 新增
  }) : assert(
         image != null || imageWidget != null,
         'PhotoQuoteCard 需要提供 image 或 imageWidget 其中之一',
       );

  /// 圖片（行動/桌面通常走 ImageProvider）
  final ImageProvider? image;

  /// 直接給一個圖片 Widget（Web 可用 NoCorsImage 避開 CORS）
  final Widget? imageWidget;

  final String title;
  final String quote;
  final DateTime? birthday;

  // ✅ 新增的資訊欄位
  final String? stageName;
  final String? group;
  final String? origin;
  final String? note;
  final bool initiallyLiked;

  /// 卡片圓角（外部也可再包 ClipRRect 做一致裁切）
  final double borderRadius;

  final ValueChanged<bool>? onLikeChanged; // ← 新增

  /// 相容舊用法：只有網址時也能建構
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

  @override
  void didUpdateWidget(covariant PhotoQuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyLiked != widget.initiallyLiked) {
      _liked = widget.initiallyLiked; // ★ 新增：同步父層變更
    }
  }

  // <-- 這裡拿掉 BuildContext 參數，直接用 this.context
  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CardDetailPage(
          image: widget.image,
          imageWidget: widget.imageWidget,
          title: widget.title,
          birthday: widget.birthday,
          quote: widget.quote,
          initiallyLiked: _liked,

          // ✅ 把 4 個欄位往下傳
          stageName: widget.stageName,
          group: widget.group,
          origin: widget.origin,
          note: widget.note,
        ),
      ),
    );
  }

  void _toggleLike() {
    setState(() => _liked = !_liked);
    widget.onLikeChanged?.call(_liked); // ← 新增：把新狀態回傳外部
  }

  @override
  Widget build(BuildContext context) {
    // ★ 關鍵：若有傳入自訂 imageWidget（例如 Web 的 HtmlElementView），
    //   用 IgnorePointer 包起來，避免攔截點擊/手勢。
    final imageView = (widget.imageWidget != null)
        ? IgnorePointer(ignoring: true, child: widget.imageWidget!)
        : Image(
            image: widget.image!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
          );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: _openDetail,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 圖片（做一次內層裁切，避免微小縫隙）
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: SizedBox.expand(child: imageView),
            ),

            // 底部標題漸層
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
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black45,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 右上角收藏按鈕
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _toggleLike,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: _liked
                      ? const Icon(
                          Icons.favorite,
                          key: ValueKey('fav-on'),
                          color: Colors.pinkAccent,
                        )
                      : const Icon(
                          Icons.favorite_border,
                          key: ValueKey('fav-off'),
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
