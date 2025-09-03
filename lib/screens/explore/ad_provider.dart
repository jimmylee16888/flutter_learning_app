// lib/screens/explore/ad_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
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

  Directory? _docsDir;
  String? _localHtmlPath;
  AdRenderInfo? _cached;

  Future<void> initialize() async {
    _docsDir ??= await getApplicationDocumentsDirectory();

    if (!kUseRemoteAd) {
      // 本地模式：如有提供 kAdHtml，就寫到 <docs>/ad_page.html 供 OpenFilex 開啟
      if (kAdHtml.trim().isNotEmpty) {
        final f = File('${_docsDir!.path}/ad_page.html');
        await f.writeAsString(kAdHtml, encoding: utf8);
        _localHtmlPath = f.path;
      } else {
        _localHtmlPath = null;
      }
      _cached = AdRenderInfo(
        banner: const AssetImage(kAdBannerAsset),
        onTap: () async {
          if (_localHtmlPath != null) {
            await OpenFilex.open(_localHtmlPath!);
          } else {
            final uri = Uri.tryParse(kAdClickUrl);
            if (uri != null)
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
      return;
    }

    // 後端模式：抓設定（這裡先寫好流程，等你把 endpoint 補上即可）
    try {
      if (kRemoteAdEndpoint.isEmpty) throw Exception('No endpoint');
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(kRemoteAdEndpoint));
      final res = await req.close();
      final body = await utf8.decoder.bind(res).join();
      final Map<String, dynamic> j = jsonDecode(body);

      final bannerUrl = (j['bannerUrl'] ?? '') as String;
      final clickUrl = (j['clickUrl'] ?? '') as String;
      final htmlUrl = (j['htmlUrl'] ?? '') as String;

      if (bannerUrl.isEmpty) {
        // 防呆：後端沒給圖就退回 assets
        _cached = AdRenderInfo(
          banner: const AssetImage(kAdBannerAsset),
          onTap: () async {
            if (clickUrl.isNotEmpty) {
              final uri = Uri.tryParse(clickUrl);
              if (uri != null)
                await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        );
      } else {
        _cached = AdRenderInfo(
          banner: NetworkImage(bannerUrl),
          onTap: () async {
            if (htmlUrl.isNotEmpty) {
              final uri = Uri.tryParse(htmlUrl);
              if (uri != null)
                await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else if (clickUrl.isNotEmpty) {
              final uri = Uri.tryParse(clickUrl);
              if (uri != null)
                await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        );
      }
    } catch (_) {
      // 後端掛了也要顯示：fallback 到本地
      _cached = AdRenderInfo(
        banner: const AssetImage(kAdBannerAsset),
        onTap: () async {
          final uri = Uri.tryParse(kAdClickUrl);
          if (uri != null)
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
      );
    }
  }

  AdRenderInfo get renderInfo {
    assert(_cached != null, 'AdProvider.initialize() 尚未呼叫');
    return _cached!;
  }
}
