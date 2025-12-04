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

  /// 🔥 新增：個人頁要顯示哪些區塊
  final ProfileVisibility visibility;

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
    this.visibility = const ProfileVisibility(), // 🔥 預設全開，且可用在 const ctor
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
    // 🔥 舊 JSON 沒 visibility → 用預設值，向下相容
    visibility: j['visibility'] is Map
        ? ProfileVisibility.fromJson(
            (j['visibility'] as Map).cast<String, dynamic>(),
          )
        : const ProfileVisibility(),
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
    // 🔥 永遠帶 visibility，後端可以選擇要不要存
    'visibility': visibility.toJson(),
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
    ProfileVisibility? visibility, // 🔥 新增
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
    visibility: visibility ?? this.visibility,
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

// lib/models/social_models.dart

// ================== ProfileVisibility ==================

class ProfileVisibility {
  final bool showMiniCards; // 是否顯示小卡牆
  final bool showAlbums; // 是否顯示專輯收藏
  final bool showListening; // 是否顯示常聽歌曲
  final bool showContact; // 是否顯示聯絡方式（IG / FB / Line）

  const ProfileVisibility({
    this.showMiniCards = true,
    this.showAlbums = true,
    this.showListening = true,
    this.showContact = true,
  });

  factory ProfileVisibility.fromJson(Map<String, dynamic> j) =>
      ProfileVisibility(
        showMiniCards: j['showMiniCards'] != false,
        showAlbums: j['showAlbums'] != false,
        showListening: j['showListening'] != false,
        showContact: j['showContact'] != false,
      );

  Map<String, dynamic> toJson() => {
    'showMiniCards': showMiniCards,
    'showAlbums': showAlbums,
    'showListening': showListening,
    'showContact': showContact,
  };
}

// 之後可把 SocialUser 加上：final ProfileVisibility? visibility;
// fromJson / toJson 對應 visibility 欄位即可

// ================== Board（聊天大廳的版） ==================

class Board {
  final String id;
  final String name;
  final String? description;
  final String ownerId; // 建版者
  final List<String> moderatorIds;
  final bool isOfficial;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool deleted;

  Board({
    required this.id,
    required this.name,
    required this.ownerId,
    this.description,
    List<String> moderatorIds = const [],
    this.isOfficial = false,
    this.isPrivate = false,
    DateTime? createdAt,
    this.updatedAt,
    this.deleted = false,
  }) : moderatorIds = List.unmodifiable(moderatorIds),
       createdAt = (createdAt ?? DateTime.now()).toUtc();

  factory Board.fromJson(Map<String, dynamic> j) => Board(
    id: j['id'].toString(),
    name: (j['name'] ?? '').toString(),
    description: j['description'] as String?,
    ownerId: j['ownerId'].toString(),
    moderatorIds: ((j['moderatorIds'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList(),
    isOfficial: j['isOfficial'] == true,
    isPrivate: j['isPrivate'] == true,
    createdAt:
        DateTime.tryParse('${j['createdAt'] ?? ''}')?.toUtc() ??
        DateTime.now().toUtc(),
    updatedAt: DateTime.tryParse('${j['updatedAt'] ?? ''}')?.toUtc(),
    deleted: j['deleted'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    'ownerId': ownerId,
    'moderatorIds': moderatorIds,
    'isOfficial': isOfficial,
    'isPrivate': isPrivate,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
  };
}

// ================== DM：Conversation & Message ==================

class Conversation {
  final String id;
  final bool isGroup;
  final String? name;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessagePreview; // 後端可以塞 "[專輯]" 之類的
  final int unreadCount;

  Conversation({
    required this.id,
    required this.isGroup,
    this.name,
    required this.memberIds,
    DateTime? createdAt,
    required this.lastMessageAt,
    this.lastMessagePreview,
    this.unreadCount = 0,
  }) : createdAt = (createdAt ?? DateTime.now()).toUtc();

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
    id: j['id'].toString(),
    isGroup: j['isGroup'] == true,
    name: j['name'] as String?,
    memberIds: ((j['memberIds'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList(),
    createdAt:
        DateTime.tryParse('${j['createdAt'] ?? ''}')?.toUtc() ??
        DateTime.now().toUtc(),
    lastMessageAt:
        DateTime.tryParse('${j['lastMessageAt'] ?? ''}')?.toUtc() ??
        DateTime.now().toUtc(),
    lastMessagePreview: j['lastMessagePreview'] as String?,
    unreadCount: (j['unreadCount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'isGroup': isGroup,
    if (name != null) 'name': name,
    'memberIds': memberIds,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'lastMessageAt': lastMessageAt.toUtc().toIso8601String(),
    if (lastMessagePreview != null) 'lastMessagePreview': lastMessagePreview,
    'unreadCount': unreadCount,
  };
}

enum MessageType { text, miniCard, album, artist, system }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;

  /// 純文字訊息使用
  final String? text;

  /// 小卡 / 專輯 / 藝人卡的整包 JSON snapshot
  final Map<String, dynamic>? contentJson;
  final String? contentSchema; // 例如 "miniCard_v1", "album_v1"

  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool deleted;
  final bool edited;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.text,
    this.contentJson,
    this.contentSchema,
    DateTime? createdAt,
    this.updatedAt,
    this.deleted = false,
    this.edited = false,
  }) : createdAt = (createdAt ?? DateTime.now()).toUtc();

  factory Message.fromJson(Map<String, dynamic> j) {
    MessageType parseType(String? raw) {
      switch (raw) {
        case 'miniCard':
          return MessageType.miniCard;
        case 'album':
          return MessageType.album;
        case 'artist':
          return MessageType.artist;
        case 'system':
          return MessageType.system;
        case 'text':
        default:
          return MessageType.text;
      }
    }

    Map<String, dynamic>? parseContent(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return v.cast<String, dynamic>();
      return null;
    }

    return Message(
      id: j['id'].toString(),
      conversationId: j['conversationId'].toString(),
      senderId: j['senderId'].toString(),
      type: parseType(j['type']?.toString()),
      text: j['text'] as String?,
      contentJson: parseContent(j['contentJson']),
      contentSchema: j['contentSchema'] as String?,
      createdAt:
          DateTime.tryParse('${j['createdAt'] ?? ''}')?.toUtc() ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse('${j['updatedAt'] ?? ''}')?.toUtc(),
      deleted: j['deleted'] == true,
      edited: j['edited'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderId': senderId,
    'type': switch (type) {
      MessageType.text => 'text',
      MessageType.miniCard => 'miniCard',
      MessageType.album => 'album',
      MessageType.artist => 'artist',
      MessageType.system => 'system',
    },
    if (text != null) 'text': text,
    if (contentJson != null) 'contentJson': contentJson,
    if (contentSchema != null) 'contentSchema': contentSchema,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt?.toUtc().toIso8601String(),
    'deleted': deleted,
    'edited': edited,
  };

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageType? type,
    String? text,
    Map<String, dynamic>? contentJson,
    String? contentSchema,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    bool? edited,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderId: senderId ?? this.senderId,
    type: type ?? this.type,
    text: text ?? this.text,
    contentJson: contentJson ?? this.contentJson,
    contentSchema: contentSchema ?? this.contentSchema,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deleted: deleted ?? this.deleted,
    edited: edited ?? this.edited,
  );
}
