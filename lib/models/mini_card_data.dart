import 'package:flutter/foundation.dart';

@immutable
class MiniCardData {
  final String id;

  // 既有欄位：視為「正面」
  final String? imageUrl; // front
  final String? localPath; // front

  // 新增：背面
  final String? backImageUrl;
  final String? backLocalPath;

  // 新增：可在ⓘ面板編輯的資訊
  final String? name; // 名稱
  final String? serial; // 序號
  final String? language; // 語言
  final String? album; // 專輯
  final String? cardType; // 卡種

  // 既有：備註 -> 仍保留
  final String note;

  // 新增：標籤（用於篩選 / 卡背顯示為 badge）
  final List<String> tags;

  final DateTime createdAt;

  const MiniCardData({
    required this.id,
    this.imageUrl,
    this.localPath,
    this.backImageUrl,
    this.backLocalPath,
    this.name,
    this.serial,
    this.language,
    this.album,
    this.cardType,
    this.note = '',
    this.tags = const [],
    required this.createdAt,
  });

  MiniCardData copyWith({
    String? id,
    String? imageUrl,
    String? localPath,
    String? backImageUrl,
    String? backLocalPath,
    String? name,
    String? serial,
    String? language,
    String? album,
    String? cardType,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) => MiniCardData(
    id: id ?? this.id,
    imageUrl: imageUrl ?? this.imageUrl,
    localPath: localPath ?? this.localPath,
    backImageUrl: backImageUrl ?? this.backImageUrl,
    backLocalPath: backLocalPath ?? this.backLocalPath,
    name: name ?? this.name,
    serial: serial ?? this.serial,
    language: language ?? this.language,
    album: album ?? this.album,
    cardType: cardType ?? this.cardType,
    note: note ?? this.note,
    tags: tags ?? this.tags,
    createdAt: createdAt ?? this.createdAt,
  );

  factory MiniCardData.fromJson(Map<String, dynamic> json) => MiniCardData(
    id: json['id'] as String,
    imageUrl: json['imageUrl'] as String?, // 既有：正面網址
    localPath: json['localPath'] as String?, // 既有：正面本地
    backImageUrl: json['backImageUrl'] as String?, // 新：背面網址
    backLocalPath: json['backLocalPath'] as String?, // 新：背面本地
    name: json['name'] as String?,
    serial: json['serial'] as String?,
    language: json['language'] as String?,
    album: json['album'] as String?,
    cardType: json['cardType'] as String?,
    note: (json['note'] as String?) ?? '',
    tags:
        (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'localPath': localPath,
    'backImageUrl': backImageUrl,
    'backLocalPath': backLocalPath,
    'name': name,
    'serial': serial,
    'language': language,
    'album': album,
    'cardType': cardType,
    'note': note,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
  };
}
