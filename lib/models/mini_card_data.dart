// lib/models/mini_card_data.dart
import 'package:flutter/foundation.dart';

@immutable
class MiniCardData {
  final String id;
  final String? imageUrl; // 可空
  final String? localPath; // 可空
  final String note;
  final DateTime createdAt;

  const MiniCardData({
    required this.id,
    this.imageUrl,
    this.localPath,
    required this.note,
    required this.createdAt,
  });

  MiniCardData copyWith({
    String? id,
    String? imageUrl,
    String? localPath,
    String? note,
    DateTime? createdAt,
  }) => MiniCardData(
    id: id ?? this.id,
    imageUrl: imageUrl ?? this.imageUrl,
    localPath: localPath ?? this.localPath,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );

  factory MiniCardData.fromJson(Map<String, dynamic> json) => MiniCardData(
    id: json['id'] as String,
    imageUrl: json['imageUrl'] as String?,
    localPath: json['localPath'] as String?,
    note: (json['note'] as String?) ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'localPath': localPath,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };
}
