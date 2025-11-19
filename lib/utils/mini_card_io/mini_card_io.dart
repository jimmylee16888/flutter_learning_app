// lib/utils/mini_card_io/mini_card_io.dart
import 'package:flutter/material.dart';

// 平台實作（IO / Web）
import 'mini_card_io_impl_io.dart'
    if (dart.library.html) 'mini_card_io_impl_web.dart'
    as impl;

// 你的資料模型
import '../../models/mini_card_data.dart';
import '../../models/card_item.dart';

import 'package:flutter/foundation.dart' show kIsWeb; // 👈 新增
import 'package:share_plus/share_plus.dart'; // 👈 新增

const String _kPlaceholderAsset = 'assets/images/mini_card_placeholder.png';

/// 啟動時呼叫：Web 會初始化 Hive/開 box；行動/桌面是 no-op
Future<void> miniCardStorageInit() => impl.miniCardStorageInit();

/// 低階：將「本地儲存位置」轉為 ImageProvider（IO=FileImage；Web=Hive/Memory/URL）
ImageProvider imageProviderForLocalPath(String path) =>
    impl.imageProviderForLocalPath(path);

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
  return const AssetImage(_kPlaceholderAsset);
}

/// 給 CardItem 用的 ImageProvider
ImageProvider imageProviderOfCardItem(CardItem c) {
  if ((c.localPath ?? '').isNotEmpty) {
    return imageProviderForLocalPath(c.localPath!);
  }
  if ((c.imageUrl ?? '').isNotEmpty) {
    return NetworkImage(c.imageUrl!);
  }
  return const AssetImage(_kPlaceholderAsset);
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
  await impl.shareLocalPath(
    ready.localPath,
    text: note,
    imageUrl: ready.imageUrl,
  );
}

/// 分享多張圖片：
/// - 行動/桌面：一次丟多個檔案給系統分享（Share.shareXFiles）
/// - Web：退回舊邏輯（逐張呼叫 sharePhoto）
Future<void> sharePhotos(List<MiniCardData> cards) async {
  // Web 版：現在就沿用原本一張一張 share 的行為，避免 localPath 格式不相容
  if (kIsWeb) {
    for (final c in cards) {
      await sharePhoto(c);
    }
    return;
  }

  // 行動/桌面：真正多張分享
  final files = <XFile>[];
  final buffer = StringBuffer();

  for (final c in cards) {
    final ready = await ensureLocalCopy(c);
    final path = ready.localPath;

    if (path == null || path.isEmpty) {
      continue;
    }

    files.add(XFile(path));

    if (ready.note.isNotEmpty) {
      buffer.writeln(ready.note);
    }
  }

  if (files.isEmpty) {
    throw Exception('no images to share');
  }

  final text = buffer.toString().trim();
  await Share.shareXFiles(files, text: text.isEmpty ? null : text);
}
