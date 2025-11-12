class FriendCard {
  final String id;
  final String nickname;
  final List<String> artists; // 追蹤藝人（建議未來用 artistIds）
  final String? phone;
  final String? lineId;
  final String? facebook;
  final String? instagram;

  FriendCard({
    required this.id,
    required this.nickname,
    List<String> artists = const [],
    this.phone,
    this.lineId,
    this.facebook,
    this.instagram,
  }) : artists = List.unmodifiable(artists);

  factory FriendCard.fromJson(Map<String, dynamic> j) => FriendCard(
    id: j['id'] as String,
    nickname: (j['nickname'] ?? '') as String,
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
    artists: artists == null ? this.artists : List.unmodifiable(artists),
    phone: phone ?? this.phone,
    lineId: lineId ?? this.lineId,
    facebook: facebook ?? this.facebook,
    instagram: instagram ?? this.instagram,
  );
}
