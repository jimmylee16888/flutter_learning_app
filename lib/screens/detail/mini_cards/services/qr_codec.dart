// lib/screens/detail/mini_cards/services/qr_codec.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show gzip;

class QrCodec {
  static String encodePackedJson(Map<String, dynamic> obj) {
    final raw = utf8.encode(jsonEncode(obj));
    final gz = gzip.encode(raw);
    return 'gz:' + base64UrlEncode(gz);
    // 若未來要支援純 JSON，可加參數切換
  }

  static Map<String, dynamic>? decodePackedJson(String s) {
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
}
