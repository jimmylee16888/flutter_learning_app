// lib/services/album/album_cover_cache.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String?> downloadAlbumCoverIfNeeded({
  required String albumId,
  required String coverUrl,
}) async {
  try {
    if (coverUrl.isEmpty) return null;
    if (kIsWeb) return null;

    final uri = Uri.tryParse(coverUrl);
    if (uri == null) return null;

    final baseDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(baseDir.path, 'album_covers'));

    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }

    var ext = p.extension(uri.path);
    if (ext.isEmpty) {
      ext = '.jpg';
    } else {
      ext = ext.split('?').first;
    }

    final fileName = 'album_${albumId}_cover$ext';
    final file = File(p.join(coversDir.path, fileName));

    if (await file.exists()) {
      return file.path;
    }

    final resp = await http.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return null;
    }

    await file.writeAsBytes(resp.bodyBytes);
    return file.path;
  } catch (_) {
    return null;
  }
}

/// ✅ 如果未來要給「單曲」自己一張圖，用這個
Future<String?> downloadTrackCoverIfNeeded({
  required String albumId,
  required String trackId,
  required String coverUrl,
}) async {
  try {
    if (coverUrl.isEmpty) return null;
    if (kIsWeb) return null;

    final uri = Uri.tryParse(coverUrl);
    if (uri == null) return null;

    final baseDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(baseDir.path, 'album_track_covers'));

    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }

    var ext = p.extension(uri.path);
    if (ext.isEmpty) {
      ext = '.jpg';
    } else {
      ext = ext.split('?').first;
    }

    final fileName = 'album_${albumId}_track_${trackId}_cover$ext';
    final file = File(p.join(coversDir.path, fileName));

    if (await file.exists()) {
      return file.path;
    }

    final resp = await http.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      return null;
    }

    await file.writeAsBytes(resp.bodyBytes);
    return file.path;
  } catch (_) {
    return null;
  }
}
