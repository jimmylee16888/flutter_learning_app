// lib/screens/detail/mini_cards/services/qr_image_builder.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// lib/screens/detail/mini_cards/services/qr_image_builder.dart
class QrImageBuilder {
  static Future<Uint8List?> buildPngBytes(
    String data,
    double size, {
    double quietZone = 24, // 想要更小白邊就再調低，例如 20
  }) async {
    try {
      final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        gapless: false,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      );

      final ui.Image qrImage = await painter.toImage(size);

      // ✅ 用參數，不要寫死 28
      final double margin = quietZone;
      final double total = size + margin * 2;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paintWhite = Paint()..color = Colors.white;

      canvas.drawRect(Rect.fromLTWH(0, 0, total, total), paintWhite);
      canvas.drawImage(qrImage, Offset(margin, margin), Paint());

      final picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(
        total.toInt(),
        total.toInt(),
      );
      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ QrImageBuilder.buildPngBytes failed: $e');
      return null;
    }
  }
}
