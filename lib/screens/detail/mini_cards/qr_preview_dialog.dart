// lib/screens/detail/mini_cards/qr_preview_dialog.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'widgets/fullscreen_qr_viewer.dart'; // ← 新增這行

class QrPreviewDialog {
  static Future<void> show(BuildContext context, Uint8List pngBytes) {
    final heroTag = Object(); // 讓 Hero 動畫有個唯一 tag
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '小卡 QR code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // ← 點擊放大
                GestureDetector(
                  onTap: () {
                    Navigator.of(dialogContext).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => FullscreenQrViewer(
                          bytes: pngBytes,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: heroTag,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 360,
                        maxHeight: 360,
                      ),
                      child: FittedBox(
                        fit: BoxFit.contain, // 只縮不裁
                        child: Image.memory(
                          pngBytes,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '掃描後會將此小卡加入對方裝置',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
