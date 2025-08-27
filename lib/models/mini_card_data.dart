// lib/models/mini_card_data.dart
import 'package:flutter/foundation.dart';

@immutable
class MiniCardData {
  final String id;
  final String imageUrl; // 只存網址
  final String note;
  final DateTime createdAt;

  const MiniCardData({
    required this.id,
    required this.imageUrl,
    required this.note,
    required this.createdAt,
  });

  MiniCardData copyWith({
    String? id,
    String? imageUrl,
    String? note,
    DateTime? createdAt,
  }) {
    return MiniCardData(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MiniCardData.fromJson(Map<String, dynamic> json) {
    return MiniCardData(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String, // ← 只讀網址
      note: (json['note'] as String?) ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl, // ← 只寫網址
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };
}
