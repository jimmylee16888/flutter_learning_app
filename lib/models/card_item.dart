import 'package:flutter/foundation.dart';

@immutable
import 'package:flutter/foundation.dart';

@immutable
class CardItem {
  final String id;
  final String title; // 人名
  final String? imageUrl; // 網址
  final String? localPath; // 本地檔案路徑
  final DateTime? birthday; // 建議存 UTC
  final String quote;
  final List<String> categories; // → 不可變

  const CardItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.localPath,
    DateTime? birthday,
    this.quote = '',
    List<String> categories = const [],
  }) : birthday = birthday,
       categories = categories;

  CardItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? localPath,
    DateTime? birthday,
    String? quote,
    List<String>? categories,
  }) {
    return CardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      birthday: birthday ?? this.birthday,
      quote: quote ?? this.quote,
      categories: categories == null
          ? this.categories
          : List.unmodifiable(categories),
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
  );
}

// class CardItem {
//   final String id;
//   final String title; // 人名
//   final String? imageUrl; // 可能是網址
//   final String? localPath; // 或本地檔案路徑
//   final DateTime? birthday;
//   final String quote;
//   final List<String> categories;

//   const CardItem({
//     required this.id,
//     required this.title,
//     this.imageUrl,
//     this.localPath,
//     this.birthday,
//     this.quote = '',
//     this.categories = const [],
//   });

//   CardItem copyWith({
//     String? id,
//     String? title,
//     String? imageUrl,
//     String? localPath,
//     DateTime? birthday,
//     String? quote,
//     List<String>? categories,
//   }) {
//     return CardItem(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       imageUrl: imageUrl ?? this.imageUrl,
//       localPath: localPath ?? this.localPath,
//       birthday: birthday ?? this.birthday,
//       quote: quote ?? this.quote,
//       categories: categories ?? this.categories,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'imageUrl': imageUrl,
//     'localPath': localPath,
//     'birthday': birthday?.toIso8601String(),
//     'quote': quote,
//     'categories': categories,
//   };

//   factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
//     id: json['id'] as String,
//     title: json['title'] as String,
//     imageUrl: json['imageUrl'] as String?,
//     localPath: json['localPath'] as String?,
//     birthday: json['birthday'] == null ? null : DateTime.parse(json['birthday']),
//     quote: (json['quote'] ?? '') as String,
//     categories: (json['categories'] as List<dynamic>? ?? const []).cast<String>(),
//   );
// }
