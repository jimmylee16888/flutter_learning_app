// lib/utils/mini_card_io_impl_web.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

Future<void> miniCardStorageInit() async {
  if (!kIsWeb) return;
  await Hive.initFlutter();
  if (!Hive.isBoxOpen('blob_store')) {
    await Hive.openBox('blob_store');
  }
}

/// Web：將「本地路徑字串」轉成 ImageProvider
/// 支援：
///  - 'hive:<id>'  → 取 bytes → MemoryImage
///  - 'data:...'   → base64 → MemoryImage（兼容舊資料）
///  - 'url:<...>'  → NetworkImage
///  - 'http(s):// → NetworkImage
/// 其餘回 placeholder
ImageProvider imageProviderForLocalPath(String path) {
  if (path.startsWith('hive:')) {
    final id = path.substring(5);
    final box = Hive.box('blob_store');
    final m = box.get(id);
    if (m == null) return MemoryImage(Uint8List(0));
    final Uint8List bytes = (m['bytes'] as Uint8List);
    return MemoryImage(bytes);
  }
  if (path.startsWith('data:')) {
    final i = path.indexOf(',');
    if (i > 0) {
      final b64 = path.substring(i + 1);
      return MemoryImage(base64Decode(b64));
    }
  }
  if (path.startsWith('url:')) return NetworkImage(path.substring(4));
  if (path.startsWith('http')) return NetworkImage(path);
  if (path.startsWith('assets/')) return AssetImage(path);
  return const AssetImage('assets/placeholder.png');
}

/// Web：從相簿挑圖 → 存到 Hive（IndexedDB）→ 回傳 'hive:<id>'
Future<String?> pickAndCopyToLocal() async {
  final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 4096, maxHeight: 4096);
  if (x == null) return null;

  final bytes = await x.readAsBytes();
  final mime = lookupMimeType(x.name, headerBytes: bytes) ?? 'image/jpeg';
  final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${x.name.hashCode}';

  final box = Hive.box('blob_store');
  await box.put(id, {'bytes': bytes, 'mime': mime, 'name': x.name, 'ts': DateTime.now().toIso8601String()});

  return 'hive:$id';
}

/// Web：跨網域下載會被 CORS 擋；直接回 'url:<原網址>'，讓 UI 用 NoCorsImage 顯示
Future<String> downloadImageToLocal(String url, {String? preferName}) async {
  return 'url:$url';
}

/// Web 分享：只能分享文字/連結（hive: 無法直接分享）
///（若已加 share_plus，可改成 Share.share(content)）
Future<void> shareLocalPath(String? localPath, {String? text, String? imageUrl}) async {
  final parts = <String>[];
  if ((text ?? '').isNotEmpty) parts.add(text!);
  if ((imageUrl ?? '').isNotEmpty) parts.add(imageUrl!);
  if ((localPath ?? '').startsWith('url:')) parts.add(localPath!.substring(4));
  final content = parts.join('\n');
  if (content.isEmpty) return;
  // print('[web-share] $content');
}

///（可選）把舊的 data: 圖片搬進 Hive，回傳新的 'hive:<id>'
Future<String?> migrateDataUrlToHive(String? dataUrl) async {
  if (dataUrl == null || !dataUrl.startsWith('data:')) return null;
  final comma = dataUrl.indexOf(',');
  if (comma <= 0 || !dataUrl.substring(0, comma).contains(';base64')) return null;
  final bytes = base64Decode(dataUrl.substring(comma + 1));
  final mime = dataUrl.substring(5, dataUrl.indexOf(';', 5));
  final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${bytes.hashCode}';
  final box = Hive.box('blob_store');
  await box.put(id, {'bytes': bytes, 'mime': mime, 'name': 'migrated', 'ts': DateTime.now().toIso8601String()});
  return 'hive:$id';
}

// // lib/utils/mini_card_io_impl_web.dart
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// Future<void> miniCardStorageInit() async {
//   // Web：no-op
// }

// /// 依據「本地路徑字串」回傳適合的 ImageProvider（Web）
// ImageProvider imageProviderForLocalPath(String path) {
//   // 1) 我們把「網址」以 url: 前綴存 localPath，這裡轉回真正的網址
//   if (path.startsWith('url:')) {
//     return NetworkImage(path.substring(4));
//   }

//   // 2) 直接支援 http(s)
//   if (path.startsWith('http://') || path.startsWith('https://')) {
//     return NetworkImage(path);
//   }

//   // 3) data URL → 直接轉成 bytes，用 MemoryImage（比起 data: 當網路圖更穩）
//   if (path.startsWith('data:')) {
//     try {
//       final bytes = _decodeDataUrlToBytes(path);
//       if (bytes != null && bytes.isNotEmpty) {
//         return MemoryImage(bytes);
//       }
//     } catch (_) {
//       // 失敗就掉到 placeholder
//     }
//   }

//   // 4) assets 路徑
//   if (path.startsWith('assets/')) {
//     return AssetImage(path);
//   }

//   // 5) 其他未知情況 → placeholder
//   return const AssetImage('assets/placeholder.png');
// }

// /// Web 選圖：用 <input type="file"> 讀出 bytes，直接回傳 data URL 當「localPath」
// Future<String?> pickAndCopyToLocal() async {
//   final x = await ImagePicker().pickImage(
//     source: ImageSource.gallery,
//     maxWidth: 4096,
//     maxHeight: 4096,
//   );
//   if (x == null) return null;

//   final bytes = await x.readAsBytes();
//   final mime = _guessMime(x.name);
//   final b64 = base64Encode(bytes);
//   return 'data:$mime;base64,$b64';
// }

// /// Web 儲存「網址」：不要抓 bytes（會被 CORS 擋），直接把網址以 url: 前綴存入 localPath
// Future<String> downloadImageToLocal(String url, {String? preferName}) async {
//   return 'url:$url';
// }

// /// Web 分享：沒有檔案可分享，就分享文字/網址（可視需要接 share_plus）
// Future<void> shareLocalPath(
//   String? localPath, {
//   String? text,
//   String? imageUrl,
// }) async {
//   final parts = <String>[];
//   if (text != null && text.isNotEmpty) parts.add(text);
//   if (imageUrl != null && imageUrl.isNotEmpty) parts.add(imageUrl);
//   if (localPath != null &&
//       localPath.startsWith('url:') &&
//       localPath.length > 4) {
//     parts.add(localPath.substring(4));
//   }
//   final content = parts.join('\n');
//   if (content.isEmpty) return;
//   // 若已安裝 share_plus，可啟用：
//   // import 'package:share_plus/share_plus.dart';
//   // await Share.share(content);
// }

// String _guessMime(String filename) {
//   final lower = filename.toLowerCase();
//   if (lower.endsWith('.png')) return 'image/png';
//   if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
//   if (lower.endsWith('.gif')) return 'image/gif';
//   if (lower.endsWith('.webp')) return 'image/webp';
//   return 'image/jpeg';
// }

// /// 解析 data URL -> bytes
// Uint8List? _decodeDataUrlToBytes(String dataUrl) {
//   // 形式：data:<mime>;base64,<payload>
//   final idx = dataUrl.indexOf(',');
//   if (idx <= 0) return null;
//   final meta = dataUrl.substring(0, idx);
//   final payload = dataUrl.substring(idx + 1);
//   if (!meta.contains(';base64')) return null;
//   return base64Decode(payload);
// }
