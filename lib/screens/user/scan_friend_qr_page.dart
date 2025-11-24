// lib/screens/social/scan_friend_qr_page.dart
import 'dart:convert'; // 👈 新增：解析 QR JSON
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart';
import 'package:flutter_learning_app/utils/qr/gallery_decoder_stub.dart';

class ScanFriendQrPage extends StatefulWidget {
  const ScanFriendQrPage({super.key});

  @override
  State<ScanFriendQrPage> createState() => _ScanFriendQrPageState();
}

class _ScanFriendQrPageState extends State<ScanFriendQrPage> {
  late final GalleryQrDecoder _galleryDecoder = createGalleryDecoder();

  final controller = ms.MobileScannerController(
    formats: const [ms.BarcodeFormat.qrCode],
    detectionSpeed: ms.DetectionSpeed.normal,
    detectionTimeoutMs: 500,
    returnImage: false,
  );

  bool _handled = false;

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

    // Web 也可以用 image_picker_for_web
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final Uint8List bytes = await img.readAsBytes();
    final code = await _galleryDecoder.decode(bytes);

    if (code == null || code.trim().isEmpty) {
      _toast(l.qrFormatInvalid); // 沿用既有字串
      return;
    }

    await _handleCode(code.trim());
  }

  Future<bool> _handleCode(String code) async {
    final l = context.l10n;

    String friendId = code.trim();
    if (friendId.isEmpty) {
      _toast(l.qrFormatInvalid);
      return false;
    }

    // 👇 如果是 JSON 格式就解析
    if (friendId.startsWith('{') && friendId.endsWith('}')) {
      try {
        final decoded = jsonDecode(friendId);
        if (decoded is Map &&
            decoded['type'] == 'friend_qr_v1' &&
            decoded['id'] is String) {
          friendId = (decoded['id'] as String).trim();
        } else {
          _toast(l.qrFormatInvalid);
          return false;
        }
      } catch (_) {
        _toast(l.qrFormatInvalid);
        return false;
      }
    }

    if (friendId.isEmpty) {
      _toast(l.qrFormatInvalid);
      return false;
    }

    try {
      final friendCtrl = context.read<FriendFollowController>();
      await friendCtrl.add(friendId);

      if (!mounted) return true;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added friend: $friendId')));
      Navigator.of(context).pop(friendId);
      return true;
    } catch (e) {
      if (!mounted) return false;
      _toast('${l.previewFailed}: $e');
      return false;
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        try {
          await controller.stop();
        } catch (_) {}
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.scanFriendQrTitle), // 👈 新的 l10n key
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
                if (_handled) return;
                final code = cap.barcodes.isNotEmpty
                    ? cap.barcodes.first.rawValue
                    : null;
                if (code == null) return;

                _handled = true;
                try {
                  await controller.stop();
                } catch (_) {}

                try {
                  await _handleCode(code);
                } finally {
                  _handled = false;
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
                  border: Border.all(color: cs.primary, width: 2),
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
