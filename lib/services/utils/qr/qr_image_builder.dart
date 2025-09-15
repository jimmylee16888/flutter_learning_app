// lib/screens/detail/mini_cards/services/qr_image_builder.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrImageBuilder {
  static Future<Uint8List?> buildPngBytes(
    String data,
    double size, {
    double quietZone = 8,
    double scale = 1.0,
  }) async {
    try {
      final double s = (size * scale).clamp(80.0, 4096.0);
      final double q = (quietZone * scale).clamp(0.0, 512.0);

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

      // ✅ 用 s
      final ui.Image qrImage = await painter.toImage(s);

      // ✅ 用 q 與 s
      final double margin = q;
      final double total = s + margin * 2;

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
