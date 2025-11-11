import 'package:flutter/foundation.dart';

@immutable
import 'package:flutter/foundation.dart';

@immutable
class MiniCardData {
  final String id;
  final String? imageUrl;
  final String? localPath;
  final String? backImageUrl;
  final String? backLocalPath;

  // 仍沿用 idol（之後建議改 cardId）
  final String? idol;

  final String? name;
  final String? serial;
  final String? language;
  final String? album;
  final String? cardType;
  final String note;
  final List<String> tags; // → 不可變
  final DateTime createdAt; // 建議 UTC

  const MiniCardData({
    required this.id,
    this.imageUrl,
    this.localPath,
    this.backImageUrl,
    this.backLocalPath,
    this.idol,
    this.name,
    this.serial,
    this.language,
    this.album,
    this.cardType,
    this.note = '',
    List<String> tags = const [],
    required DateTime createdAt,
  }) : tags = tags,
       createdAt = createdAt;

  MiniCardData copyWith({
    String? id,
    String? imageUrl,
    String? localPath,
    String? backImageUrl,
    String? backLocalPath,
    String? idol,
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
    idol: idol ?? this.idol,
    name: name ?? this.name,
    serial: serial ?? this.serial,
    language: language ?? this.language,
    album: album ?? this.album,
    cardType: cardType ?? this.cardType,
    note: note ?? this.note,
    tags: tags == null ? this.tags : List.unmodifiable(tags),
    createdAt: createdAt ?? this.createdAt,
  );

  factory MiniCardData.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (parsed == null) {
      // 若你想寬鬆，可改回 DateTime.now().toUtc()
      throw FormatException('MiniCardData.createdAt missing/invalid');
    }
    return MiniCardData(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String?,
      localPath: json['localPath'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      backLocalPath: json['backLocalPath'] as String?,
      idol: json['idol'] as String?,
      name: json['name'] as String?,
      serial: json['serial'] as String?,
      language: json['language'] as String?,
      album: json['album'] as String?,
      cardType: json['cardType'] as String?,
      note: (json['note'] as String?) ?? '',
      tags: ((json['tags'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: parsed.toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'localPath': localPath,
    'backImageUrl': backImageUrl,
    'backLocalPath': backLocalPath,
    'idol': idol,
    'name': name,
    'serial': serial,
    'language': language,
    'album': album,
    'cardType': cardType,
    'note': note,
    'tags': tags,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
