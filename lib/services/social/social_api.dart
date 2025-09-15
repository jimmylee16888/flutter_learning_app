// lib/services/social/social_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_learning_app/models/social_models.dart';

import 'package:flutter_learning_app/services/core/base_url.dart'
    show kSocialBaseUrl, absUrl;

enum FeedTabApi { friends, hot, following }

bool _ok(int code) => code >= 200 && code < 300;
const _timeout = Duration(seconds: 20);

class SocialApi {
  SocialApi({required this.meId, required this.meName, this.idTokenProvider});

  /// 僅用於顯示或在 Debug 模式下當作 Header（Debug <uid>）
  final String meId;

  /// 僅用於顯示或上傳至 /me（後端以 token 決定真正身份）
  final String meName;

  /// 建議傳入：() => FirebaseAuth.instance.currentUser?.getIdToken(true)
  final Future<String?> Function()? idTokenProvider;

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
        return h;
      }
    }

    // 無 token → 走 Debug 模式，後端以 Debug <uid> 放行（開發用）
    final uid = (meId.isNotEmpty ? meId : 'u_me');
    h['Authorization'] = 'Debug $uid';
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? q]) => Uri.parse(
    '$kSocialBaseUrl$path',
  ).replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));

  String _absUrl(String url) => absUrl(kSocialBaseUrl, url);

  /// 若伺服器好友清單為空、且本地(local)有資料：
  /// 1) 用本地清單回寫到後端
  /// 2) 回傳「最後採用」的集合（server 非空 → server；否則 local）
  Future<Set<String>> seedFriendsIfServerEmpty(Set<String> local) async {
    try {
      final server = await fetchMyFriends();
      if (server.isEmpty && local.isNotEmpty) {
        await updateProfile(followingUserIds: local.toList());
        return local;
      }
      return server.toSet();
    } catch (_) {
      // 伺服器失敗 → 退回本地
      return local;
    }
  }

  // ================== 檔案上傳 ==================

  Future<String?> uploadImage(File file) async {
    final req = http.MultipartRequest('POST', _uri('/upload'));
    req.headers.addAll(await _authHeaders());
    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await req.send().timeout(_timeout);
    final body = await resp.stream.bytesToString();
    if (!_ok(resp.statusCode)) {
      throw HttpException('upload failed ${resp.statusCode}: $body');
    }
    final j = jsonDecode(body) as Map<String, dynamic>;
    final raw = j['url'] as String?;
    // 後端已回相對路徑（/uploads/xxx.jpg），保留相對路徑交由 UI 再組完整網址
    return raw;
  }

  Future<String> uploadAvatar({required File file}) async {
    final req = http.MultipartRequest('POST', _uri('/upload'));
    req.headers.addAll(await _authHeaders());
    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final resp = await req.send().timeout(_timeout);
    final body = await resp.stream.bytesToString();
    if (!_ok(resp.statusCode)) {
      throw HttpException('uploadAvatar ${resp.statusCode}: $body');
    }
    final j = jsonDecode(body) as Map<String, dynamic>;
    final dynamic pick = j['url'] ?? j['avatarUrl'] ?? j['path'];
    final raw = pick?.toString();
    if (raw == null || raw.isEmpty) {
      throw const FormatException('Invalid upload response (missing "url")');
    }
    // 回完整絕對網址，方便頭像立即顯示
    return _absUrl(raw);
  }

  // ================== /me ==================

  String _mePath() => '/me';

  Future<Map<String, dynamic>> fetchMyProfile() async {
    final resp = await http
        .get(_uri(_mePath()), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('fetchMyProfile ${resp.statusCode}: ${resp.body}');
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
      // 後端以 token 覆蓋 uid，這裡的 id/name 只保留相容
      'id': meId,
      'name': meName,
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
      throw HttpException('updateProfile ${resp.statusCode}: ${resp.body}');
    }
  }

  // ================== 追蹤標籤 / 好友 ==================

  Future<List<String>> fetchFollowedTags() async {
    final resp = await http
        .get(_uri('/me/tags'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('fetchFollowedTags ${resp.statusCode}: ${resp.body}');
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
      throw HttpException('addFollowedTag ${resp.statusCode}: ${resp.body}');
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
      throw HttpException('removeFollowedTag ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) return data.map((e) => '$e').toList();
    if (data is Map && data['tags'] is List) {
      return (data['tags'] as List).map((e) => '$e').toList();
    }
    return fetchFollowedTags();
  }

  Future<List<String>> fetchMyFriends() async {
    final resp = await http
        .get(_uri('/me/friends'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('fetchMyFriends ${resp.statusCode}: ${resp.body}');
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
      throw HttpException('followUser ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final resp = await http
        .delete(_uri('/users/$userId/follow'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('unfollowUser ${resp.statusCode}: ${resp.body}');
    }
  }

  // ================== 使用者 / 貼文讀取 ==================

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final resp = await http
        .get(_uri('/users/$userId'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('fetchUserProfile ${resp.statusCode}: ${resp.body}');
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
      throw HttpException('fetchUserPosts ${resp.statusCode}: ${resp.body}');
    }
    return (jsonDecode(resp.body) as List)
        .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SocialPost>> fetchPosts({
    required FeedTabApi tab,
    List<String>? tags,
  }) async {
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
      throw HttpException('fetchPosts ${resp.statusCode}: ${resp.body}');
    }
    return (jsonDecode(resp.body) as List)
        .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ================== 發文 / 讚 / 留言 ==================

  Future<SocialPost> createPost({
    required String text,
    required List<String> tags,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }
    final body = jsonEncode({
      // author 由後端依 token 判定，不由前端決定
      'text': text,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    final resp = await http
        .post(
          _uri('/posts'),
          headers: await _authHeaders(json: true),
          body: body,
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('createPost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<SocialPost> updatePost({
    required String id,
    required String text,
    required List<String> tags,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }
    final body = jsonEncode({
      'text': text,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    final resp = await http
        .put(
          _uri('/posts/$id'),
          headers: await _authHeaders(json: true),
          body: body,
        )
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('updatePost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) async {
    final resp = await http
        .delete(_uri('/posts/$id'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('deletePost ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<SocialPost> toggleLike(String id) async {
    final resp = await http
        .post(_uri('/posts/$id/like'), headers: await _authHeaders())
        .timeout(_timeout);
    if (!_ok(resp.statusCode)) {
      throw HttpException('toggleLike ${resp.statusCode}: ${resp.body}');
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
      throw HttpException('addComment ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  // ================== 便利方法 ==================

  /// 讓 UI 不需要知道 base url 細節（相對 → 絕對）
  String resolveUrl(String url) => _absUrl(url);
}
