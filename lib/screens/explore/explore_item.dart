import 'dart:ui';

enum ExploreKind { photo, quote, countdown, ad, ball }

class ExploreItem {
  ExploreItem({
    required this.kind,
    required this.pos,
    this.w = 160,
    this.h = 160,
    this.title,
    this.quote,
    this.imagePath,
    this.imageUrl,
    this.countdownDate,
    this.deletable = true,
    this.isBack = false,

    // ball 專用
    this.ballEmoji,
    this.ballImagePath,
    this.ballImageUrl,
    this.ballVx = 180,
    this.ballVy = 140,
    this.ballDiameter = 80,
  });

  final ExploreKind kind;

  /// 元件左上角座標
  Offset pos;

  /// 元件尺寸（廣告以外都可調）
  double w;
  double h;

  // 通用
  String? title;
  String? quote;
  String? imagePath; // 非 Web 儲存本地路徑
  String? imageUrl; // Web 儲存 blob: 或 http url
  DateTime? countdownDate;
  bool deletable;
  bool isBack;

  // ball
  String? ballEmoji; // 與 ballImagePath/Url 擇一
  String? ballImagePath; // 非 Web
  String? ballImageUrl; // Web
  double ballVx;
  double ballVy;
  double ballDiameter;

  // ====== JSON ======
  factory ExploreItem.fromJson(Map<String, dynamic> j) => ExploreItem(
    kind: ExploreKind.values[j['kind'] as int],
    pos: Offset((j['pos']?[0] ?? 0).toDouble(), (j['pos']?[1] ?? 0).toDouble()),
    w: (j['w'] ?? 160).toDouble(),
    h: (j['h'] ?? 160).toDouble(),
    title: j['title'] as String?,
    quote: j['quote'] as String?,
    imagePath: j['imagePath'] as String?,
    imageUrl: j['imageUrl'] as String?,
    countdownDate: j['countdownDate'] == null ? null : DateTime.parse(j['countdownDate'] as String),
    deletable: j['deletable'] ?? true,
    isBack: j['isBack'] ?? false,
    ballEmoji: j['ballEmoji'] as String?,
    ballImagePath: j['ballImagePath'] as String?,
    ballImageUrl: j['ballImageUrl'] as String?,
    ballVx: (j['ballVx'] ?? 180).toDouble(),
    ballVy: (j['ballVy'] ?? 140).toDouble(),
    ballDiameter: (j['ballDiameter'] ?? 80).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'kind': kind.index,
    'pos': [pos.dx, pos.dy],
    'w': w,
    'h': h,
    'title': title,
    'quote': quote,
    'imagePath': imagePath,
    'imageUrl': imageUrl,
    'countdownDate': countdownDate?.toIso8601String(),
    'deletable': deletable,
    'isBack': isBack,
    'ballEmoji': ballEmoji,
    'ballImagePath': ballImagePath,
    'ballImageUrl': ballImageUrl,
    'ballVx': ballVx,
    'ballVy': ballVy,
    'ballDiameter': ballDiameter,
  };
}
