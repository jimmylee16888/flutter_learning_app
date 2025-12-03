// lib/models/social_models.dart

/// ===============================================================
/// Models for Social feature
/// - SocialUser: 含暱稱、頭像、email、追蹤的標籤/好友清單，及社群資訊(可選擇是否顯示)
/// - SocialPost / SocialComment: 貼文與留言
/// - FriendCard: 好友名片（可獨立管理）
/// ===============================================================

class SocialUser {
  final String id;
  final String name;
  final String? avatarAsset;
  final String? avatarUrl;
  final String? email;
  final List<String> followedTags; // 不可變
  final List<String> followingUserIds; // 不可變
  final String? instagram;
  final String? facebook;
  final String? lineId;
  final bool showInstagram;
  final bool showFacebook;
  final bool showLine;

  /// 🔥 新增：同步用
  final DateTime? updatedAt;
  final bool deleted;

  const SocialUser({
    required this.id,
    required this.name,
    this.avatarAsset,
    this.avatarUrl,
    this.email,
    List<String> followedTags = const [],
    List<String> followingUserIds = const [],
    this.instagram,
    this.facebook,
    this.lineId,
    this.showInstagram = false,
    this.showFacebook = false,
    this.showLine = false,
    this.updatedAt,
    this.deleted = false,
  }) : followedTags = followedTags,
       followingUserIds = followingUserIds;

  factory SocialUser.fromJson(Map<String, dynamic> j) => SocialUser(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    avatarAsset: j['avatarAsset'] as String?,
    avatarUrl: j['avatarUrl'] as String?,
    email: j['email'] as String?,
    followedTags: ((j['followedTags'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(),
    followingUserIds: ((j['followingUserIds'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(),
    instagram: j['instagram'] as String?,
    facebook: j['facebook'] as String?,
    lineId: j['lineId'] as String?,
    showInstagram: j['showInstagram'] == true,
    showFacebook: j['showFacebook'] == true,
    showLine: j['showLine'] == true,
    updatedAt: (j['updatedAt'] as String?) != null
        ? DateTime.tryParse(j['updatedAt'] as String)?.toUtc()
        : null,
    deleted: j['deleted'] == true,
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
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
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
    DateTime? updatedAt,
    bool? deleted,
  }) => SocialUser(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarAsset: avatarAsset ?? this.avatarAsset,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    email: email ?? this.email,
    followedTags: followedTags == null
        ? this.followedTags
        : List.unmodifiable(followedTags),
    followingUserIds: followingUserIds == null
        ? this.followingUserIds
        : List.unmodifiable(followingUserIds),
    instagram: instagram ?? this.instagram,
    facebook: facebook ?? this.facebook,
    lineId: lineId ?? this.lineId,
    showInstagram: showInstagram ?? this.showInstagram,
    showFacebook: showFacebook ?? this.showFacebook,
    showLine: showLine ?? this.showLine,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
}

class SocialComment {
  final String id;
  final SocialUser author;
  final String text;
  final DateTime createdAt; // 建議 UTC

  /// 🔥 新增：最後編輯 & 軟刪除
  final DateTime? updatedAt;
  final bool deleted;

  SocialComment({
    required this.id,
    required this.author,
    required this.text,
    DateTime? createdAt,
    this.updatedAt,
    this.deleted = false,
  }) : createdAt = (createdAt ?? DateTime.now()).toUtc();

  factory SocialComment.fromJson(Map<String, dynamic> j) => SocialComment(
    id: (j['id'] ?? '').toString(),
    author: SocialUser.fromJson((j['author'] as Map).cast<String, dynamic>()),
    text: (j['text'] ?? '').toString(),
    createdAt:
        DateTime.tryParse((j['createdAt'] ?? '').toString())?.toUtc() ??
        DateTime.now().toUtc(),
    updatedAt: (j['updatedAt'] as String?) != null
        ? DateTime.tryParse(j['updatedAt'] as String)?.toUtc()
        : null,
    deleted: j['deleted'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
  };

  SocialComment copyWith({
    String? id,
    SocialUser? author,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) => SocialComment(
    id: id ?? this.id,
    author: author ?? this.author,
    text: text ?? this.text,
    createdAt: (createdAt ?? this.createdAt).toUtc(),
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
}

class SocialPost {
  final String id;
  final SocialUser author;
  final DateTime createdAt; // 建議 UTC
  final String text;

  /// 僅保留 URL，避免 dart:io
  final String? imageUrl;

  final int likeCount;
  final bool likedByMe;
  final List<SocialComment> comments; // 不可變
  final List<String> tags; // 不可變

  /// 🔥 新增：最後編輯 & 軟刪除
  final DateTime? updatedAt;
  final bool deleted;

  SocialPost({
    required this.id,
    required this.author,
    required this.text,
    this.imageUrl,
    DateTime? createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
    List<SocialComment> comments = const [],
    List<String> tags = const [],
    this.updatedAt,
    this.deleted = false,
  }) : createdAt = (createdAt ?? DateTime.now()).toUtc(),
       comments = List.unmodifiable(comments),
       tags = List.unmodifiable(tags);

  factory SocialPost.fromJson(Map<String, dynamic> j) => SocialPost(
    id: (j['id'] ?? '').toString(),
    author: SocialUser.fromJson((j['author'] as Map).cast<String, dynamic>()),
    text: (j['text'] ?? '').toString(),
    createdAt:
        DateTime.tryParse((j['createdAt'] ?? '').toString())?.toUtc() ??
        DateTime.now().toUtc(),
    imageUrl: () {
      final v = j['imageUrl'];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }(),
    likeCount: (j['likeCount'] as num?)?.toInt() ?? 0,
    likedByMe: j['likedByMe'] == true,
    comments: ((j['comments'] as List?) ?? const [])
        .map((e) => SocialComment.fromJson((e as Map).cast<String, dynamic>()))
        .toList(),
    tags: ((j['tags'] as List?) ?? const [])
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList(),
    updatedAt: (j['updatedAt'] as String?) != null
        ? DateTime.tryParse(j['updatedAt'] as String)?.toUtc()
        : null,
    deleted: j['deleted'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author.toJson(),
    'text': text,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'likeCount': likeCount,
    'likedByMe': likedByMe,
    'comments': comments.map((e) => e.toJson()).toList(),
    'tags': tags,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
  };

  SocialPost copyWith({
    String? id,
    SocialUser? author,
    DateTime? createdAt,
    String? text,
    String? imageUrl,
    int? likeCount,
    bool? likedByMe,
    List<SocialComment>? comments,
    List<String>? tags,
    DateTime? updatedAt,
    bool? deleted,
  }) => SocialPost(
    id: id ?? this.id,
    author: author ?? this.author,
    createdAt: (createdAt ?? this.createdAt).toUtc(),
    text: text ?? this.text,
    imageUrl: imageUrl ?? this.imageUrl,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
    comments: comments == null ? this.comments : List.unmodifiable(comments),
    tags: tags == null ? this.tags : List.unmodifiable(tags),
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
  );
}

extension SocialPostExt on SocialPost {
  DateTime get lastModified => updatedAt ?? createdAt;
}
