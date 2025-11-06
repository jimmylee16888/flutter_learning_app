// lib/models/social_models.dart
import 'dart:io';

/// ===============================================================
/// Models for Social feature
/// - SocialUser: 含暱稱、頭像、email、追蹤的標籤/好友清單，及社群資訊(可選擇是否顯示)
/// - SocialPost / SocialComment: 貼文與留言
/// - FriendCard: 好友名片（可獨立管理）
/// ===============================================================

/// ============== Users / Comments / Posts ==============

class SocialUser {
  /// 使用者 ID（後端唯一鍵）
  final String id;

  /// 顯示名稱（暱稱）
  final String name;

  /// 頭像（目前使用本地 asset；未來可換成後端 URL）
  final String? avatarAsset;

  /// 可選：頭像 URL（若接後端可改用此欄位）
  final String? avatarUrl;

  /// 使用者 Email
  final String? email;

  /// 追蹤的標籤（#tag）
  final List<String> followedTags;

  /// 追蹤/加入的好友（userId 清單）
  final List<String> followingUserIds;

  /// ---- 社群資訊（使用者可選擇是否顯示）----
  final String? instagram;
  final String? facebook;
  final String? lineId;

  /// 是否公開顯示這些社群欄位
  final bool showInstagram;
  final bool showFacebook;
  final bool showLine;

  const SocialUser({
    required this.id,
    required this.name,
    this.avatarAsset,
    this.avatarUrl,
    this.email,
    this.followedTags = const [],
    this.followingUserIds = const [],
    this.instagram,
    this.facebook,
    this.lineId,
    this.showInstagram = false,
    this.showFacebook = false,
    this.showLine = false,
  });

  // --- SocialUser ---
  factory SocialUser.fromJson(Map<String, dynamic> j) => SocialUser(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    avatarAsset: j['avatarAsset'] as String?,
    avatarUrl: j['avatarUrl'] as String?,
    email: j['email'] as String?,
    followedTags:
        (j['followedTags'] as List?)?.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList() ?? <String>[],
    followingUserIds:
        (j['followingUserIds'] as List?)?.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList() ??
        <String>[],
    instagram: j['instagram'] as String?,
    facebook: j['facebook'] as String?,
    lineId: j['lineId'] as String?,
    showInstagram: j['showInstagram'] == true,
    showFacebook: j['showFacebook'] == true,
    showLine: j['showLine'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatarAsset != null) 'avatarAsset': avatarAsset,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    if (email != null) 'email': email,
    'followedTags': followedTags,
    'followingUserIds': followingUserIds,
    if (instagram != null) 'instagram': instagram,
    if (facebook != null) 'facebook': facebook,
    if (lineId != null) 'lineId': lineId,
    'showInstagram': showInstagram,
    'showFacebook': showFacebook,
    'showLine': showLine,
  };

  SocialUser copyWith({
    String? id,
    String? name,
    String? avatarAsset,
    String? avatarUrl,
    String? email,
    List<String>? followedTags,
    List<String>? followingUserIds,
    String? instagram,
    String? facebook,
    String? lineId,
    bool? showInstagram,
    bool? showFacebook,
    bool? showLine,
  }) => SocialUser(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarAsset: avatarAsset ?? this.avatarAsset,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    email: email ?? this.email,
    followedTags: followedTags ?? this.followedTags,
    followingUserIds: followingUserIds ?? this.followingUserIds,
    instagram: instagram ?? this.instagram,
    facebook: facebook ?? this.facebook,
    lineId: lineId ?? this.lineId,
    showInstagram: showInstagram ?? this.showInstagram,
    showFacebook: showFacebook ?? this.showFacebook,
    showLine: showLine ?? this.showLine,
  );
}

class SocialComment {
  final String id;
  final SocialUser author;
  final String text;
  final DateTime createdAt;

  SocialComment({required this.id, required this.author, required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  // --- SocialComment ---
  factory SocialComment.fromJson(Map<String, dynamic> j) => SocialComment(
    id: (j['id'] ?? '').toString(),
    author: SocialUser.fromJson((j['author'] as Map).cast<String, dynamic>()),
    text: (j['text'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  SocialComment copyWith({String? id, SocialUser? author, String? text, DateTime? createdAt}) => SocialComment(
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
  // --- SocialPost ---
  factory SocialPost.fromJson(Map<String, dynamic> j) => SocialPost(
    id: (j['id'] ?? '').toString(),
    author: SocialUser.fromJson((j['author'] as Map).cast<String, dynamic>()),
    text: (j['text'] ?? '').toString(),
    createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ?? DateTime.now(),
    images: const <File?>[], // 後端不回本地檔
    imageUrl: () {
      final v = j['imageUrl'];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }(),
    likeCount: (j['likeCount'] as num?)?.toInt() ?? 0,
    likedByMe: j['likedByMe'] == true,
    comments:
        (j['comments'] as List?)?.map((e) => SocialComment.fromJson((e as Map).cast<String, dynamic>())).toList() ??
        <SocialComment>[],
    tags: (j['tags'] as List?)?.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList() ?? <String>[],
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

final _mockAlice = SocialUser(
  id: 'u_alice',
  name: 'Alice',
  email: 'alice@example.com',
  instagram: '@alice',
  showInstagram: true,
);

final _mockBob = SocialUser(id: 'u_bob', name: 'Bob', email: 'bob@example.com');

List<SocialPost> mockPosts(SocialUser current) {
  return [];
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
