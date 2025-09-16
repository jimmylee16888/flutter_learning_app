// lib/utils/mini_card_io_impl_web.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> miniCardStorageInit() async {
  // Web 端不需要打開任何檔案系統，保持 no-op 即可
}

/// 依據「本地路徑字串」回傳適合的 ImageProvider（Web）
ImageProvider imageProviderForLocalPath(String path) {
  if (path.startsWith('url:')) {
    // 我們把「網址」存在 localPath 時加上 url: 前綴，這裡轉回真正的網址
    return NetworkImage(path.substring(4));
  }
  if (path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('data:')) {
    // 允許直接存 data URL 或原始 http(s) 也能顯示
    return NetworkImage(path);
  }
  // 其它不認得的情況退回 placeholder
  return const AssetImage('assets/placeholder.png');
}

/// Web 選圖：用 <input type="file"> 讀出 bytes，直接回傳 data URL 當「localPath」
Future<String?> pickAndCopyToLocal() async {
  final x = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 4096,
    maxHeight: 4096,
  );
  if (x == null) return null;

  final bytes = await x.readAsBytes();
  final mime = _guessMime(x.name); // 盡量推一個常見 mime
  final b64 = base64Encode(bytes);
  return 'data:$mime;base64,$b64';
}

/// Web 儲存「網址」：不要抓 bytes（會被 CORS 擋），直接把網址以 url: 前綴的形式存入 localPath
Future<String> downloadImageToLocal(String url, {String? preferName}) async {
  return 'url:$url';
}

/// Web 分享：沒有檔案可分享，就分享文字/網址
Future<void> shareLocalPath(
  String? localPath, {
  String? text,
  String? imageUrl,
}) async {
  final parts = <String>[];
  if (text != null && text.isNotEmpty) parts.add(text);
  if (imageUrl != null && imageUrl.isNotEmpty) parts.add(imageUrl);
  if (localPath != null &&
      localPath.startsWith('url:') &&
      localPath.length > 4) {
    parts.add(localPath.substring(4));
  }
  final content = parts.join('\n');
  if (content.isEmpty) return;

  // 用 share_plus（已裝的話）最簡單：
  // import 'package:share_plus/share_plus.dart';
  // await Share.share(content);

  // 沒裝 share_plus 也沒關係，不分享也不會當。
}

String _guessMime(String filename) {
  final lower = filename.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
