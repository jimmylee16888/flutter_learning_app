// lib/screens/explore/ad_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'ad_config.dart';

class AdRenderInfo {
  AdRenderInfo({required this.banner, required this.onTap});
  final ImageProvider banner;
  final Future<void> Function() onTap;
}

class AdProvider {
  AdProvider._();
  static final AdProvider I = AdProvider._();

  AdRenderInfo? _cached;
  AdRenderInfo? get renderInfo => _cached;

  Future<void> initialize({bool forceRefresh = false}) async {
    // 1) 先試遠端
    if (kUseRemoteAd && kRemoteAdEndpoint.isNotEmpty) {
      final info = await _tryFetchRemote(forceRefresh: forceRefresh);
      if (info != null) {
        _cached = info;
        return;
      }
    }
    // 2) fallback：用 ad_config.dart 的 HTTP 圖片與連結
    if (kAdFallbacks.isNotEmpty) {
      final f = kAdFallbacks.first;
      _cached = AdRenderInfo(
        banner: NetworkImage(_bustUrl(f.bannerUrl)),
        onTap: () => _openUrl(f.clickUrl),
      );
      return;
    }
    // 3) 最後的保底，避免完全沒圖
    const fallbackBanner = "asset:assets/images/ad_banner.png";
    _cached = AdRenderInfo(
      banner: NetworkImage(_bustUrl(fallbackBanner)),
      onTap: () async {},
    );
  }

  Future<AdRenderInfo?> _tryFetchRemote({bool forceRefresh = false}) async {
    try {
      final adJsonUri = _bustUri(kRemoteAdEndpoint); // ← 對 ad.json 加上 ?_ts=...
      final res = await http.get(
        adJsonUri,
        headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      );
      if (res.statusCode < 200 || res.statusCode >= 300) return null;

      final Map<String, dynamic> j = jsonDecode(res.body);
      final bannerUrl = (j['bannerUrl'] ?? '').toString().trim();
      final clickUrl = (j['clickUrl'] ?? '').toString().trim();
      if (bannerUrl.isEmpty) return null;

      // 圖片網址也加上時間戳，避免圖片被快取
      final bustedBanner = _bustUrl(bannerUrl);

      return AdRenderInfo(
        banner: NetworkImage(bustedBanner),
        onTap: () => _openUrl(clickUrl),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  // ===== cache-busting helpers =====

  Uri _bustUri(String url) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final u = Uri.parse(url);
    return u.replace(queryParameters: {...u.queryParameters, '_ts': now});
  }

  String _bustUrl(String url) => _bustUri(url).toString();
}
