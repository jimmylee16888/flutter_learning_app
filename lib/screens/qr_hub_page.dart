import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as ml;

import '../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart';

/// QrHubPage：可切換「掃描」與「分享」兩個分頁
class QrHubPage extends StatefulWidget {
  const QrHubPage({
    super.key,
    required this.ownerTitle, // 例如 idol 名稱
    required this.cards, // 本地小卡清單
    required this.onImport, // 掃描成功後的匯入回呼
  });

  final String ownerTitle;
  final List<MiniCardData> cards;
  final Future<bool> Function(MiniCardData newCard) onImport;

  @override
  State<QrHubPage> createState() => _QrHubPageState();
}

class _QrHubPageState extends State<QrHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 工具'),
        bottom: TabBar(
          controller: _tc,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: '掃描'),
            Tab(icon: Icon(Icons.ios_share), text: '分享'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tc,
        children: [
          _ScanTab(onImport: widget.onImport),
          _ShareTab(ownerTitle: widget.ownerTitle, cards: widget.cards),
        ],
      ),
    );
  }
}

/* -------------------- 分頁 1：掃描 -------------------- */
class _ScanTab extends StatefulWidget {
  const _ScanTab({required this.onImport});
  final Future<bool> Function(MiniCardData newCard) onImport;

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  // 相機即時掃描：mobile_scanner
  final ms.MobileScannerController _controller = ms.MobileScannerController(
    formats: [ms.BarcodeFormat.qrCode], // ← 用 ms.
    detectionSpeed: ms.DetectionSpeed.normal, // ← 用 ms.
    detectionTimeoutMs: 500,
    returnImage: false,
  );

  // 相簿單張圖片掃描：ML Kit
  final ml.BarcodeScanner _barcodeScanner = ml.BarcodeScanner(
    formats: [ml.BarcodeFormat.qrCode], // ← 用 ml.
  );

  final ImagePicker _picker = ImagePicker();

  bool _handled = false;
  bool _busyGallery = false;

  @override
  void dispose() {
    _barcodeScanner.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ms.MobileScanner(
          // ← 用 ms.
          controller: _controller,
          onDetect: (ms.BarcodeCapture capture) async {
            // ← 型別用 ms.
            if (_handled) return;
            final barcode = capture.barcodes.isNotEmpty
                ? capture.barcodes.first
                : null;
            final raw = barcode?.rawValue;
            if (raw == null) return;

            try {
              final payload = _decodePackedJson(raw);
              if (payload == null ||
                  payload['type'] != 'mini_card_v1' ||
                  payload['card'] == null) {
                _snack(context, 'QR 格式不符');
                return;
              }
              final newCard = MiniCardData.fromJson(
                Map<String, dynamic>.from(payload['card']),
              );
              _handled = true;
              final ok = await widget.onImport(newCard);
              if (!mounted) return;
              _snack(context, ok ? '已匯入小卡並儲存' : '已存在或失敗');
            } finally {
              Future.delayed(
                const Duration(milliseconds: 1200),
                () => _handled = false,
              );
              _busyGallery = false;
            }
          },
        ),

        // 中間取景框
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // 右下角：相簿掃描 & 手電筒
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 從相簿挑一張圖片並解析 QR
              FloatingActionButton.extended(
                heroTag: 'pick_gallery_qr',
                onPressed: _busyGallery ? null : _scanFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('相簿掃描'),
              ),
              const SizedBox(height: 8),
              // // 切換手電筒（可選）
              // FloatingActionButton(
              //   heroTag: 'toggle_torch',
              //   onPressed: () async {
              //     try {
              //       await _controller.toggleTorch();
              //       if (mounted) setState(() => _torchOn = !_torchOn);
              //     } catch (_) {
              //       _snack(context, '此裝置不支援手電筒');
              //     }
              //   },
              //   tooltip: _torchOn ? '關閉手電筒' : '開啟手電筒',
              //   child: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  /// 從相簿挑一張圖片 → 交給 controller.analyzeImage() 解析 QR
  Future<void> _scanFromGallery() async {
    if (_busyGallery) return;
    _busyGallery = true;
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
      if (img == null) {
        _busyGallery = false;
        return;
      }

      final input = ml.InputImage.fromFilePath(img.path); // ← 用 ml.
      final barcodes = await _barcodeScanner.processImage(input);

      if (barcodes.isEmpty) {
        _snack(context, '圖片中未偵測到 QR');
        _busyGallery = false;
        return;
      }

      final raw = barcodes.first.rawValue;
      if (raw == null || raw.isEmpty) {
        _snack(context, '讀取失敗，換張試試');
        _busyGallery = false;
        return;
      }

      final payload = _decodePackedJson(raw);
      if (payload == null ||
          payload['type'] != 'mini_card_v1' ||
          payload['card'] == null) {
        _snack(context, 'QR 格式不符');
        _busyGallery = false;
        return;
      }

      final newCard = MiniCardData.fromJson(
        Map<String, dynamic>.from(payload['card']),
      );
      _handled = true;
      final ok = await widget.onImport(newCard);
      if (!mounted) return;
      _snack(context, ok ? '已匯入小卡並儲存' : '已存在或失敗');
    } catch (e) {
      _snack(context, '相簿掃描失敗：$e');
    } finally {
      Future.delayed(const Duration(milliseconds: 800), () {
        _handled = false;
        _busyGallery = false;
      });
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/* -------------------- 分頁 2：分享（選小卡→顯示 QR） -------------------- */
class _ShareTab extends StatelessWidget {
  const _ShareTab({required this.ownerTitle, required this.cards});
  final String ownerTitle;
  final List<MiniCardData> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Text('目前沒有小卡可分享', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return GestureDetector(
          onTap: () => _showQr(context, ownerTitle, c),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: imageProviderOf(c), fit: BoxFit.cover),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: Text(
                        c.note.isEmpty ? '(點我分享 QR)' : c.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQr(BuildContext context, String ownerTitle, MiniCardData card) {
    final payload = {
      'type': 'mini_card_v1',
      'owner': ownerTitle,
      'card': card.toJson(),
    };
    final data = _encodePackedJson(payload);

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('分享小卡 QR'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 240,
                gapless: false,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                '對方掃描後即可將此小卡加入裝置',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
}

String _encodePackedJson(Map<String, dynamic> obj) {
  final raw = utf8.encode(jsonEncode(obj));
  final gz = gzip.encode(raw);
  return 'gz:' + base64UrlEncode(gz);
}

Map<String, dynamic>? _decodePackedJson(String s) {
  try {
    if (s.startsWith('gz:')) {
      final gz = base64Url.decode(s.substring(3));
      final raw = gzip.decode(gz);
      return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
    }
    return jsonDecode(s) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
