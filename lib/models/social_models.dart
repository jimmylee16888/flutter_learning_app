// lib/models/social_models.dart
import 'dart:io';

/// ============== Users / Comments / Posts ==============

class SocialUser {
  final String id;
  final String name;
  final String? avatarAsset; // 先用本地 asset，未來可換後端 URL
  const SocialUser({required this.id, required this.name, this.avatarAsset});

  factory SocialUser.fromJson(Map<String, dynamic> j) => SocialUser(
    id: j['id'] as String,
    name: j['name'] as String,
    avatarAsset: j['avatarAsset'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatarAsset != null) 'avatarAsset': avatarAsset,
  };

  SocialUser copyWith({String? id, String? name, String? avatarAsset}) =>
      SocialUser(
        id: id ?? this.id,
        name: name ?? this.name,
        avatarAsset: avatarAsset ?? this.avatarAsset,
      );
}

class SocialComment {
  final String id;
  final SocialUser author;
  final String text;
  final DateTime createdAt;

  SocialComment({
    required this.id,
    required this.author,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SocialComment.fromJson(Map<String, dynamic> j) => SocialComment(
    id: j['id'] as String,
    author: SocialUser.fromJson(j['author'] as Map<String, dynamic>),
    text: j['text'] as String? ?? '',
    createdAt: DateTime.parse(j['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  SocialComment copyWith({
    String? id,
    SocialUser? author,
    String? text,
    DateTime? createdAt,
  }) => SocialComment(
    id: id ?? this.id,
    author: author ?? this.author,
    text: text ?? this.text,
    createdAt: createdAt ?? this.createdAt,
  );
}

class SocialPost {
  final String id;
  final SocialUser author;
  final DateTime createdAt;
  String text;

  /// 舊版本地圖片預覽；現在主要使用 [imageUrl] 顯示網路圖
  List<File?> images;

  /// 後端儲存的圖片 URL（例如：`/uploads/xxxx.jpg`）
  final String? imageUrl;

  int likeCount;
  bool likedByMe;
  final List<SocialComment> comments;
  final List<String> tags;

  SocialPost({
    required this.id,
    required this.author,
    required this.text,
    this.imageUrl,
    List<File?>? images,
    DateTime? createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
    List<SocialComment>? comments,
    List<String>? tags,
  }) : images = images ?? <File?>[],
       createdAt = createdAt ?? DateTime.now(),
       comments = comments ?? <SocialComment>[],
       tags = tags ?? <String>[];

  /// 後端 JSON 轉模型（對應 Go 後端欄位名稱）
  factory SocialPost.fromJson(Map<String, dynamic> j) => SocialPost(
    id: j['id'] as String,
    author: SocialUser.fromJson(j['author'] as Map<String, dynamic>),
    text: j['text'] as String? ?? '',
    createdAt: DateTime.parse(j['createdAt'] as String),
    images: const <File?>[], // 後端不回傳本地 image 檔
    imageUrl: j['imageUrl'] as String?,
    likeCount: j['likeCount'] as int? ?? 0,
    likedByMe: j['likedByMe'] as bool? ?? false,
    comments: ((j['comments'] as List?) ?? const [])
        .map((e) => SocialComment.fromJson(e as Map<String, dynamic>))
        .toList(),
    tags: ((j['tags'] as List?) ?? const []).map((e) => '$e').toList(),
  );

  /// 序列化送後端（不含本地 images）
  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'likeCount': likeCount,
    'likedByMe': likedByMe,
    'comments': comments.map((e) => e.toJson()).toList(),
    'tags': tags,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  SocialPost copyWith({
    String? id,
    SocialUser? author,
    DateTime? createdAt,
    String? text,
    List<File?>? images,
    String? imageUrl,
    int? likeCount,
    bool? likedByMe,
    List<SocialComment>? comments,
    List<String>? tags,
  }) => SocialPost(
    id: id ?? this.id,
    author: author ?? this.author,
    createdAt: createdAt ?? this.createdAt,
    text: text ?? this.text,
    images: images ?? this.images,
    imageUrl: imageUrl ?? this.imageUrl,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
    comments: comments ?? this.comments,
    tags: tags ?? this.tags,
  );
}

/// ============== 假資料（之後可接後端） ==============

final _mockAlice = SocialUser(id: 'u_alice', name: 'Alice');
final _mockBob = SocialUser(id: 'u_bob', name: 'Bob');

List<SocialPost> mockPosts(SocialUser current) {
  return [
    SocialPost(
      id: 'p1',
      author: _mockAlice,
      text: '第一篇貼文！這是一個示範的社交動態卡片 👋',
      likeCount: 23,
      tags: ['kpop', 'ui', 'flutter'],
      comments: [SocialComment(id: 'c1', author: _mockBob, text: '看起來很讚！')],
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      // imageUrl 可為 null；如需測試可填 '/uploads/xxx.jpg'
    ),
    SocialPost(
      id: 'p2',
      author: _mockBob,
      text: '今天把 UI 卡片邊角修好了 ✅',
      tags: ['flutter', 'design'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 2)),
    ),
  ];
}

/// ============== 好友名片資料模型 ==============

class FriendCard {
  String id;
  String nickname;
  List<String> artists; // 追蹤藝人
  String? phone;
  String? lineId;
  String? facebook;
  String? instagram;

  FriendCard({
    required this.id,
    required this.nickname,
    this.artists = const [],
    this.phone,
    this.lineId,
    this.facebook,
    this.instagram,
  });

  factory FriendCard.fromJson(Map<String, dynamic> j) => FriendCard(
    id: j['id'] as String,
    nickname: j['nickname'] as String,
    artists: ((j['artists'] as List?) ?? const []).map((e) => '$e').toList(),
    phone: j['phone'] as String?,
    lineId: j['lineId'] as String?,
    facebook: j['facebook'] as String?,
    instagram: j['instagram'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'artists': artists,
    if (phone != null) 'phone': phone,
    if (lineId != null) 'lineId': lineId,
    if (facebook != null) 'facebook': facebook,
    if (instagram != null) 'instagram': instagram,
  };

  FriendCard copyWith({
    String? id,
    String? nickname,
    List<String>? artists,
    String? phone,
    String? lineId,
    String? facebook,
    String? instagram,
  }) => FriendCard(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    artists: artists ?? this.artists,
    phone: phone ?? this.phone,
    lineId: lineId ?? this.lineId,
    facebook: facebook ?? this.facebook,
    instagram: instagram ?? this.instagram,
  );
}
