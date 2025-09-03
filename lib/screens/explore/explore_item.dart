import 'dart:ui';

enum ExploreKind { photo, quote, countdown, ad }

class ExploreItem {
  ExploreItem({
    required this.kind,
    required this.pos,
    required this.size,
    this.title,
    this.quote,
    this.imagePath,
    this.imageUrl,
    this.countdownDate,
    this.deletable = true,
    this.isBack = false,
  });

  final ExploreKind kind;
  Offset pos;
  final double size;
  String? title;
  String? quote;
  String? imagePath;
  String? imageUrl;
  DateTime? countdownDate;
  bool deletable;
  bool isBack;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'pos': {'x': pos.dx, 'y': pos.dy},
    'size': size,
    'title': title,
    'quote': quote,
    'imagePath': imagePath,
    'imageUrl': imageUrl,
    'countdownDate': countdownDate?.toIso8601String(),
    'deletable': deletable,
    'isBack': isBack,
  };

  static ExploreItem fromJson(Map<String, dynamic> j) {
    final kind = ExploreKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => ExploreKind.photo,
    );
    final posMap =
        (j['pos'] ?? {'x': 24.0, 'y': 100.0}) as Map<String, dynamic>;
    return ExploreItem(
      kind: kind,
      pos: Offset(
        (posMap['x'] ?? 24).toDouble(),
        (posMap['y'] ?? 100).toDouble(),
      ),
      size: (j['size'] ?? 160).toDouble(),
      title: j['title'],
      quote: j['quote'],
      imagePath: j['imagePath'],
      imageUrl: j['imageUrl'],
      countdownDate: j['countdownDate'] != null
          ? DateTime.tryParse(j['countdownDate'])
          : null,
      deletable: j['deletable'] ?? true,
      isBack: j['isBack'] ?? false,
    );
  }
}
