// lib/screens/detail/mini_cards/scan_qr_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/utils/qr/qr_codec.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as ml;
import 'package:http/http.dart' as http;

import '../../../../l10n/l10n.dart'; // i18n
import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  /// 與分享端一致的後端位址
  static const String _kApiBase = 'https://YOUR_BACKEND_HOST';

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

  /// 從相簿選擇 QR 圖片並辨識
  Future<void> _scanFromGallery() async {
    final l = context.l10n;
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final scanner = ml.BarcodeScanner(formats: [ml.BarcodeFormat.qrCode]);
    try {
      final input = ml.InputImage.fromFilePath(img.path);
      final result = await scanner.processImage(input);
      final code = result.isNotEmpty ? result.first.rawValue : null;
      if (code == null) {
        _toast(l.noQrFoundInImage);
        return;
      }
      await _handleCode(code);
    } finally {
      await scanner.close();
    }
  }

  /// 處理掃描到的 QR 內容
  Future<bool> _handleCode(String code) async {
    final l = context.l10n;
    final payload = QrCodec.decode(code);
    if (payload == null) {
      _toast(l.qrFormatInvalid);
      return false;
    }

    final out = <MiniCardData>[];

    if (payload.kind == QrPayloadKind.json && payload.json != null) {
      // 內嵌 JSON（單卡 v1/v2 或 bundle v1/v2）
      final map = payload.json!;
      final type = map['type'];
      List<Map<String, dynamic>> rawList;

      if ((type == 'mini_card_v2' || type == 'mini_card_v1') &&
          map['card'] != null) {
        rawList = [Map<String, dynamic>.from(map['card'])];
      } else if ((type == 'mini_card_bundle_v2' ||
              type == 'mini_card_bundle_v1') &&
          map['cards'] is List) {
        rawList = (map['cards'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        _toast(l.qrTypeUnsupported);
        return false;
      }

      for (final j in rawList) {
        var card = MiniCardData.fromJson(j);

        // 可選：下載圖片到本地
        if ((card.imageUrl ?? '').isNotEmpty) {
          try {
            final p = await downloadImageToLocal(
              card.imageUrl!,
              preferName: card.id,
            );
            card = card.copyWith(localPath: p);
          } catch (_) {}
        }
        if ((card.backImageUrl ?? '').isNotEmpty) {
          try {
            final p2 = await downloadImageToLocal(
              card.backImageUrl!,
              preferName: '${card.id}_back',
            );
            card = card.copyWith(backLocalPath: p2);
          } catch (_) {}
        }

        out.add(card);
      }
    } else if (payload.kind == QrPayloadKind.id && payload.id != null) {
      // 後端模式：QR 只有 id，向後端取得完整資料
      try {
        final card = await _fetchCardById(payload.id!);

        // 可選：下載圖片到本地
        var c = card;
        if ((c.imageUrl ?? '').isNotEmpty) {
          try {
            final p = await downloadImageToLocal(c.imageUrl!, preferName: c.id);
            c = c.copyWith(localPath: p);
          } catch (_) {}
        }
        if ((c.backImageUrl ?? '').isNotEmpty) {
          try {
            final p2 = await downloadImageToLocal(
              c.backImageUrl!,
              preferName: '${c.id}_back',
            );
            c = c.copyWith(backLocalPath: p2);
          } catch (_) {}
        }

        out.add(c);
      } catch (e) {
        _toast(l.fetchFromBackendFailed('$e'));
        return false;
      }
    }

    if (!mounted) return false;
    Navigator.pop(context, out);
    return true;
  }

  /// 依 id 向後端取得卡片資料
  Future<MiniCardData> _fetchCardById(String id) async {
    final uri = Uri.parse('$_kApiBase/api/cards/$id');
    final resp = await http.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);

    // 允許兩種後端回傳格式：
    // 1) 直接回傳卡片 JSON
    // 2) 包一層 { "type": "...", "owner": "...", "card": { ... } }
    final Map<String, dynamic> raw = (decoded is Map && decoded['card'] is Map)
        ? Map<String, dynamic>.from(decoded['card'])
        : Map<String, dynamic>.from(decoded as Map);

    return MiniCardData.fromJson(raw);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return WillPopScope(
      onWillPop: () async {
        try {
          await controller.stop();
        } catch (_) {}
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.scanMiniCardQrTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _scanFromGallery,
              tooltip: l.scanFromGallery,
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
            // 中間對齊框（僅視覺輔助）
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
