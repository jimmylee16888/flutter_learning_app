// lib/screens/detail/mini_cards/qr_preview_dialog.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/fullscreen_qr_viewer.dart';

class QrPreviewDialog {
  /// 顯示小卡分享對話框
  /// [pngBytes] 可能為 null（例如尚未生成 QR 或切到 JSON 分頁時不用）
  /// [transportHint] 文字說明（例如：'直接內嵌(本地)' 或 '後端模式(走 API)'）
  /// [jsonText] JSON 文字（供 JSON 分頁顯示 / 複製）
  static Future<void> show(
    BuildContext context,
    Uint8List? pngBytes, {
    required String transportHint,
    required String jsonText,
  }) {
    final heroTag = Object();

    return showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;

        // 對話框外距大一些，避免靠邊貼齊
        const hPad = 28.0;
        const vPad = 28.0;

        // 預估 QR 能舒適顯示的邊長（避免被邊角吃到）
        final side = math.max(
          200.0,
          math.min(
            300.0,
            math.min(size.width - hPad * 2 - 40, size.height - vPad * 2 - 200),
          ),
        );

        // 0 = QR, 1 = JSON
        int tab = 0;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: vPad,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (ctx, setS) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Stack(
                  children: [
                    // 右上角：傳輸方式小圖示（不佔一整行）
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Tooltip(
                        message: transportHint,
                        preferBelow: false,
                        child: InkResponse(
                          radius: 18,
                          onTap: () {}, // 預留：需要可改成顯示說明對話框
                          child: Icon(
                            _transportIcon(transportHint),
                            size: 18,
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    // 主要內容
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 標題
                        Text(
                          '小卡分享',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        // 滑動開關：QR / JSON
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 220,
                            child: CupertinoSlidingSegmentedControl<int>(
                              groupValue: tab,
                              padding: const EdgeInsets.all(4),
                              children: const {
                                0: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text('QR code'),
                                ),
                                1: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Text('JSON'),
                                ),
                              },
                              onValueChanged: (v) => setS(() => tab = v ?? 0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 內容：依分頁切換
                        if (tab == 0) ...[
                          // ====== QR 分頁 ======
                          if (pngBytes == null)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            )
                          else
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
                                  constraints: BoxConstraints(
                                    maxWidth: side,
                                    maxHeight: side,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Image.memory(
                                        pngBytes,
                                        filterQuality: FilterQuality.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ] else ...[
                          // ====== JSON 分頁 ======
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: TextField(
                              controller: TextEditingController(text: jsonText),
                              maxLines: null,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 8,
                              children: [
                                FilledButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: jsonText),
                                    );
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text('已複製 JSON')),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('複製 JSON'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],

                        const SizedBox(height: 8),
                        // 固定提示
                        Text(
                          '若 QR code 無法正常顯示可能是資料太大，建議用 JSON 傳送',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 8),
                        // 關閉按鈕
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('關閉'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 判斷是否為 API/後端模式（用於決定右上角 icon）
bool _isApiTransport(String hint) =>
    hint.contains('API') || hint.contains('後端');

/// 本地(內嵌)用手機圖示；API 用雲朵圖示
IconData _transportIcon(String hint) =>
    _isApiTransport(hint) ? Icons.cloud_outlined : Icons.smartphone;
