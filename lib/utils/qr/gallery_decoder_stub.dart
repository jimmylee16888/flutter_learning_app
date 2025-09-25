import 'dart:typed_data';

abstract class GalleryQrDecoder {
  Future<String?> decode(Uint8List bytes);
}

class UnsupportedGalleryQrDecoder implements GalleryQrDecoder {
  @override
  Future<String?> decode(Uint8List bytes) async => null;
}

GalleryQrDecoder createGalleryDecoder() => UnsupportedGalleryQrDecoder();
