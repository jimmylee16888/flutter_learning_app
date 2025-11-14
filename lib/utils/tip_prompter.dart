// lib/utils/tip_prompter.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../services/core/base_url.dart';

/// Tip 的資料模型
class TipPrompt {
  final String id;
  final String title;
  final String body;
  final String imageUrl;

  TipPrompt({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
  });

  factory TipPrompt.fromJson(Map<String, dynamic> j) => TipPrompt(
    id: (j['id'] ?? j['tipId'] ?? j['key'] ?? '').toString().trim().isEmpty
        ? _randId()
        : (j['id'] ?? j['tipId'] ?? j['key']).toString(),
    title: (j['title'] ?? '').toString(),
    body: (j['body'] ?? j['subtitle'] ?? '').toString(),
    imageUrl: (j['imageUrl'] ?? j['image'] ?? j['cover'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
  };

  static String _randId() => 'tip_${DateTime.now().microsecondsSinceEpoch}';
}

/// 一天只提示一次的彈窗協助器（支援後端輪播 + 離線預設）
class TipPrompter {
  TipPrompter._();

  /// 設為 true：無論如何都顯示（忽略每日一次 / 已讀）
  static bool alwaysShowOverride = false;
  // static bool alwaysShowOverride = true;

  /// 是否啟用「一天只播一次」邏輯（預設 true）
  static bool enableDailyGate = true;

  /// 內部重入保護
  static bool _isShowing = false;

  /// 進入 App（或首頁）後呼叫即可。
  /// [endpointUrl] 後端 API，回傳「單筆 tip 物件」或「tip 陣列」皆可。
  static Future<void> showIfNeeded(
    BuildContext context, {
    required String endpointUrl,
    Duration httpTimeout = const Duration(seconds: 8),
  }) async {
    if (_isShowing) return;
    _isShowing = true;
    try {
      final tips = await _fetchTips(
        endpointUrl,
        httpTimeout: httpTimeout,
      ).catchError((_) => <TipPrompt>[]);

      final TipPrompt tipToShow = tips.isNotEmpty
          ? _pickTipForToday(tips)
          : _offlineFallback();

      final bypassDailyGate = alwaysShowOverride || !enableDailyGate;

      if (!bypassDailyGate) {
        final seen = await _seenToday(tipToShow.id);
        if (seen) return;
      }

      if (!context.mounted) return;
      await _showDialog(context, tipToShow);

      if (enableDailyGate) {
        await _markSeen(tipToShow.id);
      }
    } finally {
      _isShowing = false;
    }
  }

  /// 強制顯示一次（顯示後若 enableDailyGate=true 仍會標記今日已讀）
  static Future<void> forceShowOnce(
    BuildContext context, {
    required String endpointUrl,
    Duration httpTimeout = const Duration(seconds: 8),
  }) async {
    final tips = await _fetchTips(
      endpointUrl,
      httpTimeout: httpTimeout,
    ).catchError((_) => <TipPrompt>[]);

    final tip = tips.isNotEmpty ? _pickTipForToday(tips) : _offlineFallback();

    if (!context.mounted) return;
    await _showDialog(context, tip);
    if (enableDailyGate) {
      await _markSeen(tip.id);
    }
  }

  static String _dateKeyLocal() {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<bool> _seenToday(String tipId) async {
    final sp = await SharedPreferences.getInstance();
    final key = 'tip_ack.$tipId.${_dateKeyLocal()}';
    return sp.getBool(key) ?? false;
  }

  static Future<void> _markSeen(String tipId) async {
    final sp = await SharedPreferences.getInstance();
    final key = 'tip_ack.$tipId.${_dateKeyLocal()}';
    await sp.setBool(key, true);
  }

  static Future<void> resetTodaySeen({String? tipId}) async {
    final sp = await SharedPreferences.getInstance();
    final today = _dateKeyLocal();
    final keys = sp.getKeys();
    for (final k in keys) {
      if (!k.startsWith('tip_ack.')) continue;
      final parts = k.split('.');
      if (parts.length != 3) continue;
      final id = parts[1];
      final date = parts[2];
      if (date == today && (tipId == null || tipId == id)) {
        await sp.remove(k);
      }
    }
  }

  static Future<void> resetAllSeen() async {
    final sp = await SharedPreferences.getInstance();
    final keys = sp.getKeys().where((k) => k.startsWith('tip_ack.')).toList();
    for (final k in keys) {
      await sp.remove(k);
    }
  }

  /// ============== 後端 ==============
  static Future<List<TipPrompt>> _fetchTips(
    String endpointUrl, {
    Duration httpTimeout = const Duration(seconds: 8),
  }) async {
    if (endpointUrl.trim().isEmpty) return <TipPrompt>[];

    final uri = Uri.parse(endpointUrl);
    final res = await http.get(uri).timeout(httpTimeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('HTTP ${res.statusCode}');
    }

    final decoded = json.decode(res.body);
    if (decoded is List) {
      return decoded
          .whereType<Object>()
          .map((e) => TipPrompt.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      return [TipPrompt.fromJson(decoded)];
    } else {
      if (decoded is String && decoded.trim().isNotEmpty) {
        return [
          TipPrompt(
            id: 'server_text_${DateTime.now().millisecondsSinceEpoch}',
            title: '公告',
            body: decoded,
            imageUrl: '',
          ),
        ];
      }
      return <TipPrompt>[];
    }
  }

  /// 依今天日期做「穩定輪播」：同一天所有用戶同一則
  static TipPrompt _pickTipForToday(List<TipPrompt> pool) {
    if (pool.length == 1) return pool.first;

    final key = _dateKeyLocal();
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = 0x1fffffff & (hash + key.codeUnitAt(i));
      hash = 0x1fffffff & (hash + ((hash & 0x0007ffff) << 10));
      hash ^= (hash >> 6);
    }
    hash = 0x1fffffff & (hash + ((hash & 0x03ffffff) << 3));
    hash ^= (hash >> 11);
    hash = 0x1fffffff & (hash + ((hash & 0x00000fff) << 15));

    final index = hash.abs() % pool.length;
    return pool[index];
  }

  /// ============== 離線 fallback ==============

  static TipPrompt _offlineFallback() => TipPrompt(
    id: 'offline_welcome_popcard',
    title: '歡迎使用PopCard',
    body: '用最直覺的方式收藏、整理、分享你最愛的偶像小卡，打造專屬於你的粉絲空間。',
    imageUrl: 'asset:assets/images/tip_explore2.png', // ← 改這行
  );

  /// ============== UI ==============
  static Future<void> _showDialog(BuildContext context, TipPrompt tip) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SafeArea(
        child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tip.imageUrl.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildTipImage(context, tip.imageUrl),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(
                  tip.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  tip.body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTipImage(BuildContext context, String url) {
    final onError = Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported),
    );

    if (url.startsWith('asset:')) {
      final assetPath = url.substring('asset:'.length);
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => onError,
      );
    }

    if (url.startsWith('data:')) {
      try {
        final comma = url.indexOf(',');
        if (comma > 0) {
          final meta = url.substring(5, comma);
          final base64Part = url.substring(comma + 1);
          if (meta.contains('base64')) {
            final bytes = base64.decode(base64Part);
            return Image.memory(
              Uint8List.fromList(bytes),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => onError,
            );
          }
        }
      } catch (_) {}
      return onError;
    }
    // 👇 這段是關鍵：遇到 /uploads/... 這種相對路徑就補上 baseUrl
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = absUrl(kSocialBaseUrl, url.startsWith('/') ? url : '/$url');
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => onError,
    );
  }
}
