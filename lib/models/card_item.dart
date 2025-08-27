import 'package:flutter/foundation.dart';

@immutable
class CardItem {
  final String id;
  final String title; // 人名
  final String imageUrl;
  final DateTime? birthday;
  final String quote;
  final List<String> categories; // 分類（可多選）

  const CardItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.birthday,
    this.quote = '',
    this.categories = const [],
  });

  CardItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    DateTime? birthday,
    String? quote,
    List<String>? categories,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      birthday: birthday ?? this.birthday,
      quote: quote ?? this.quote,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'birthday': birthday?.toIso8601String(),
    'quote': quote,
    'categories': categories,
  };

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
    id: json['id'] as String,
    title: json['title'] as String,
    imageUrl: json['imageUrl'] as String,
    birthday: json['birthday'] == null
        ? null
        : DateTime.parse(json['birthday']),
    quote: (json['quote'] ?? '') as String,
    categories: (json['categories'] as List<dynamic>? ?? const [])
        .cast<String>(),
  );
}
