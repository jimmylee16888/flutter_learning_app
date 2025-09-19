// lib/services/social/social_api.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter_learning_app/models/social_models.dart';
import 'package:flutter_learning_app/services/core/base_url.dart'
    show kSocialBaseUrl, absUrl;
import 'package:flutter_learning_app/models/tip_models.dart';

enum FeedTabApi { friends, hot, following }

bool _ok(int code) => code >= 200 && code < 300;
const _timeout = Duration(seconds: 20);

class SocialApi {
  SocialApi({
    required this.meId,
    required this.meName,
    this.idTokenProvider,
    this.clientId, // 可選：每台裝置固定 ID（純註記來源）
    this.clientAliasProvider, // 可選：提供「本機暱稱」，僅做 header 註記
  });

  /// 僅用於顯示或在 Debug 模式下當作 Header（Debug <uid>）
  final String meId;

  /// 僅用於顯示或上傳至 /me（後端以 token 決定真正身份）
  final String meName;

  /// 建議傳入：() => FirebaseAuth.instance.currentUser?.getIdToken(true)
  final Future<String?> Function()? idTokenProvider;

  /// 每個前端裝置的固定識別（例如 dev_xxx），用於標記貼文來源（後端不以此決定身分）
  final String? clientId;

  /// 提供「此裝置上的本機暱稱」；僅加到 X-Client-Alias header 做記錄，不影響顯示名稱
  final Future<String?> Function()? clientAliasProvider;

  // ================== 共用小工具 ==================

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final h = <String, String>{
      if (json) 'Content-Type': 'application/json; charset=utf-8',
    };

    // 優先使用 Firebase IdToken（正式驗證）
    if (idTokenProvider != null) {
      final t = await idTokenProvider!();
      if (t != null && t.isNotEmpty) {
        h['Authorization'] = 'Bearer $t';
      }
    }

    // 無 token → 走 Debug 模式，後端以 Debug <uid> 放行（開發用）
    if (!h.containsKey('Authorization')) {
      final uid = (meId.isNotEmpty ? meId : (clientId ?? 'u_me'));
      h['Authorization'] = 'Debug $uid';
    }

    // 設備與本機別名（純記錄用）
    if (clientId != null && clientId!.isNotEmpty) {
      h['X-Client-Id'] = clientId!;
    }
    if (clientAliasProvider != null) {
      final alias = await clientAliasProvider!();
      if (alias != null && alias.isNotEmpty) {
        h['X-Client-Alias'] = alias;
      }
    }

    // 冗餘身分：就算代理吃掉 Authorization，也能在 NO_AUTH=1 下被後端辨識
    h['X-Auth-Uid'] = meId;

    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? q]) => Uri.parse(
    '$kSocialBaseUrl$path',
  ).replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));

  String _absUrl(String url) => absUrl(kSocialBaseUrl, url);

  /// 若伺服器好友清單為空、且本地(local)有資料：回寫到後端
  Future<Set<String>> seedFriendsIfServerEmpty(Set<String> local) async {
    try {
      final server = await fetchMyFriends();
      if (server.isEmpty && local.isNotEmpty) {
        await updateProfile(followingUserIds: local.toList());
        return local;
      }
      return server.toSet();
    } catch (_) {
      return local;
    }
  }

  // ================== 檔案上傳（bytes 版，Web 相容） ==================

  /// 上傳圖片，回傳「相對路徑」(例如 `/uploads/xxx.jpg`)
  Future<String?> uploadImageBytes(Uint8List bytes, {String? filename}) async {
    final req = http.MultipartRequest('POST', _uri('/upload'));
    req.headers.addAll(await _authHeaders());
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename ?? 'upload.jpg',
      ),
    );

    final resp = await req.send().timeout(_timeout);
    final body = await resp.stream.bytesToString();
    if (!_ok(resp.statusCode)) {
      throw Exception('upload failed ${resp.statusCode}: $body');
    }
    final j = jsonDecode(body) as Map<String, dynamic>;
    final raw = j['url'] as String?;
    return raw;
  }

  /// 上傳大頭貼，回傳「絕對網址」（方便直接顯示）
  Future<String> uploadAvatarBytes(Uint8List bytes, {String? filename}) async {
    final req = http.MultipartRequest('POST', _uri('/upload'));
    req.headers.addAll(await _authHeaders());
    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename ?? 'avatar.jpg',
      ),
    );

    final resp = await req.send().timeout(_timeout);
    final body = await resp.stream.bytesToString();
    if (!_ok(resp.statusCode)) {
      throw Exception('uploadAvatar ${resp.statusCode}: $body');
    }
    final j = jsonDecode(body) as Map<String, dynamic>;
    final dynamic pick = j['url'] ?? j['avatarUrl'] ?? j['path'];
    final raw = pick?.toString();
    if (raw == null || raw.isEmpty) {
      throw const FormatException('Invalid upload response (missing "url")');
    }
    return _absUrl(raw);
  }

  // ================== /me ==================

  String _mePath() => '/me';

  Future<Map<String, dynamic>> fetchMyProfile() async {
    final resp = await http
        .get(_uri(_mePath()), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchMyProfile ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<void> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? instagram,
    String? facebook,
    String? lineId,
    bool? showInstagram,
    bool? showFacebook,
    bool? showLine,
    List<String>? followedTags,
    List<String>? followingUserIds,
  }) async {
    final payload = <String, dynamic>{
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (instagram != null) 'instagram': instagram,
      if (facebook != null) 'facebook': facebook,
      if (lineId != null) 'lineId': lineId,
      if (showInstagram != null) 'showInstagram': showInstagram,
      if (showFacebook != null) 'showFacebook': showFacebook,
      if (showLine != null) 'showLine': showLine,
      if (followedTags != null) 'followedTags': followedTags,
      if (followingUserIds != null) 'followingUserIds': followingUserIds,
    };

    final resp = await http
        .patch(
          _uri(_mePath()),
          headers: await _authHeaders(json: true),
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('updateProfile ${resp.statusCode}: ${resp.body}');
    }
  }

  // ================== 追蹤標籤 / 好友 ==================

  Future<List<String>> fetchFollowedTags() async {
    final resp = await http
        .get(_uri('/me/tags'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchFollowedTags ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.map((e) => '$e').toList();
    if (data is Map && data['tags'] is List) {
      return (data['tags'] as List).map((e) => '$e').toList();
    }
    return <String>[];
  }

  Future<List<String>> addFollowedTag(String tag) async {
    final resp = await http
        .post(
          _uri('/me/tags'),
          headers: await _authHeaders(json: true),
          body: jsonEncode({'tag': tag}),
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('addFollowedTag ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.map((e) => '$e').toList();
    if (data is Map && data['tags'] is List) {
      return (data['tags'] as List).map((e) => '$e').toList();
    }
    return fetchFollowedTags();
  }

  Future<List<String>> removeFollowedTag(String tag) async {
    final resp = await http
        .delete(_uri('/me/tags/$tag'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('removeFollowedTag ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.map((e) => '$e').toList();
    if (data is Map && data['tags'] is List) {
      return (data['tags'] as List).map((e) => '$e').toList();
    }
    return <String>[];
  }

  Future<List<String>> fetchMyFriends() async {
    final resp = await http
        .get(_uri('/me/friends'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchMyFriends ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.map((e) => '$e').toList();
    if (data is Map && data['friends'] is List) {
      return (data['friends'] as List).map((e) => '$e').toList();
    }
    return <String>[];
  }

  Future<void> followUser(String userId) async {
    final resp = await http
        .post(_uri('/users/$userId/follow'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('followUser ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final resp = await http
        .delete(_uri('/users/$userId/follow'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('unfollowUser ${resp.statusCode}: ${resp.body}');
    }
  }

  // ================== 使用者 / 貼文讀取 ==================

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final resp = await http
        .get(_uri('/users/$userId'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchUserProfile ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final au = data['avatarUrl'];
    if (au is String && au.isNotEmpty) {
      data['avatarUrl'] = _absUrl(au);
    }
    return data;
  }

  Future<List<SocialPost>> fetchUserPosts(String userId) async {
    final resp = await http
        .get(_uri('/users/$userId/posts'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchUserPosts ${resp.statusCode}: ${resp.body}');
    }
    return (jsonDecode(resp.body) as List)
        .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Future<List<SocialPost>> fetchPosts({
  //   required FeedTabApi tab,
  //   List<String>? tags,
  // }) async {
  //   final q = <String, dynamic>{
  //     'tab': switch (tab) {
  //       FeedTabApi.friends => 'friends',
  //       FeedTabApi.hot => 'hot',
  //       FeedTabApi.following => 'following',
  //     },
  //     if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
  //   };
  //   final resp = await http
  //       .get(_uri('/posts', q), headers: await _authHeaders())
  //       .timeout(_timeout);
  //   if (!_ok(resp.statusCode)) {
  //     throw Exception('fetchPosts ${resp.statusCode}: ${resp.body}');
  //   }
  //   return (jsonDecode(resp.body) as List)
  //       .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }

  // ================== 發文 / 讚 / 留言（bytes 版） ==================

  Future<SocialPost> createPost({
    required String text,
    required List<String> tags,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await uploadImageBytes(imageBytes, filename: filename);
    }
    final body = jsonEncode({
      'text': text,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (clientId != null) 'clientId': clientId,
    });
    final resp = await http
        .post(
          _uri('/posts'),
          headers: await _authHeaders(json: true),
          body: body,
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('createPost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<SocialPost> updatePost({
    required String id,
    required String text,
    required List<String> tags,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await uploadImageBytes(imageBytes, filename: filename);
    }
    final body = jsonEncode({
      'text': text,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (clientId != null) 'clientId': clientId,
    });
    final resp = await http
        .put(
          _uri('/posts/$id'),
          headers: await _authHeaders(json: true),
          body: body,
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('updatePost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) async {
    final resp = await http
        .delete(_uri('/posts/$id'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('deletePost ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<SocialPost> toggleLike(String id) async {
    final resp = await http
        .post(_uri('/posts/$id/like'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('toggleLike ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<SocialPost> addComment({
    required String postId,
    required String text,
  }) async {
    final body = jsonEncode({'text': text});
    final resp = await http
        .post(
          _uri('/posts/$postId/comments'),
          headers: await _authHeaders(json: true),
          body: body,
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('addComment ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  // ================== 便利方法 ==================

  /// 讓 UI 不需要知道 base url 細節（相對 → 絕對）
  String resolveUrl(String url) => _absUrl(url);

  // 1) 介面新增 friendIds
  Future<List<SocialPost>> fetchPosts({
    required FeedTabApi tab,
    List<String>? tags,
    List<String>? friendIds, // ← 新增
  }) async {
    // 如果要帶好友名單，就用 POST（避免 GET query 太長）
    if (tab == FeedTabApi.friends && friendIds != null) {
      final body = jsonEncode({
        'tab': 'friends',
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        'friendIds': friendIds, // ← 直接把好友清單交給後端
      });
      final resp = await http
          .post(
            _uri('/posts/query'), // ← 新增的查詢端點
            headers: await _authHeaders(json: true),
            body: body,
          )
          .timeout(_timeout);
      if (!_ok(resp.statusCode)) {
        throw Exception('fetchPosts(query) ${resp.statusCode}: ${resp.body}');
      }
      return (jsonDecode(resp.body) as List)
          .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 否則維持舊的 GET 行為（後端用 /me/friends 決定）
    final q = <String, dynamic>{
      'tab': switch (tab) {
        FeedTabApi.friends => 'friends',
        FeedTabApi.hot => 'hot',
        FeedTabApi.following => 'following',
      },
      if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
    };
    final resp = await http
        .get(_uri('/posts', q), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchPosts ${resp.statusCode}: ${resp.body}');
    }
    return (jsonDecode(resp.body) as List)
        .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 先在檔頭加： import 'package:flutter_learning_app/models/tip_models.dart';

  Future<TipPrompt?> fetchTipOfTheDay() async {
    // 後端可回傳 { id, title, body, imageUrl } 或 204/空陣列 表示今天不推播
    final resp = await http
        .get(_uri('/tips/today'), headers: await _authHeaders())
        .timeout(_timeout);

    if (resp.statusCode == 204 || resp.body.trim().isEmpty) return null;
    if (!_ok(resp.statusCode)) {
      throw Exception('fetchTipOfTheDay ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    Map<String, dynamic>? item;
    if (data is Map<String, dynamic>) {
      item = data;
    } else if (data is List && data.isNotEmpty && data.first is Map) {
      item = (data.first as Map).cast<String, dynamic>();
    }

    if (item == null) return null;

    // 圖片路徑若是相對路徑，轉成絕對網址
    final img = item['imageUrl'];
    if (img is String && img.isNotEmpty && img.startsWith('/')) {
      item['imageUrl'] = _absUrl(img);
    }

    final tip = TipPrompt.fromJson(item);
    if (tip.id.isEmpty) return null;
    return tip;
  }
}
