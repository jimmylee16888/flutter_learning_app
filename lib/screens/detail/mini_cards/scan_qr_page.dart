// lib/screens/detail/mini_cards/scan_qr_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as ml;

import '../../../models/mini_card_data.dart';
import '../../../utils/mini_card_io.dart';
import 'services/qr_codec.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});
  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final controller = ms.MobileScannerController(
    formats: const [ms.BarcodeFormat.qrCode],
    detectionSpeed: ms.DetectionSpeed.normal,
    detectionTimeoutMs: 500,
    returnImage: false,
  );

  bool handled = false;

  @override
  void dispose() {
    try {
      controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _scanFromGallery() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final scanner = ml.BarcodeScanner(formats: [ml.BarcodeFormat.qrCode]);
    final input = ml.InputImage.fromFilePath(img.path);
    final result = await scanner.processImage(input);
    await scanner.close();

    final code = result.isNotEmpty ? result.first.rawValue : null;
    if (code == null) return _toast('圖片中未偵測到 QR');

    await _handleCode(code);
  }

  Future<bool> _handleCode(String code) async {
    final map = QrCodec.decodePackedJson(code);
    if (map == null) {
      _toast('QR 格式不符');
      return false;
    }

    // 轉成統一的列表
    List<Map<String, dynamic>> rawList;
    if (map['type'] == 'mini_card_v1' && map['card'] != null) {
      rawList = [Map<String, dynamic>.from(map['card'])];
    } else if (map['type'] == 'mini_card_bundle_v1' && map['cards'] is List) {
      rawList = (map['cards'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      _toast('QR 類型不支援');
      return false;
    }

    // 邊下載圖片至本地、邊去重
    final List<MiniCardData> out = [];
    for (final j in rawList) {
      var card = MiniCardData.fromJson(j).copyWith(createdAt: DateTime.now());
      if ((card.imageUrl ?? '').isNotEmpty) {
        try {
          final p = await downloadImageToLocal(
            card.imageUrl!,
            preferName: card.id,
          );
          card = card.copyWith(localPath: p);
        } catch (_) {}
      }
      final dup = out.any(
        (c) => c.id == card.id && c.imageUrl == card.imageUrl,
      );
      if (!dup) out.add(card);
    }

    if (!mounted) return false;
    Navigator.pop(context, out); // ✅ 一律回傳 List
    return true;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          await controller.stop();
        } catch (_) {}
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('掃描小卡 QR'),
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _scanFromGallery,
              tooltip: '相簿掃描',
            ),
          ],
        ),
        body: Stack(
          children: [
            ms.MobileScanner(
              controller: controller,
              onDetect: (cap) async {
                if (handled) return;
                final code = cap.barcodes.isNotEmpty
                    ? cap.barcodes.first.rawValue
                    : null;
                if (code == null) return;
                handled = true;
                try {
                  await controller.stop();
                } catch (_) {}
                try {
                  await _handleCode(code);
                } finally {
                  handled = false;
                }
              },
            ),
            // 中間對齊框
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
          ],
        ),
      ),
    );
  }
}
