// lib/utils/mini_card_io_impl_io.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> miniCardStorageInit() async {
  // 行動/桌面：不需要特別初始化
}

ImageProvider imageProviderForLocalPath(String path) {
  return FileImage(File(path));
}

Future<String?> pickAndCopyToLocal() async {
  final x = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 4096,
    maxHeight: 4096,
  );
  if (x == null) return null;
  final bytes = await x.readAsBytes();
  final ext = p.extension(x.path).isEmpty ? '.jpg' : p.extension(x.path);
  final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
  return _saveBytesToLocal(bytes, filename);
}

Future<String> downloadImageToLocal(String url, {String? preferName}) async {
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) {
    throw Exception('下載失敗：HTTP ${res.statusCode}');
  }
  final uriPathExt = p.extension(Uri.parse(url).path);
  final ext = uriPathExt.isEmpty ? '.jpg' : uriPathExt;
  final filename = '${preferName ?? DateTime.now().millisecondsSinceEpoch}$ext';
  return _saveBytesToLocal(res.bodyBytes, filename);
}

Future<String> _saveBytesToLocal(Uint8List bytes, String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory(p.join(dir.path, 'mini_cards'));
  if (!folder.existsSync()) folder.createSync(recursive: true);
  final fullPath = p.join(folder.path, filename);
  await File(fullPath).writeAsBytes(bytes, flush: true);
  return fullPath;
}

/// 分享（行動/桌面）
Future<void> shareLocalPath(
  String? localPath, {
  String? text,
  String? imageUrl,
}) async {
  if (localPath != null && localPath.isNotEmpty) {
    await Share.shareXFiles([XFile(localPath)], text: text);
  } else if ((imageUrl ?? '').isNotEmpty) {
    await Share.share(imageUrl!, subject: text);
  } else if ((text ?? '').isNotEmpty) {
    await Share.share(text!);
  }
}
