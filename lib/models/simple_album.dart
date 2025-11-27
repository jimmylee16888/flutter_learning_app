import 'package:flutter/foundation.dart';

@immutable
class AlbumTrack {
  final String id;
  final String title;

  /// 各平台連結（選填）
  final String? youtubeUrl;
  final String? youtubeMusicUrl;
  final String? spotifyUrl;

  /// 單曲自己的圖片（選填，不填就用專輯圖）
  final String? coverLocalPath;

  /// 單曲自己的線上圖片 URL（選填）
  final String? coverUrl;

  const AlbumTrack({
    required this.id,
    required this.title,
    this.youtubeUrl,
    this.youtubeMusicUrl,
    this.spotifyUrl,
    this.coverLocalPath,
    this.coverUrl,
  });

  factory AlbumTrack.fromJson(Map<String, dynamic> j) => AlbumTrack(
    id: j['id'] as String,
    title: j['title'] as String,
    youtubeUrl: j['youtubeUrl'] as String?,
    youtubeMusicUrl: j['youtubeMusicUrl'] as String?,
    spotifyUrl: j['spotifyUrl'] as String?,
    coverLocalPath: j['coverLocalPath'] as String?,
    coverUrl: j['coverUrl'] as String?,
  );

  /// 本機用：完整存起來（含本地圖）
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'youtubeUrl': youtubeUrl,
    'youtubeMusicUrl': youtubeMusicUrl,
    'spotifyUrl': spotifyUrl,
    'coverLocalPath': coverLocalPath,
    'coverUrl': coverUrl,
  };

  /// ✅ 匯出用：不帶本地路徑，只保留線上圖
  Map<String, dynamic> toPortableJson() => {
    'id': id,
    'title': title,
    'youtubeUrl': youtubeUrl,
    'youtubeMusicUrl': youtubeMusicUrl,
    'spotifyUrl': spotifyUrl,
    'coverUrl': coverUrl,
  };

  AlbumTrack copyWith({
    String? id,
    String? title,
    String? youtubeUrl,
    String? youtubeMusicUrl,
    String? spotifyUrl,
    String? coverLocalPath,
    String? coverUrl,
  }) {
    return AlbumTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      youtubeMusicUrl: youtubeMusicUrl ?? this.youtubeMusicUrl,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

@immutable
class SimpleAlbum {
  final String id;
  final String title;

  /// 多位作者（通常對應 CardItem 的人名／藝名）
  final List<String> artists;

  final int? year;

  /// 語言（例如：Korean / Japanese / Chinese）
  final String? language;

  /// 版本（普通盤 / 限定盤 A / B / 初回版……）
  final String? version;

  /// 網路封面 URL
  final String? coverUrl;

  /// 本地封面路徑（透過 mini_card_io 存的 path）
  final String? coverLocalPath;

  /// 專輯整體的串流連結
  final String? youtubeUrl;
  final String? youtubeMusicUrl;
  final String? spotifyUrl;

  /// 專輯中的歌曲
  final List<AlbumTrack> tracks;

  const SimpleAlbum({
    required this.id,
    required this.title,
    this.artists = const [],
    this.year,
    this.language,
    this.version,
    this.coverUrl,
    this.coverLocalPath,
    this.youtubeUrl,
    this.youtubeMusicUrl,
    this.spotifyUrl,
    this.tracks = const [],
  });

  String get artistLabel => artists.join(', ');

  SimpleAlbum copyWith({
    String? id,
    String? title,
    List<String>? artists,
    int? year,
    String? language,
    String? version,
    String? coverUrl,
    String? coverLocalPath,
    String? youtubeUrl,
    String? youtubeMusicUrl,
    String? spotifyUrl,
    List<AlbumTrack>? tracks,
  }) {
    return SimpleAlbum(
      id: id ?? this.id,
      title: title ?? this.title,
      artists: artists ?? this.artists,
      year: year ?? this.year,
      language: language ?? this.language,
      version: version ?? this.version,
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      youtubeMusicUrl: youtubeMusicUrl ?? this.youtubeMusicUrl,
      spotifyUrl: spotifyUrl ?? this.spotifyUrl,
      tracks: tracks ?? this.tracks,
    );
  }

  factory SimpleAlbum.fromJson(Map<String, dynamic> j) {
    final List<String> artists;
    if (j['artists'] is List) {
      artists = (j['artists'] as List).cast<String>();
    } else if (j['artist'] is String) {
      artists = [(j['artist'] as String)];
    } else {
      artists = const [];
    }

    final tracksJson = j['tracks'] as List?;
    final tracks = tracksJson == null
        ? const <AlbumTrack>[]
        : tracksJson
              .map((e) => AlbumTrack.fromJson(e as Map<String, dynamic>))
              .toList(growable: false);

    return SimpleAlbum(
      id: j['id'] as String,
      title: j['title'] as String,
      artists: artists,
      year: j['year'] as int?,
      language: j['language'] as String?,
      version: j['version'] as String?,
      coverUrl: j['coverUrl'] as String?,
      coverLocalPath: j['coverLocalPath'] as String?,
      youtubeUrl: j['youtubeUrl'] as String?,
      youtubeMusicUrl: j['youtubeMusicUrl'] as String?,
      spotifyUrl: j['spotifyUrl'] as String?,
      tracks: tracks,
    );
  }

  /// 📦 本機儲存：完整（含本地封面 & 單曲本地圖）
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artists': artists,
    'year': year,
    'language': language,
    'version': version,
    'coverUrl': coverUrl,
    'coverLocalPath': coverLocalPath,
    'youtubeUrl': youtubeUrl,
    'youtubeMusicUrl': youtubeMusicUrl,
    'spotifyUrl': spotifyUrl,
    'tracks': tracks.map((t) => t.toJson()).toList(),
  };

  /// 🌐 匯出 JSON：不帶任何本地路徑，但保留完整專輯資訊 + 歌曲
  Map<String, dynamic> toPortableJson() => {
    'id': id,
    'title': title,
    'artists': artists,
    'year': year,
    'language': language,
    'version': version,
    'coverUrl': coverUrl,
    'youtubeUrl': youtubeUrl,
    'youtubeMusicUrl': youtubeMusicUrl,
    'spotifyUrl': spotifyUrl,
    'tracks': tracks.map((t) => t.toPortableJson()).toList(),
  };
}
