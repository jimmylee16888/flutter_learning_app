// lib/services/album/album_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumStore extends ChangeNotifier {
  static const _prefsKey = 'albums_json';

  final List<SimpleAlbum> _albums = [];

  List<SimpleAlbum> get albums => List.unmodifiable(_albums);

  // 啟動時載入
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

  Future<void> add(SimpleAlbum album) async {
    _albums.add(album);
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _albums.removeWhere((a) => a.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> update(SimpleAlbum album) async {
    final idx = _albums.indexWhere((a) => a.id == album.id);
    if (idx >= 0) {
      _albums[idx] = album;
      await _save();
      notifyListeners();
    }
  }

  /// ✅ 匯入 JSON 時用，一次整批換掉所有專輯
  Future<void> replaceAll(List<SimpleAlbum> albums) async {
    _albums
      ..clear()
      ..addAll(albums);
    await _save();
    notifyListeners();
  }
}
