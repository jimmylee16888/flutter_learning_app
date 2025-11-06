// lib/services/tips/tip_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // ← 用 debugPrint
import 'package:flutter/widgets.dart';

import '../core/base_url.dart';
import '../../utils/tip_prompter.dart' show TipPrompt;

class TipService {
  const TipService();

  String buildDailyUrl({
    required String clientId,
    required String meId,
    required String meNameLocal,
    String? idToken,
    Locale? locale,
    String? appVersion,
    String? platform,
  }) {
    final uri = Uri.parse(absUrl(kSocialBaseUrl, '/tips/daily')).replace(
      queryParameters: <String, String>{
        'clientId': clientId,
        'meId': meId,
        'meName': meNameLocal,
        if (idToken != null && idToken.isNotEmpty) 'idToken': idToken,
        if (locale != null) 'locale': locale.toLanguageTag(),
        if (appVersion?.isNotEmpty == true) 'appVersion': appVersion!,
        if (platform?.isNotEmpty == true) 'platform': platform!,
      },
    );
    return uri.toString();
  }

  Future<List<TipPrompt>> fetchDailyTips({
    required String clientId,
    required String meId,
    required String meNameLocal,
    String? idToken,
    Locale? locale,
    String? appVersion,
    String? platform,
    Duration timeout = const Duration(seconds: 8),
    Map<String, String>? extraHeaders,
  }) async {
    final url = buildDailyUrl(
      clientId: clientId,
      meId: meId,
      meNameLocal: meNameLocal,
      idToken: idToken,
      locale: locale,
      appVersion: appVersion,
      platform: platform,
    );

    debugPrint('[TipService] GET $url');
    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      debugPrint('[TipService] headers=${jsonEncode(extraHeaders)}');
    }

    try {
      final resp = await http.get(Uri.parse(url), headers: extraHeaders).timeout(timeout);
      debugPrint('[TipService] status=${resp.statusCode}');
      debugPrint('[TipService] raw=${resp.body}');

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw StateError('HTTP ${resp.statusCode}');
      }

      final decoded = json.decode(resp.body);
      if (decoded is List) {
        final list = decoded.whereType<Object>().map((e) => TipPrompt.fromJson(e as Map<String, dynamic>)).toList();
        debugPrint('[TipService] parsed tips(list) count=${list.length}');
        return list;
      } else if (decoded is Map<String, dynamic>) {
        final one = TipPrompt.fromJson(decoded);
        debugPrint('[TipService] parsed tip(map) id=${one.id}');
        return [one];
      } else if (decoded is String && decoded.trim().isNotEmpty) {
        final one = TipPrompt(
          id: 'server_text_${DateTime.now().millisecondsSinceEpoch}',
          title: '公告',
          body: decoded,
          imageUrl: '',
        );
        debugPrint('[TipService] parsed tip(string) bodyLen=${decoded.length}');
        return [one];
      }

      debugPrint('[TipService] empty payload → []');
      return <TipPrompt>[];
    } catch (e, st) {
      debugPrint('[TipService] ERROR: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
