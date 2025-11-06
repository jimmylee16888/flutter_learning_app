// lib/utils/mini_card_io.dart
import 'package:flutter/material.dart';

// 平台實作（IO / Web）
import 'mini_card_io_impl_io.dart' if (dart.library.html) 'mini_card_io_impl_web.dart' as impl;

// 你的資料模型
import '../../models/mini_card_data.dart';
import '../../models/card_item.dart';

/// 啟動時呼叫：Web 會初始化 Hive/開 box；行動/桌面是 no-op
Future<void> miniCardStorageInit() => impl.miniCardStorageInit();

/// 低階：將「本地儲存位置」轉為 ImageProvider（IO=FileImage；Web=Hive/Memory/URL）
ImageProvider imageProviderForLocalPath(String path) => impl.imageProviderForLocalPath(path);

/// 低階：從相簿挑一張並存入「平台持久化」
Future<String?> pickAndCopyToLocal() => impl.pickAndCopyToLocal();

/// 低階：下載圖片並存入「平台持久化」
Future<String> downloadImageToLocal(String url, {String? preferName}) =>
    impl.downloadImageToLocal(url, preferName: preferName);

/// ─────────────────────────────────────────────────────────────
/// 便捷函式：維持你既有程式碼呼叫點不變
/// ─────────────────────────────────────────────────────────────

/// 給 MiniCardData 用的 ImageProvider（先本地、再 URL、最後 placeholder）
ImageProvider imageProviderOf(MiniCardData c) {
  if ((c.localPath ?? '').isNotEmpty) {
    return imageProviderForLocalPath(c.localPath!);
  }
  if ((c.imageUrl ?? '').isNotEmpty) {
    return NetworkImage(c.imageUrl!);
  }
  return const AssetImage('assets/placeholder.png');
}

/// 給 CardItem 用的 ImageProvider
ImageProvider imageProviderOfCardItem(CardItem c) {
  if ((c.localPath ?? '').isNotEmpty) {
    return imageProviderForLocalPath(c.localPath!);
  }
  if ((c.imageUrl ?? '').isNotEmpty) {
    return NetworkImage(c.imageUrl!);
  }
  return const AssetImage('assets/placeholder.png');
}

/// 若本地沒有檔案（或 Web 沒有 Hive key）而有 imageUrl，則下載一份放到本地/IndexedDB
Future<MiniCardData> ensureLocalCopy(MiniCardData c) async {
  final hasLocal = (c.localPath ?? '').isNotEmpty;
  if (hasLocal) return c;
  if ((c.imageUrl ?? '').isEmpty) return c;
  final saved = await downloadImageToLocal(c.imageUrl!, preferName: c.id);
  return c.copyWith(localPath: saved);
}

/// 分享圖片：行動/桌面會用分享檔案；Web 退而分享網址或文字
Future<void> sharePhoto(MiniCardData c) async {
  final ready = await ensureLocalCopy(c);
  final note = c.note.isEmpty ? null : c.note;
  await impl.shareLocalPath(ready.localPath, text: note, imageUrl: ready.imageUrl);
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

// import '../models/mini_card_data.dart';
// import '../models/card_item.dart';

// ImageProvider imageProviderOf(MiniCardData c) {
//   if (c.localPath != null &&
//       c.localPath!.isNotEmpty &&
//       File(c.localPath!).existsSync()) {
//     return FileImage(File(c.localPath!));
//   }
//   if (c.imageUrl != null && c.imageUrl!.isNotEmpty) {
//     return NetworkImage(c.imageUrl!);
//   }
//   return const AssetImage('assets/placeholder.png');
// }

// Future<String> _saveBytesToLocal(Uint8List bytes, String filename) async {
//   final dir = await getApplicationDocumentsDirectory();
//   final folder = Directory(p.join(dir.path, 'mini_cards'));
//   if (!folder.existsSync()) folder.createSync(recursive: true);
//   final fullPath = p.join(folder.path, filename);
//   await File(fullPath).writeAsBytes(bytes, flush: true);
//   return fullPath;
// }

// extension _IfEmpty on String {
//   String ifEmpty(String fallback) => isEmpty ? fallback : this;
// }

// Future<String> downloadImageToLocal(String url, {String? preferName}) async {
//   final res = await http.get(Uri.parse(url));
//   if (res.statusCode != 200) throw Exception('下載失敗：HTTP ${res.statusCode}');
//   final ext = p.extension(Uri.parse(url).path).ifEmpty('.jpg');
//   final filename =
//       (preferName ?? DateTime.now().millisecondsSinceEpoch.toString()) + ext;
//   return _saveBytesToLocal(res.bodyBytes, filename);
// }

// Future<String?> pickAndCopyToLocal() async {
//   final picker = ImagePicker();
//   final x = await picker.pickImage(
//     source: ImageSource.gallery,
//     maxWidth: 4096,
//     maxHeight: 4096,
//   );
//   if (x == null) return null;
//   final bytes = await x.readAsBytes();
//   final ext = p.extension(x.path).ifEmpty('.jpg');
//   final filename = DateTime.now().millisecondsSinceEpoch.toString() + ext;
//   return _saveBytesToLocal(bytes, filename);
// }

// Future<MiniCardData> ensureLocalCopy(MiniCardData c) async {
//   if (c.localPath != null && File(c.localPath!).existsSync()) return c;
//   if ((c.imageUrl ?? '').isNotEmpty) {
//     final path = await downloadImageToLocal(c.imageUrl!, preferName: c.id);
//     return c.copyWith(localPath: path);
//   }
//   return c;
// }

// Future<void> sharePhoto(MiniCardData c) async {
//   final ready = await ensureLocalCopy(c);
//   if (ready.localPath == null) throw Exception('沒有可分享的本地照片');
//   await Share.shareXFiles([
//     XFile(ready.localPath!),
//   ], text: c.note.isEmpty ? null : c.note);
// }

// ImageProvider imageProviderOfCardItem(CardItem c) {
//   if ((c.localPath ?? '').isNotEmpty && File(c.localPath!).existsSync()) {
//     return FileImage(File(c.localPath!));
//   }
//   if ((c.imageUrl ?? '').isNotEmpty) {
//     return NetworkImage(c.imageUrl!);
//   }
//   return const AssetImage('assets/placeholder.png');
// }
