// lib\services\library_sync_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_learning_app/models/card_item.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:flutter_learning_app/services/album/album_store.dart';
import 'package:flutter_learning_app/services/auth/auth_controller.dart';
// LibrarySyncService 用 kApiBaseUrl
import 'package:flutter_learning_app/services/core/base_url.dart';

class LibrarySyncService {
  final CardItemStore cardStore;
  final MiniCardStore miniStore;
  final AlbumStore albumStore;
  final AuthController auth;

  LibrarySyncService({
    required this.cardStore,
    required this.miniStore,
    required this.albumStore,
    required this.auth,
  });

  /// App 啟動 / 使用者手動按「同步」時呼叫
  Future<void> sync() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] no Firebase token, skip');
      return;
    }

    final payload = _buildPayloadForSync();
    debugPrint('[LibrarySync] payload built');

    final uri = Uri.parse(absUrl(kSocialBaseUrl, '/api/v1/library/sync'));

    http.Response resp;
    try {
      resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
    } catch (e, st) {
      debugPrint('[LibrarySync] http.post error: $e\n$st');
      return;
    }

    // 🔍 這裡完整把回傳資訊印出來，方便你在 log 看到
    if (kDebugMode) {
      debugPrint('[LibrarySync] response status = ${resp.statusCode}');
      debugPrint('[LibrarySync] response headers = ${resp.headers}');

      final body = resp.body;
      if (body.isEmpty) {
        debugPrint('[LibrarySync] response body = <empty>');
      } else {
        // 避免太長炸 terminal，截斷一下就好
        const maxLen = 2000;
        final short = body.length > maxLen
            ? body.substring(0, maxLen) + ' ...[truncated]'
            : body;
        debugPrint('[LibrarySync] response body = $short');
      }
    }

    // ❌ 非 2xx 就先不要做 jsonDecode，直接當錯誤看
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      debugPrint('[LibrarySync] sync failed: ${resp.statusCode} ${resp.body}');
      return;
    }

    // 🔸 有些 API 可能 204 No Content 或 body 為空 → 這裡先防呆
    if (resp.body.trim().isEmpty) {
      debugPrint('[LibrarySync] empty body from server, skip apply');
      return;
    }

    Map<String, dynamic> obj;
    try {
      obj = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e, st) {
      debugPrint('[LibrarySync] response is not valid JSON: $e\n$st');
      return;
    }

    await _applyMergedResult(obj);
    debugPrint('[LibrarySync] sync finished');
  }

  /// 🔧 組成送給後端的 payload（以目前本機資料為主）
  Map<String, dynamic> _buildPayloadForSync() {
    // ---------- 1) CardItem ----------
    const defaultProfileAsset = 'assets/images/default profile picture.png';

    final cardsJson = {
      'categories': cardStore.categories,
      'items': cardStore.allCardItemsRaw.map((e) {
        final j = e.toJson();

        // 不把 localPath 傳上去（雲端不需要知道你這台機器的路徑）
        j.remove('localPath');

        final rawUrl = (j['imageUrl'] as String?)?.trim() ?? '';

        if (rawUrl.isEmpty) {
          j['imageUrl'] = defaultProfileAsset;
        }

        return j;
      }).toList(),
    };

    // ---------- 2) MiniCard ----------
    final byOwner = <String, List<Map<String, dynamic>>>{};

    for (final owner in miniStore.owners()) {
      final rawList = miniStore.forOwner(owner);
      final exportedList = <Map<String, dynamic>>[];

      for (final m in rawList) {
        final frontUrl = (m.imageUrl ?? '').trim();
        final backUrl = (m.backImageUrl ?? '').trim();
        final hasAnyRemote = frontUrl.isNotEmpty || backUrl.isNotEmpty;

        final hasLocalFront = (m.localPath ?? '').isNotEmpty;
        final hasLocalBack = (m.backLocalPath ?? '').isNotEmpty;
        final hasAnyLocal = hasLocalFront || hasLocalBack;

        // 只有 local 圖 → 雲端沒有意義，就不傳
        if (!hasAnyRemote && hasAnyLocal) {
          continue;
        }

        final j = m.toJson();
        j.remove('localPath');
        j.remove('backLocalPath');

        exportedList.add(j);
      }

      if (exportedList.isNotEmpty) {
        byOwner[owner] = exportedList;
      }
    }

    final minisJson = {
      'by_owner': byOwner,
      'all_count': byOwner.values.fold<int>(0, (a, b) => a + b.length),
    };

    // ---------- 3) Albums ----------
    final albumsJson = albumStore.allAlbumsRaw
        .map((a) => a.toPortableJson())
        .toList();

    return {
      'format': 'single-json',
      'version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'card_item_store': cardsJson,
      'mini_card_store': minisJson,
      'albums': albumsJson,
    };
  }

  Future<void> _applyMergedResult(Map<String, dynamic> obj) async {
    // ---- CardItem ----
    final cardsJson = (obj['card_item_store'] ?? {}) as Map<String, dynamic>;
    final itemsRaw = (cardsJson['items'] as List? ?? const []);
    final categoriesRaw = (cardsJson['categories'] as List? ?? const []);

    // ---- MiniCard ----
    final minisJson = (obj['mini_card_store'] ?? {}) as Map<String, dynamic>;
    final byOwner =
        (minisJson['by_owner'] as Map<String, dynamic>? ?? const {});

    // ---- Albums ----
    final albumsRaw = (obj['albums'] as List? ?? const []);

    // 🔒 防呆：如果後端回來三組都是空，就視為「雲端目前沒資料」，不要洗掉本機
    final serverIsEmpty =
        itemsRaw.isEmpty && byOwner.isEmpty && albumsRaw.isEmpty;

    if (serverIsEmpty) {
      debugPrint(
        '[LibrarySync] server returned EMPTY library; skip apply to protect local data',
      );
      return;
    }

    // ====== ✅ 下面才是「真的覆蓋本機」的部分 ======

    // ---- CardItem ----
    final categories = categoriesRaw.map((e) => '$e').toList();

    final serverCards = itemsRaw
        .map((e) => CardItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    // 先拿本機舊的
    final localCards = cardStore.allCardItemsRaw;
    final localById = <String, CardItem>{for (final c in localCards) c.id: c};

    final mergedCards = <CardItem>[];

    for (final server in serverCards) {
      final old = localById.remove(server.id);
      if (old != null) {
        final json = server.toJson();
        if ((old.localPath ?? '').isNotEmpty) {
          json['localPath'] = old.localPath;
        }
        mergedCards.add(CardItem.fromJson(json));
      } else {
        mergedCards.add(server);
      }
    }

    // localById 剩下的是只存在本機的 CardItem（如果有的話）
    mergedCards.addAll(localById.values);

    cardStore.replaceAll(categories: categories, items: mergedCards);
    // ✅ 同步完幫沒 localPath 的卡下載一份到本機，之後離線就能顯示
    await _ensureLocalCacheForCards(mergedCards);

    // ---- MiniCard ----
    // ---- MiniCard ----
    for (final entry in byOwner.entries) {
      final owner = entry.key;
      final listRaw = (entry.value as List? ?? const []);

      // 1) 先把 server 結果 parse 出來
      final serverList = listRaw
          .map((e) => MiniCardData.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      // 2) 讀出目前本機的資料
      final localList = miniStore.forOwner(owner);
      final localById = <String, MiniCardData>{
        for (final m in localList) m.id: m,
      };

      final merged = <MiniCardData>[];

      for (final server in serverList) {
        final old = localById.remove(server.id);

        if (old != null) {
          // 用 server 當主體，但把本機的路徑類欄位「蓋回去」
          final json = server.toJson();

          if ((old.localPath ?? '').isNotEmpty) {
            json['localPath'] = old.localPath;
          }
          if ((old.backLocalPath ?? '').isNotEmpty) {
            json['backLocalPath'] = old.backLocalPath;
          }

          merged.add(MiniCardData.fromJson(json));
        } else {
          // 本機沒有這張卡 → 新卡，直接吃 server 的
          merged.add(server);
        }
      }

      // 3) localById 裡剩下的是「只存在本機、沒上傳雲端」的卡
      //    例如只有 local 圖、沒 imageUrl 的，前面 payload 就把它 skip 掉
      //    這些我們要保留，避免被清掉
      merged.addAll(localById.values);

      await miniStore.replaceCardsForIdol(idol: owner, next: merged);
    }

    // ---- Albums ----
    final albums = albumsRaw
        .map((e) => SimpleAlbum.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    await albumStore.replaceAll(albums);
  }

  Future<void> _ensureLocalCacheForCards(List<CardItem> cards) async {
    // Web 版沒「本機檔案」這件事，就直接略過
    if (kIsWeb) return;

    for (final c in cards) {
      // 已經有 localPath 的就不用再抓
      if ((c.localPath ?? '').isNotEmpty) continue;

      final url = c.imageUrl?.trim();
      if (url == null || url.isEmpty) continue;

      try {
        final local = await downloadImageToLocal(url, preferName: c.id);
        if (local == null || local.isEmpty) continue;

        // 這裡假設沒有 copyWith，就自己 new 一個
        final updated = CardItem(
          id: c.id,
          title: c.title,
          imageUrl: c.imageUrl,
          localPath: local,
          quote: c.quote,
          birthday: c.birthday,
          categories: c.categories,
          stageName: c.stageName,
          group: c.group,
          origin: c.origin,
          note: c.note,
        );

        // 用 store 覆蓋回去
        cardStore.upsertCard(updated);
      } catch (e, st) {
        debugPrint('[LibrarySync] cache image failed for ${c.id}: $e\n$st');
      }
    }
  }
}
