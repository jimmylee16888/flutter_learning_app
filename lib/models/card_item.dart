import 'package:flutter/foundation.dart';

@immutable
class CardItem {
  final String id;
  final String title; // 人名
  final String? imageUrl; // 網址
  final String? localPath; // 本地檔案路徑
  final DateTime? birthday; // 建議存 UTC
  final String quote;
  final List<String> categories;

  // ✅ 新欄位
  final String? stageName; // 暱稱 / 藝名
  final String? group; // 團體 / 系列
  final String? origin; // 卡片來源（專輯 / 活動）
  final String? note; // 備註

  /// ✅ 新增：這個人物相關的專輯 ID 清單
  final List<String> albumIds;

  const CardItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.localPath,
    this.birthday,
    this.quote = '',
    this.categories = const [],
    this.stageName,
    this.group,
    this.origin,
    this.note,
    this.albumIds = const [],
  });

  CardItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? localPath,
    DateTime? birthday,
    String? quote,
    List<String>? categories,
    String? stageName,
    String? group,
    String? origin,
    String? note,
    List<String>? albumIds,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      birthday: birthday ?? this.birthday,
      quote: quote ?? this.quote,
      categories: categories ?? this.categories,
      stageName: stageName ?? this.stageName,
      group: group ?? this.group,
      origin: origin ?? this.origin,
      note: note ?? this.note,
      albumIds: albumIds ?? this.albumIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'localPath': localPath,
    'birthday': birthday?.toUtc().toIso8601String(),
    'quote': quote,
    'categories': categories,
    'stageName': stageName,
    'group': group,
    'origin': origin,
    'note': note,
    'albumIds': albumIds,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'] as String,
    title: json['title'] as String,
    imageUrl: json['imageUrl'] as String?,
    localPath: json['localPath'] as String?,
    birthday: json['birthday'] == null
        ? null
        : DateTime.parse(json['birthday']).toUtc(),
    quote: (json['quote'] ?? '') as String,
    categories: ((json['categories'] as List?) ?? const []).cast<String>(),
    stageName: json['stageName'] as String?,
    group: json['group'] as String?,
    origin: json['origin'] as String?,
    note: json['note'] as String?,
    albumIds: ((json['albumIds'] as List?) ?? const []).cast<String>(),
  );
}
