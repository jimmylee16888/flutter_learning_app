// lib/services/utils/qr/gallery_decoder_mobile.dart
import 'dart:typed_data';
import 'dart:typed_data' show Int32List;
import 'package:image/image.dart' as im;
import 'package:zxing2/qrcode.dart';
// import 'package:zxing2/zxing2.dart';

import 'gallery_decoder_stub.dart';

class MobileGalleryQrDecoder implements GalleryQrDecoder {
  @override
  Future<String?> decode(Uint8List bytes) async {
    final im.Image? img = im.decodeImage(bytes);
    if (img == null) return null;

    // 以 RGBA 取 bytes，手動組成 0xAARRGGBB 給 zxing2
    final rgba = img.getBytes(order: im.ChannelOrder.rgba); // Uint8List
    final pixels = Int32List(img.width * img.height);
    for (int i = 0, j = 0; i < rgba.length; i += 4, j++) {
      final r = rgba[i];
      final g = rgba[i + 1];
      final b = rgba[i + 2];
      final a = rgba[i + 3]; // 0..255
      pixels[j] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    final source = RGBLuminanceSource(img.width, img.height, pixels);
    final bitmap = BinaryBitmap(HybridBinarizer(source));
    final reader = QRCodeReader();
    try {
      final res = reader.decode(bitmap);
      return res.text;
    } catch (_) {
      return null;
    }
  }
}

GalleryQrDecoder createGalleryDecoder() => MobileGalleryQrDecoder();
