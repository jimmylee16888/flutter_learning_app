// lib/models/friend_card.dart
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'artists': artists,
    'phone': phone,
    'lineId': lineId,
    'facebook': facebook,
    'instagram': instagram,
  };

  static FriendCard fromJson(Map<String, dynamic> j) => FriendCard(
    id: j['id'] as String,
    nickname: j['nickname'] as String? ?? '',
    artists: (j['artists'] as List?)?.cast<String>() ?? const [],
    phone: j['phone'] as String?,
    lineId: j['lineId'] as String?,
    facebook: j['facebook'] as String?,
    instagram: j['instagram'] as String?,
  );
}
