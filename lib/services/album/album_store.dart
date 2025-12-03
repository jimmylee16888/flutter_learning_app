// lib/services/album/album_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/services/album/album_cover_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumStore extends ChangeNotifier {
  static const _prefsKey = 'albums_json';

  final List<SimpleAlbum> _albums = [];

  List<SimpleAlbum> get visibleAlbums =>
      List.unmodifiable(_albums.where((a) => !a.deleted));

  List<SimpleAlbum> get allAlbumsRaw => List.unmodifiable(_albums);

  // 👇 向下相容用：舊程式碼用 albums，多半是給畫面顯示，
  // 所以這裡回傳 visibleAlbums 即可
  List<SimpleAlbum> get albums => visibleAlbums;

  // 啟動時載入（這裡用的是完整的 toJson / fromJson，會帶 coverLocalPath）
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;

    final List data = jsonDecode(raw);
    _albums
      ..clear()
      ..addAll(
        data
            .map((e) => SimpleAlbum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_albums.map((SimpleAlbum e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  // ----------------- 新增 / 更新 / 移除 -----------------

  Future<void> add(SimpleAlbum album) async {
    final now = DateTime.now().toUtc();
    var withTime = album.copyWith(updatedAt: now, deleted: false);

    final withLocal = await _withLocalCovers(withTime);
    _albums.add(withLocal);
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final idx = _albums.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final now = DateTime.now().toUtc();
      final cur = _albums[idx];
      _albums[idx] = cur.copyWith(deleted: true, updatedAt: now);
      await _save();
      notifyListeners();
    }
  }

  Future<void> update(SimpleAlbum album) async {
    final idx = _albums.indexWhere((a) => a.id == album.id);
    if (idx >= 0) {
      final now = DateTime.now().toUtc();
      var withTime = album.copyWith(updatedAt: now, deleted: false);
      final withLocal = await _withLocalCovers(withTime);
      _albums[idx] = withLocal;
      await _save();
      notifyListeners();
    }
  }

  /// ✅ 匯入 JSON（portable）後整批換掉：也順便幫它下載封面
  Future<void> replaceAll(List<SimpleAlbum> albums) async {
    _albums.clear();

    for (final a in albums) {
      final withLocal = await _withLocalCovers(a);
      _albums.add(withLocal);
    }

    await _save();
    notifyListeners();
  }

  // ----------------- 核心：依 URL 自動下載，填 coverLocalPath -----------------

  Future<SimpleAlbum> _withLocalCovers(SimpleAlbum album) async {
    // Web 不處理本地檔案，直接略過
    if (kIsWeb) return album;

    var result = album;

    // 1️⃣ 專輯封面：如果沒有本地路徑但有 URL，就下載
    final hasLocal =
        result.coverLocalPath != null && result.coverLocalPath!.isNotEmpty;
    final hasUrl =
        result.coverUrl != null && result.coverUrl!.trim().isNotEmpty;

    if (!hasLocal && hasUrl) {
      final localPath = await downloadAlbumCoverIfNeeded(
        albumId: result.id,
        coverUrl: result.coverUrl!.trim(),
      );

      if (localPath != null && localPath.isNotEmpty) {
        result = result.copyWith(coverLocalPath: localPath);
      }
    }

    // 2️⃣ 如果之後要支援「每首歌自己的封面」，可以在這裡順便處理 tracks：
    // if (result.tracks.isNotEmpty) { ...downloadTrackCoverIfNeeded... }

    return result;
  }
}
