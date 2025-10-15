// lib/screens/detail/mini_cards/qr_preview_dialog.dart
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'widgets/fullscreen_qr_viewer.dart';

class QrPreviewDialog {
  /// 顯示小卡分享對話框（跨平台支援 Web / App / Desktop）
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

        const hPad = 28.0;
        const vPad = 28.0;

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
                    // 右上角：傳輸方式小圖示（API / 手機等）
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Tooltip(
                        message: transportHint,
                        preferBelow: false,
                        child: InkResponse(
                          radius: 18,
                          onTap: () {},
                          child: Icon(
                            _transportIcon(transportHint),
                            size: 18,
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    // 內容
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '小卡分享',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        // 分段切換 QR / JSON
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

                        if (tab == 0) ...[
                          // ===== QR 分頁 =====
                          if (kIsWeb) ...[
                            // Web：直接以 QrImageView 繪製（不依賴 pngBytes）
                            GestureDetector(
                              onTap: () {
                                Navigator.of(dialogContext).push(
                                  MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (_) => _WebFullscreenQr(
                                      data: jsonText,
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
                                    child: Container(
                                      color: Colors.white,
                                      child: QrImageView(
                                        data: jsonText,
                                        version: QrVersions.auto,
                                        gapless: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // App / 桌面：沿用原本的 pngBytes 顯示 + 點擊全螢幕
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
                          ],
                        ] else ...[
                          // ===== JSON 分頁 =====
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
                        Text(
                          '若 QR code 無法正常顯示可能是資料太大，建議用 JSON 傳送',
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

// ===== 工具函式：傳輸圖示（沿用你的判斷邏輯） =====

bool _isApiTransport(String hint) =>
    hint.contains('API') || hint.contains('後端');

IconData _transportIcon(String hint) =>
    _isApiTransport(hint) ? Icons.cloud_outlined : Icons.smartphone;

// ===== Web 全螢幕 QR Viewer（不依賴 bytes，直接吃 data）=====

class _WebFullscreenQr extends StatelessWidget {
  const _WebFullscreenQr({required this.data, required this.heroTag});

  final String data;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final side = math.min(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR code'),
        actions: [
          IconButton(
            tooltip: '關閉',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: side - 48,
                maxHeight: side - 48,
              ),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                gapless: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// // lib/screens/detail/mini_cards/qr_preview_dialog.dart
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'widgets/fullscreen_qr_viewer.dart';

// class QrPreviewDialog {
//   /// 顯示小卡分享對話框
//   static Future<void> show(
//     BuildContext context,
//     Uint8List? pngBytes, {
//     required String transportHint,
//     required String jsonText,
//   }) {
//     final heroTag = Object();

//     return showDialog(
//       context: context,
//       barrierDismissible: true,
//       useSafeArea: true,
//       builder: (dialogContext) {
//         final size = MediaQuery.of(dialogContext).size;

//         const hPad = 28.0;
//         const vPad = 28.0;

//         final side = math.max(
//           200.0,
//           math.min(
//             300.0,
//             math.min(size.width - hPad * 2 - 40, size.height - vPad * 2 - 200),
//           ),
//         );

//         // 0 = QR, 1 = JSON
//         int tab = 0;

//         return Dialog(
//           insetPadding: const EdgeInsets.symmetric(
//             horizontal: hPad,
//             vertical: vPad,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: StatefulBuilder(
//             builder: (ctx, setS) => SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
//                 child: Stack(
//                   children: [
//                     // 右上角：傳輸方式小圖示
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: Tooltip(
//                         message: transportHint,
//                         preferBelow: false,
//                         child: InkResponse(
//                           radius: 18,
//                           onTap: () {},
//                           child: Icon(
//                             _transportIcon(transportHint),
//                             size: 18,
//                             color: Theme.of(ctx).colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ),
//                     ),

//                     // 內容
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           '小卡分享',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),

//                         // 分段切換 QR / JSON
//                         Align(
//                           alignment: Alignment.center,
//                           child: SizedBox(
//                             width: 220,
//                             child: CupertinoSlidingSegmentedControl<int>(
//                               groupValue: tab,
//                               padding: const EdgeInsets.all(4),
//                               children: const {
//                                 0: Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 6),
//                                   child: Text('QR code'),
//                                 ),
//                                 1: Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 6),
//                                   child: Text('JSON'),
//                                 ),
//                               },
//                               onValueChanged: (v) => setS(() => tab = v ?? 0),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         if (tab == 0) ...[
//                           // ===== QR 分頁 =====
//                           if (pngBytes == null)
//                             const Padding(
//                               padding: EdgeInsets.all(20),
//                               child: CircularProgressIndicator(),
//                             )
//                           else
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.of(dialogContext).push(
//                                   MaterialPageRoute(
//                                     fullscreenDialog: true,
//                                     builder: (_) => FullscreenQrViewer(
//                                       bytes: pngBytes,
//                                       heroTag: heroTag,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Hero(
//                                 tag: heroTag,
//                                 child: ConstrainedBox(
//                                   constraints: BoxConstraints(
//                                     maxWidth: side,
//                                     maxHeight: side,
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(6),
//                                     child: FittedBox(
//                                       fit: BoxFit.contain,
//                                       child: Image.memory(
//                                         pngBytes,
//                                         filterQuality: FilterQuality.none,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ] else ...[
//                           // ===== JSON 分頁 =====
//                           ConstrainedBox(
//                             constraints: const BoxConstraints(maxHeight: 300),
//                             child: TextField(
//                               controller: TextEditingController(text: jsonText),
//                               maxLines: null,
//                               readOnly: true,
//                               decoration: const InputDecoration(
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: Wrap(
//                               spacing: 8,
//                               children: [
//                                 FilledButton.icon(
//                                   onPressed: () {
//                                     Clipboard.setData(
//                                       ClipboardData(text: jsonText),
//                                     );
//                                     ScaffoldMessenger.of(ctx).showSnackBar(
//                                       const SnackBar(content: Text('已複製 JSON')),
//                                     );
//                                   },
//                                   icon: const Icon(Icons.copy),
//                                   label: const Text('複製 JSON'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                         ],

//                         const SizedBox(height: 8),
//                         Text(
//                           '若 QR code 無法正常顯示可能是資料太大，建議用 JSON 傳送',
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.bodySmall,
//                         ),

//                         const SizedBox(height: 8),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () => Navigator.of(dialogContext).pop(),
//                             child: const Text('關閉'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// bool _isApiTransport(String hint) =>
//     hint.contains('API') || hint.contains('後端');

// IconData _transportIcon(String hint) =>
//     _isApiTransport(hint) ? Icons.cloud_outlined : Icons.smartphone;
