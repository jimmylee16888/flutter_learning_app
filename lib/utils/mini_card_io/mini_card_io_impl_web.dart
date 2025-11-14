// lib/utils/mini_card_io/mini_card_io_impl_web.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

const String _kPlaceholderAsset = 'assets/images/mini_card_placeholder.png';

Future<void> miniCardStorageInit() async {
  if (!kIsWeb) return;
  await Hive.initFlutter();
  if (!Hive.isBoxOpen('blob_store')) {
    await Hive.openBox('blob_store');
  }
}

Box _blobBox() {
  // 假設 main() 一定有先呼叫 miniCardStorageInit()
  return Hive.box('blob_store');
}

/// Web：將「本地路徑字串」轉成 ImageProvider
/// 支援：
///  - 'hive:<id>'  → 取 bytes → MemoryImage
///  - 'data:...'   → base64 → MemoryImage（兼容舊資料）
///  - 'url:<...>'  → NetworkImage
///  - 'http(s):// → NetworkImage
///  - 'assets/...' → AssetImage
/// 其餘回 placeholder
ImageProvider imageProviderForLocalPath(String path) {
  if (path.startsWith('hive:')) {
    final id = path.substring(5);
    final box = _blobBox();
    final m = box.get(id);
    if (m == null) return const AssetImage(_kPlaceholderAsset);
    final bytes = m['bytes'];
    if (bytes is Uint8List && bytes.isNotEmpty) {
      return MemoryImage(bytes);
    }
    return const AssetImage(_kPlaceholderAsset);
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

  return const AssetImage(_kPlaceholderAsset);
}

/// Web：從相簿挑圖 → 存到 Hive（IndexedDB）→ 回傳 'hive:<id>'
Future<String?> pickAndCopyToLocal() async {
  final x = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 4096,
    maxHeight: 4096,
  );
  if (x == null) return null;

  final bytes = await x.readAsBytes();
  final mime = lookupMimeType(x.name, headerBytes: bytes) ?? 'image/jpeg';
  final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${x.name.hashCode}';

  final box = _blobBox();
  await box.put(id, {
    'bytes': bytes,
    'mime': mime,
    'name': x.name,
    'ts': DateTime.now().toIso8601String(),
  });

  return 'hive:$id';
}

/// Web：跨網域下載會被 CORS 擋；直接回 'url:<原網址>'，讓 UI 用 NoCorsImage 顯示
Future<String> downloadImageToLocal(String url, {String? preferName}) async {
  return 'url:$url';
}

/// Web 分享：只能分享文字/連結（hive: 無法直接分享）
///（若已加 share_plus_web，可改成 Share.share(content)）
Future<void> shareLocalPath(
  String? localPath, {
  String? text,
  String? imageUrl,
}) async {
  final parts = <String>[];
  if ((text ?? '').isNotEmpty) parts.add(text!);
  if ((imageUrl ?? '').isNotEmpty) parts.add(imageUrl!);
  if ((localPath ?? '').startsWith('url:')) {
    parts.add(localPath!.substring(4));
  }
  final content = parts.join('\n');
  if (content.isEmpty) return;

  // TODO: 之後可以接 share_plus_web
  // debugPrint('[web-share] $content');
}

///（可選）把舊的 data: 圖片搬進 Hive，回傳新的 'hive:<id>'
Future<String?> migrateDataUrlToHive(String? dataUrl) async {
  if (dataUrl == null || !dataUrl.startsWith('data:')) return null;
  final comma = dataUrl.indexOf(',');
  if (comma <= 0 || !dataUrl.substring(0, comma).contains(';base64')) {
    return null;
  }

  final bytes = base64Decode(dataUrl.substring(comma + 1));
  final mime = dataUrl.substring(5, dataUrl.indexOf(';', 5));
  final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${bytes.hashCode}';
  final box = _blobBox();
  await box.put(id, {
    'bytes': bytes,
    'mime': mime,
    'name': 'migrated',
    'ts': DateTime.now().toIso8601String(),
  });
  return 'hive:$id';
}
