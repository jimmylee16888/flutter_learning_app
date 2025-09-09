// lib/screens/social/social_models.dart
import 'dart:io';

class SocialUser {
  final String id;
  final String name;
  final String? avatarAsset; // 先用本地 asset，未來可換後端 URL
  const SocialUser({required this.id, required this.name, this.avatarAsset});
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
}

class SocialPost {
  final String id;
  final SocialUser author;
  final DateTime createdAt;
  String text;
  List<File?> images;
  int likeCount;
  bool likedByMe;
  final List<SocialComment> comments;
  final List<String> tags;

  SocialPost({
    required this.id,
    required this.author,
    required this.text,
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
}

// ---- 假資料（之後可接後端） ----
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

// ---- 好友名片資料模型 ----
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
}
