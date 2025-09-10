// lib/services/social_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/social_models.dart';

/// ----- 設定後端位置 -----
/// Android 模擬器請用 10.0.2.2；
/// Windows/iOS/macOS 模擬器跑本機則用 localhost。
// const String kBaseUrl = 'http://10.0.2.2:8088';
const String kBaseUrl = 'https://socialdemo-backend.onrender.com';

// const String kBaseUrl = 'http://localhost:8088';

enum FeedTabApi { friends, hot, following }

class SocialApi {
  SocialApi({required this.meId, required this.meName});

  final String meId;
  final String meName;

  Map<String, String> _jsonHeaders() => {
    'Content-Type': 'application/json; charset=utf-8',
  };

  Uri _uri(String path, [Map<String, dynamic>? q]) => Uri.parse(
    '$kBaseUrl$path',
  ).replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));

  /// 上傳圖片到 `/upload`，回傳 JSON 的 `url`（例如 `/uploads/xxx.jpg`）
  Future<String?> uploadImage(File file) async {
    final uri = _uri('/upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final resp = await req.send();
    final body = await resp.stream.bytesToString();
    if (resp.statusCode != 200) {
      throw HttpException('upload failed ${resp.statusCode}: $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['url'] as String?;
  }

  /// 取得貼文
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
    final resp = await http.get(_uri('/posts', q));
    if (resp.statusCode != 200) {
      throw HttpException('fetchPosts ${resp.statusCode}: ${resp.body}');
    }
    final list = (jsonDecode(resp.body) as List)
        .map((e) => SocialPost.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// 新增貼文（可帶 imageFile 先上傳拿到 imageUrl）
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
      'author': {'id': meId, 'name': meName},
      'text': text,
      'tags': tags,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
    final resp = await http.post(
      _uri('/posts'),
      headers: _jsonHeaders(),
      body: body,
    );
    if (resp.statusCode != 200) {
      throw HttpException('createPost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  /// 更新貼文（可選擇重新上傳一張圖）
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
    final resp = await http.put(
      _uri('/posts/$id'),
      headers: _jsonHeaders(),
      body: body,
    );
    if (resp.statusCode != 200) {
      throw HttpException('updatePost ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) async {
    final resp = await http.delete(_uri('/posts/$id'));
    if (resp.statusCode != 200) {
      throw HttpException('deletePost ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<SocialPost> toggleLike(String id) async {
    final resp = await http.post(_uri('/posts/$id/like'));
    if (resp.statusCode != 200) {
      throw HttpException('toggleLike ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<SocialPost> addComment({
    required String postId,
    required String text,
  }) async {
    final body = jsonEncode({
      'author': {'id': meId, 'name': meName},
      'text': text,
    });
    final resp = await http.post(
      _uri('/posts/$postId/comments'),
      headers: _jsonHeaders(),
      body: body,
    );
    if (resp.statusCode != 200) {
      throw HttpException('addComment ${resp.statusCode}: ${resp.body}');
    }
    return SocialPost.fromJson(jsonDecode(resp.body) as Map<String, dynamic>);
  }
}
