// lib/screens/detail/mini_cards/services/qr_codec.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show gzip;

enum QrPayloadKind { json, id }

class QrPayload {
  final QrPayloadKind kind;
  final Map<String, dynamic>? json;
  final String? id;
  const QrPayload._(this.kind, {this.json, this.id});
  factory QrPayload.json(Map<String, dynamic> obj) =>
      QrPayload._(QrPayloadKind.json, json: obj);
  factory QrPayload.id(String id) => QrPayload._(QrPayloadKind.id, id: id);
}

class QrCodec {
  // 仍保留：完整 JSON（gzip+base64url）
  static String encodePackedJson(Map<String, dynamic> obj) {
    final raw = utf8.encode(jsonEncode(obj));
    final gz = gzip.encode(raw);
    return 'gz:' + base64UrlEncode(gz);
  }

  // 仍保留：舊版只回 Map 的解碼（給既有呼叫點）
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

  // 短 ID 編碼
  static String encodeShortId(String id) => 'id:' + id;

  // ✅ 新：通用解碼（同時支援 gz:/id:/純JSON）
  static QrPayload? decode(String code) {
    try {
      if (code.startsWith('gz:')) {
        final gz = base64Url.decode(code.substring(3));
        final raw = gzip.decode(gz);
        final obj = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
        return QrPayload.json(obj);
      }
      if (code.startsWith('id:')) {
        return QrPayload.id(code.substring(3));
      }
      // 兼容：純 JSON
      final obj = jsonDecode(code) as Map<String, dynamic>;
      return QrPayload.json(obj);
    } catch (_) {
      return null;
    }
  }
}
