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

  // ✅ 你原本的新欄位
  final String? stageName; // 暱稱 / 藝名
  final String? group; // 團體 / 系列
  final String? origin; // 卡片來源（專輯 / 活動）
  final String? note; // 備註
  final List<String> albumIds; // 關聯專輯 ID

  // 🔥 同步用欄位
  /// 最後編輯時間（雲端同步判斷誰比較新）
  final DateTime? updatedAt;

  /// 軟刪除：true 代表這筆在邏輯上被刪掉（給雲端同步用）
  final bool deleted;

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
    this.updatedAt, // 可為 null：舊資料沒這欄時 fallback 用
    this.deleted = false,
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
    DateTime? updatedAt,
    bool? deleted,
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
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
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
    // 🔥 雲端同步也要看到這兩個
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
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
    updatedAt: (json['updatedAt'] as String?) != null
        ? DateTime.tryParse(json['updatedAt'] as String)?.toUtc()
        : null,
    deleted: json['deleted'] == true,
  );
}

extension CardItemExt on CardItem {
  DateTime get lastModified =>
      updatedAt ?? birthday ?? DateTime.fromMillisecondsSinceEpoch(0);
}
