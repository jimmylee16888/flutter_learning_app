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
import 'package:shared_preferences/shared_preferences.dart';

class LibrarySyncService {
  static const _kLastSyncAtKey = 'library_last_sync_at';
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
  /// App 啟動 / 使用者手動按「同步」時呼叫
  /// App 啟動時專用：優先採用「後端為主」，除非後端完全沒有 Library
  Future<void> syncOnAppStart() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] app-start: no Firebase token, skip');
      return;
    }

    // STEP 1: 無論本機是否有資料，都先試著從 server 拿 snapshot
    final snapshot = await _fetchSnapshot(token);

    if (snapshot != null) {
      debugPrint(
        '[LibrarySync] app-start: snapshot found, apply server as master',
      );
      await _applyMergedResult(snapshot);
      return; // ✅ 啟動時只拉，不再 POST
    }

    debugPrint(
      '[LibrarySync] app-start: no snapshot on server, fallback to local→server',
    );

    // STEP 2: snapshot 沒東西 → 如果本機有 Library，就把本機當第一版往上傳
    if (!_isLocalLibraryEmpty()) {
      await _postAndApply(token);
    } else {
      debugPrint(
        '[LibrarySync] app-start: local & remote both empty, nothing to do',
      );
    }
  }

  /// 手動 Dev 同步仍用原本的行為
  Future<void> sync() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] no Firebase token, skip');
      return;
    }

    // 保留你原本的邏輯：本機空 → 優先 snapshot；否則 POST / sync merge
    if (_isLocalLibraryEmpty()) {
      debugPrint('[LibrarySync] local library is EMPTY, try snapshot first...');
      final remote = await _fetchSnapshot(token);
      if (remote != null) {
        debugPrint('[LibrarySync] snapshot found, apply as initial library');
        await _applyMergedResult(remote);
        debugPrint(
          '[LibrarySync] initial sync from snapshot finished (no POST)',
        );
        return;
      } else {
        debugPrint(
          '[LibrarySync] no snapshot on server, will upload local as first version',
        );
      }
    } else {
      debugPrint('[LibrarySync] local library is NOT empty, skip snapshot');
    }

    await _postAndApply(token);
  }

  /// 把原本 sync() 裡「POST + 套用」的那段抽成一個 helper
  Future<void> _postAndApply(String token) async {
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

    if (kDebugMode) {
      debugPrint('[LibrarySync] response status = ${resp.statusCode}');
      debugPrint('[LibrarySync] response headers = ${resp.headers}');
      final body = resp.body;
      if (body.isEmpty) {
        debugPrint('[LibrarySync] response body = <empty>');
      } else {
        const maxLen = 2000;
        final short = body.length > maxLen
            ? body.substring(0, maxLen) + ' ...[truncated]'
            : body;
        debugPrint('[LibrarySync] response body = $short');
      }
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      debugPrint('[LibrarySync] sync failed: ${resp.statusCode} ${resp.body}');
      return;
    }

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

  /// 判斷目前本機 library 是否「完全沒有任何使用者資料」
  /// 這裡只看 albums + mini_cards，不把內建 CardItem 當成「有資料」
  bool _isLocalLibraryEmpty() {
    bool hasMinis = false;
    for (final owner in miniStore.owners()) {
      if (miniStore.forOwner(owner).isNotEmpty) {
        hasMinis = true;
        break;
      }
    }

    final hasAlbums = albumStore.allAlbumsRaw.isNotEmpty;

    // 如果之後有「使用者自定義 CardItem」再補判斷
    return !(hasMinis || hasAlbums);
  }

  /// 從 server 拉 snapshot（GET /api/v1/library/snapshot）
  Future<Map<String, dynamic>?> _fetchSnapshot(String token) async {
    final uri = Uri.parse(absUrl(kSocialBaseUrl, '/api/v1/library/snapshot'));

    http.Response resp;
    try {
      resp = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    } catch (e, st) {
      debugPrint('[LibrarySync] snapshot http.get error: $e\n$st');
      return null;
    }

    if (kDebugMode) {
      debugPrint('[LibrarySync] snapshot status = ${resp.statusCode}');
    }

    if (resp.statusCode == 404) {
      // 雲端目前沒有 library 檔案（這個帳號第一次 sync）
      debugPrint('[LibrarySync] no snapshot on server (404)');
      return null;
    }

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      debugPrint(
        '[LibrarySync] snapshot failed: ${resp.statusCode} ${resp.body}',
      );
      return null;
    }

    if (resp.body.trim().isEmpty) {
      debugPrint('[LibrarySync] snapshot body empty, skip');
      return null;
    }

    try {
      final obj = jsonDecode(resp.body) as Map<String, dynamic>;
      return obj;
    } catch (e, st) {
      debugPrint('[LibrarySync] snapshot is not valid JSON: $e\n$st');
      return null;
    }
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

  /// 每天最多 sync 一次：
  /// - 以「本機為主」做 merge（跟你手動按同步那顆一樣邏輯）
  /// - 只有距離上次同步 >= 24 小時才會真的打 API
  Future<void> syncDailyIfNeeded() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] daily: no Firebase token, skip');
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kLastSyncAtKey);
    final now = DateTime.now().toUtc();

    if (raw != null) {
      final last = DateTime.tryParse(raw);
      if (last != null && now.difference(last) < const Duration(hours: 24)) {
        debugPrint('[LibrarySync] daily: last sync < 24h, skip');
        return;
      }
    }

    debugPrint('[LibrarySync] daily: >24h, run sync()');
    await sync(); // 👈 直接用你原本的 sync()（POST + merge）

    await sp.setString(_kLastSyncAtKey, now.toIso8601String());
  }

  /// 給 UI 用：直接從雲端抓 snapshot（不套用到本機）
  /// - 有成功回傳 JSON → Map
  /// - 沒有資料 / 404 / 錯誤 → 回傳 null
  Future<Map<String, dynamic>?> debugFetchSnapshotForUi() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] debugFetchSnapshot: no token');
      return null;
    }
    return _fetchSnapshot(token);
  }

  /// 給「下載並套用」按鈕用：
  /// - 從雲端抓 snapshot
  /// - 若有資料，直接視為 server master，覆蓋本機（仍保留 localPath 類欄位）
  /// - 若雲端沒資料（404 / 空 / 解析錯誤） → 回傳 false，不動本機
  Future<bool> downloadFromServerAndApply() async {
    final token = await auth.debugGetIdToken();
    if (token == null) {
      debugPrint('[LibrarySync] downloadFromServer: no token');
      return false;
    }

    final snap = await _fetchSnapshot(token);
    if (snap == null) {
      debugPrint('[LibrarySync] downloadFromServer: no snapshot');
      return false;
    }

    await _applyMergedResult(snap);
    debugPrint('[LibrarySync] downloadFromServer: applied snapshot');
    return true;
  }
}
