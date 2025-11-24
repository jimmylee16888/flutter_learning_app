// lib/screens/detail/mini_cards/scan_qr_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/utils/qr/qr_codec.dart';
import 'package:flutter_learning_app/utils/qr/gallery_decoder_stub.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
//     as ml;
import 'package:http/http.dart' as http;

import '../../../../l10n/l10n.dart'; // i18n
import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io/mini_card_io.dart';

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  /// 與分享端一致的後端位址
  static const String _kApiBase = 'https://YOUR_BACKEND_HOST';

  late final GalleryQrDecoder _galleryDecoder = createGalleryDecoder();

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
    final l = context.l10n;
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    // 讀成 bytes（Web / 手機都通）
    final Uint8List bytes = await img.readAsBytes();
    final code = await _galleryDecoder.decode(bytes);

    if (code == null) {
      _toast(l.noQrFoundInImage);
      return;
    }
    await _handleCode(code);
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
      // 內嵌 JSON（單卡/多卡）
      final map = payload.json!;
      final type = map['type'];
      // ⬇️ 讀取 owner（我們在分享時有放 owner）
      final String? owner = (map['owner'] as String?)?.trim();

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

        // ⬇️ 若 QR 有帶 owner，就把 idol 設成 owner
        if (owner != null && owner.isNotEmpty) {
          card = card.copyWith(idol: owner);
        }

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
      // 後端模式
      try {
        final card = await _fetchCardById(payload.id!);
        out.add(card);
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

    String? owner;
    late Map<String, dynamic> raw;

    // 允許兩種：包 card 或直接回卡
    if (decoded is Map && decoded['card'] is Map) {
      owner = (decoded['owner'] as String?)?.trim(); // ⬅️ 讀 owner
      raw = Map<String, dynamic>.from(decoded['card']);
    } else {
      raw = Map<String, dynamic>.from(decoded as Map);
      // 有些後端可能把 owner 放同層
      owner = (raw['owner'] as String?)?.trim() ?? owner;
    }

    var c = MiniCardData.fromJson(raw);
    if (owner != null && owner.isNotEmpty) {
      c = c.copyWith(idol: owner); // ⬅️ 回填 idol
    }
    return c;
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
