import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/card_item.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/services/album/album_store.dart';
import 'package:flutter_learning_app/services/auth/auth_controller.dart';
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:flutter_learning_app/services/subscription_service.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';
import 'package:flutter_learning_app/utils/tip_prompter.dart';

class DevSettingsPage extends StatefulWidget {
  const DevSettingsPage({super.key});
  @override
  State<DevSettingsPage> createState() => _DevSettingsPageState();
}

class _DevSettingsPageState extends State<DevSettingsPage> {
  bool _overrideEnabled = false;
  SubscriptionPlan _simPlan = SubscriptionPlan.free;
  bool _simActive = false;

  // 👉 Tip 彈窗相關 Dev 設定
  bool _tipAlwaysShow = false; // 對應 TipPrompter.alwaysShowOverride
  bool _tipDailyGate = true; // 對應 TipPrompter.enableDailyGate

  // 預覽狀態（CardItem + MiniCard）
  String _previewJson = '';
  String _metaLine = '';
  bool _collapsed = false;

  // 專輯預覽狀態（Albums）👈 新增
  String _albumPreviewJson = '';
  String _albumMetaLine = '';
  bool _albumCollapsed = false;

  CardItemStore? _cardStore;
  MiniCardStore? _miniStore;
  AlbumStore? _albumStore; // 👈 新增

  @override
  void initState() {
    super.initState();
    final s = SubscriptionService.I;
    _overrideEnabled = s.devOverrideEnabled;
    final st = s.devOverrideState ?? s.state.value;
    _simPlan = st.plan;
    _simActive = st.isActive;

    // 🔧 載入 TipPrompter 的 Dev 設定（只給開發者用）
    Future.microtask(() async {
      final sp = await SharedPreferences.getInstance();
      setState(() {
        _tipAlwaysShow = sp.getBool('dev_tip_always_show') ?? false;
        _tipDailyGate = sp.getBool('dev_tip_daily_gate') ?? true;
      });

      // 同步到 TipPrompter 的 static
      TipPrompter.alwaysShowOverride = _tipAlwaysShow;
      TipPrompter.enableDailyGate = _tipDailyGate;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextCard = context.read<CardItemStore>();
    final nextMini = context.read<MiniCardStore>();
    final nextAlbum = context.read<AlbumStore>(); // 👈 新增

    if (_cardStore != nextCard) {
      _cardStore?._listenersRemove(_rebuildPreview);
      _cardStore = nextCard.._listenersAdd(_rebuildPreview);
    }
    if (_miniStore != nextMini) {
      _miniStore?._listenersRemove(_rebuildPreview);
      _miniStore = nextMini.._listenersAdd(_rebuildPreview);
    }
    if (_albumStore != nextAlbum) {
      _albumStore?._listenersRemove(_rebuildAlbumPreview);
      _albumStore = nextAlbum.._listenersAdd(_rebuildAlbumPreview);
    }

    _rebuildPreview();
    _rebuildAlbumPreview(); // 👈 新增：專輯同步重算
  }

  @override
  void dispose() {
    _cardStore?._listenersRemove(_rebuildPreview);
    _miniStore?._listenersRemove(_rebuildPreview);
    _albumStore?._listenersRemove(_rebuildAlbumPreview);
    super.dispose();
  }

  // 👉 新增：按鈕用的函式，在 terminal 印出兩種 token
  Future<void> _printTokens() async {
    // 1) Firebase ID Token（給 Social / Firebase 用）
    final auth = context.read<AuthController>();
    final firebaseToken = await auth.debugGetIdToken();

    // 2) 你自家後端的 API Token（這裡假設你有存 SharedPreferences 'api_token'）
    final sp = await SharedPreferences.getInstance();
    final backendToken = sp.getString('api_token');

    debugPrint('================ TOKEN DEBUG ================');
    debugPrint('🔑 Firebase ID Token: ${firebaseToken ?? '(null / 未登入)'}');
    debugPrint(
      '🛠 Backend API Token: ${backendToken ?? '(null / 尚未儲存 api_token)'}',
    );
    debugPrint('=============================================');

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已在 Terminal 印出兩個 Token')));
  }

  Future<void> _apply() async {
    // 1) 套用訂閱模擬
    await SubscriptionService.I.setDevOverride(
      enabled: _overrideEnabled,
      plan: _simPlan,
      isActive: _simActive,
    );

    // 2) 套用 Tip 彈窗 Dev 設定（只影響這台 / 這個使用者）
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('dev_tip_always_show', _tipAlwaysShow);
    await sp.setBool('dev_tip_daily_gate', _tipDailyGate);

    // 寫回 TipPrompter 的 static
    TipPrompter.alwaysShowOverride = _tipAlwaysShow;
    TipPrompter.enableDailyGate = _tipDailyGate;

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已套用開發者設定')));
    setState(() {});
  }

  // ===== 組合目前資料（CardItem + MiniCard）為單一 JSON（跨裝置用）=====
  Map<String, dynamic> _buildPayload() {
    final cardStore = context.read<CardItemStore>();
    final miniStore = context.read<MiniCardStore>();

    // 1) CardItem：匯出時移除本機路徑（localPath）
    //   如果沒有 imageUrl（代表只有 local 圖或完全沒圖），改用預設圖
    const defaultProfileAsset = 'assets/images/default profile picture.png';

    final cardsJson = {
      'categories': cardStore.categories,
      'items': cardStore.cardItems.map((e) {
        final j = e.toJson();

        // 永遠不要匯出 localPath
        j.remove('localPath');

        final rawUrl = (j['imageUrl'] as String?)?.trim() ?? '';

        // 沒有 remote imageUrl → 改成預設圖片
        if (rawUrl.isEmpty) {
          j['imageUrl'] = defaultProfileAsset;
        }

        return j;
      }).toList(),
    };

    // 2) MiniCard：只匯出有「雲端圖」的；只有 localPath 的就跳過
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

        // 👉 只有 local 圖、沒有任何遠端 URL → 不匯出這張
        if (!hasAnyRemote && hasAnyLocal) {
          continue;
        }

        final j = m.toJson();

        // 一律移除本機路徑欄位
        j.remove('localPath');
        j.remove('backLocalPath');

        exportedList.add(j);
      }

      // 如果這個 owner 底下還有卡片才寫入 JSON
      if (exportedList.isNotEmpty) {
        byOwner[owner] = exportedList;
      }
    }

    final minisJson = {
      'by_owner': byOwner,
      'all_count': byOwner.values.fold<int>(0, (a, b) => a + b.length),
    };

    return {
      'format': 'single-json',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'card_item_store': cardsJson,
      'mini_card_store': minisJson,
    };
  }

  void _rebuildPreview() {
    final payload = _buildPayload();
    final pretty = const JsonEncoder.withIndent('  ').convert(payload);
    final bytesLen = utf8.encode(pretty).length;
    final kb = (bytesLen / 1024).toStringAsFixed(1);

    final cardStore = context.read<CardItemStore>();
    final miniStore = context.read<MiniCardStore>();
    final owners = miniStore.owners().length;

    setState(() {
      _previewJson = pretty;
      _metaLine =
          'CardItem: ${cardStore.cardItems.length}、MiniCard: ${miniStore.allCards().length}、Owners: $owners、檔案大小: ${kb}KB';
    });
  }

  // 專輯預覽：組成 List<SimpleAlbum> 的 JSON 👈 新增
  void _rebuildAlbumPreview() {
    final store = context.read<AlbumStore>();
    final albums = store.albums;

    final listJson = albums.map((a) => a.toJson()).toList();
    final pretty = const JsonEncoder.withIndent('  ').convert(listJson);
    final bytesLen = utf8.encode(pretty).length;
    final kb = (bytesLen / 1024).toStringAsFixed(1);

    setState(() {
      _albumPreviewJson = pretty;
      _albumMetaLine = 'Albums: ${albums.length}、檔案大小: ${kb}KB';
    });
  }

  Future<void> _importAll() async {
    try {
      // 先叫出檔案選擇器
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      // 使用者關掉選擇視窗 / 沒選檔案
      if (res == null || res.files.single.bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已取消匯入')));
        return;
      }

      // 把檔案 bytes 轉成 Map<String, dynamic>
      final raw = utf8.decode(res.files.single.bytes!);
      final obj = jsonDecode(raw) as Map<String, dynamic>;

      // 先取出兩大區塊
      final cardsJson = (obj['card_item_store'] ?? {}) as Map<String, dynamic>;
      final minisJson = (obj['mini_card_store'] ?? {}) as Map<String, dynamic>;

      // 開 loading dialog（之後記得關）
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // ===== 1) 匯入 CardItem =====
        final categories = (cardsJson['categories'] as List? ?? const [])
            .map((e) => '$e')
            .toList();

        final rawItems = (cardsJson['items'] as List? ?? const []);
        final List<CardItem> items = [];

        for (final raw in rawItems) {
          final m = (raw as Map).cast<String, dynamic>();
          final c = CardItem.fromJson(m);

          final url = c.imageUrl ?? '';
          CardItem next = c;

          if (url.isNotEmpty) {
            try {
              final lp = await downloadImageToLocal(url, preferName: c.id);
              next = next.copyWith(localPath: lp);
            } catch (e) {
              debugPrint('CardItem image download failed for ${c.id}: $e');
              next = next.copyWith(localPath: null);
            }
          } else {
            next = next.copyWith(localPath: null);
          }

          items.add(next);
        }

        // 覆蓋目前的 CardItemStore
        context.read<CardItemStore>().replaceAll(
          categories: categories,
          items: items,
        );

        // ===== 2) 匯入 MiniCard by_owner =====
        final byOwner =
            (minisJson['by_owner'] as Map<String, dynamic>? ?? const {});
        final miniStore = context.read<MiniCardStore>();

        int total = 0;

        for (final entry in byOwner.entries) {
          final ownerTitle = entry.key;
          final rawList = (entry.value as List? ?? const []);

          final List<MiniCardData> list = [];

          for (final raw in rawList) {
            final m = MiniCardData.fromJson(
              (raw as Map).cast<String, dynamic>(),
            );

            // 如果缺 idol，就補 owner 名字
            MiniCardData cur = (m.idol == null || m.idol!.trim().isEmpty)
                ? m.copyWith(idol: ownerTitle)
                : m;

            // 前面（正面）圖片
            final frontUrl = cur.imageUrl ?? '';
            if (frontUrl.isNotEmpty) {
              try {
                final lp = await downloadImageToLocal(
                  frontUrl,
                  preferName: '${cur.id}_front',
                );
                cur = cur.copyWith(localPath: lp);
              } catch (e) {
                debugPrint('MiniCard front download failed for ${cur.id}: $e');
                cur = cur.copyWith(localPath: null);
              }
            } else {
              cur = cur.copyWith(localPath: null);
            }

            // 背面圖片
            final backUrl = cur.backImageUrl ?? '';
            if (backUrl.isNotEmpty) {
              try {
                final lp = await downloadImageToLocal(
                  backUrl,
                  preferName: '${cur.id}_back',
                );
                cur = cur.copyWith(backLocalPath: lp);
              } catch (e) {
                debugPrint('MiniCard back download failed for ${cur.id}: $e');
                cur = cur.copyWith(backLocalPath: null);
              }
            } else {
              cur = cur.copyWith(backLocalPath: null);
            }

            list.add(cur);
          }

          total += list.length;
          await miniStore.replaceCardsForIdol(idol: ownerTitle, next: list);
        }

        if (!mounted) return;
        // 匯入成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 匯入完成：CardItem ${items.length}、MiniCard $total'),
          ),
        );

        _rebuildPreview();
      } finally {
        // 關掉 loading dialog
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('匯入失敗：$e')));
    }
  }

  Future<void> _copyPreview() async {
    if (_previewJson.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _previewJson));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已複製到剪貼簿')));
  }

  Future<void> _exportToJsonFile() async {
    try {
      // 1) 跟預覽一樣，用目前狀態組 payload
      final payload = _buildPayload();
      final pretty = const JsonEncoder.withIndent('  ').convert(payload);
      final bytes = Uint8List.fromList(utf8.encode(pretty));

      // 2) 建議檔名：帶時間戳方便分辨
      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'mini_cards_export_$ts';

      // 3) 用 FileSaver 存檔（Android / iOS / Web / Desktop 都可以）
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ 已匯出 JSON 檔案')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('匯出失敗：$e')));
    }
  }

  Color _muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color _codeBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return cs.surfaceVariant.withOpacity(.55);
  }

  // === 專輯：文字匯出（Dialog 顯示 JSON，可選可複製） ===
  Future<void> _onExportAlbumJson(BuildContext context) async {
    final store = context.read<AlbumStore>();

    final listJson = store.albums.map((a) => a.toJson()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(listJson);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('匯出專輯 JSON（文字）'),
          content: SizedBox(
            width: 400,
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  // === 專輯：文字貼上匯入（Dialog） ===
  Future<void> _onImportAlbumJson(BuildContext context) async {
    final controller = TextEditingController();

    final jsonStr = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('以文字匯入專輯 JSON'),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              maxLines: 14,
              decoration: const InputDecoration(
                hintText:
                    '貼上專輯 JSON（List<SimpleAlbum>，例如 [ { ... }, { ... } ]）',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('匯入'),
            ),
          ],
        );
      },
    );

    if (jsonStr == null || jsonStr.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(jsonStr);

      if (decoded is! List) {
        throw const FormatException('根層必須是 List，例如 [ { ... }, { ... } ]');
      }

      final albums = decoded
          .map((e) => SimpleAlbum.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);

      final store = context.read<AlbumStore>();
      await store.replaceAll(albums);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已成功匯入 ${albums.length} 張專輯')));
      }

      _rebuildAlbumPreview();
    } catch (e, st) {
      debugPrint('Import album JSON error: $e\n$st');
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('匯入專輯 JSON 失敗：$e')));
    }
  }

  // === 專輯：從 JSON 檔案匯入 ===
  Future<void> _importAlbumFromFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (res == null || res.files.single.bytes == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已取消匯入')));
        return;
      }

      final raw = utf8.decode(res.files.single.bytes!);
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw const FormatException('根層必須是 List，例如 [ { ... }, { ... } ]');
      }

      final albums = decoded
          .map((e) => SimpleAlbum.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);

      final store = context.read<AlbumStore>();
      await store.replaceAll(albums);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已成功匯入 ${albums.length} 張專輯')));

      _rebuildAlbumPreview();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('匯入專輯 JSON 檔失敗：$e')));
    }
  }

  // === 專輯：匯出到 JSON 檔 ===
  Future<void> _exportAlbumToJsonFile() async {
    try {
      final store = context.read<AlbumStore>();
      final listJson = store.albums.map((a) => a.toJson()).toList();
      final pretty = const JsonEncoder.withIndent('  ').convert(listJson);
      final bytes = Uint8List.fromList(utf8.encode(pretty));

      final ts = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'albums_export_$ts';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ 已匯出專輯 JSON 檔案')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('匯出專輯 JSON 檔失敗：$e')));
    }
  }

  // === 專輯：複製預覽 JSON 文字 ===
  Future<void> _copyAlbumPreview() async {
    if (_albumPreviewJson.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _albumPreviewJson));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已複製專輯 JSON 到剪貼簿')));
  }

  @override
  Widget build(BuildContext context) {
    final eff = SubscriptionService.I.effective.value;
    final albumStore = context.watch<AlbumStore>();
    final albumCount = albumStore.albums.length;

    return Scaffold(
      appBar: AppBar(title: const Text('開發者設定'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 目前有效狀態
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('目前 App 讀到的訂閱狀態（effective）'),
              subtitle: Text(
                'plan: ${eff.plan.name} / active: ${eff.isActive}',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 👉 新增：印出兩種 Token 的按鈕
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Token Debug'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _printTokens,
                    icon: const Icon(Icons.key_outlined),
                    label: const Text(
                      '在 Terminal 印出 Firebase + Backend 兩個 Token',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Firebase ID Token 來自 FirebaseAuth.currentUser.getIdToken()\n'
                    '• Backend API Token 預設從 SharedPreferences["api_token"] 讀取',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _muted(context)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 覆寫開關
          Card(
            child: SwitchListTile(
              title: const Text('使用模擬訂閱狀態覆寫（開發者）'),
              subtitle: const Text('開啟後，App 會忽略真實訂閱，使用下方的模擬值'),
              value: _overrideEnabled,
              onChanged: (v) => setState(() => _overrideEnabled = v),
            ),
          ),
          const SizedBox(height: 12),

          // 模擬方案
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('模擬的訂閱方案'),
                  const SizedBox(height: 8),
                  DropdownButton<SubscriptionPlan>(
                    value: _simPlan,
                    items: SubscriptionPlan.values
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _simPlan = v!),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _simActive,
                    onChanged: (v) => setState(() => _simActive = v ?? false),
                    title: const Text('視為有效（isActive=true）'),
                    subtitle: const Text('模擬已付費或權限仍有效'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('儲存並套用'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 💡 Tip 彈窗 Dev 設定
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Tip 每次都顯示（開發者測試用）'),
                  subtitle: const Text('開啟後會忽略「一天一次」與已讀紀錄'),
                  value: _tipAlwaysShow,
                  onChanged: (v) => setState(() => _tipAlwaysShow = v),
                ),
                SwitchListTile(
                  title: const Text('啟用「一天只顯示一次」機制'),
                  subtitle: const Text('一般使用者建議保持開啟'),
                  value: _tipDailyGate,
                  onChanged: (v) => setState(() => _tipDailyGate = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 預覽（CardItem + MiniCard）—— 檔案匯出 / 匯入 / 文字預覽 + 複製
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '資料預覽（CardItem + MiniCard）',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: '匯入 JSON 檔',
                        icon: const Icon(Icons.upload_outlined),
                        onPressed: _importAll,
                      ),
                      IconButton(
                        tooltip: '匯出 JSON 檔',
                        icon: const Icon(Icons.download_outlined),
                        onPressed: _previewJson.isEmpty
                            ? null
                            : _exportToJsonFile,
                      ),
                      IconButton(
                        tooltip: '複製文字 JSON',
                        icon: const Icon(Icons.copy_all_outlined),
                        onPressed: _previewJson.isEmpty ? null : _copyPreview,
                      ),
                      IconButton(
                        tooltip: _collapsed ? '展開' : '摺疊',
                        icon: Icon(
                          _collapsed ? Icons.unfold_more : Icons.unfold_less,
                        ),
                        onPressed: () =>
                            setState(() => _collapsed = !_collapsed),
                      ),
                    ],
                  ),

                  if (_metaLine.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _metaLine,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _muted(context)),
                    ),
                  ],
                  const SizedBox(height: 8),

                  if (!_collapsed)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _codeBg(context),
                      ),
                      child: SizedBox(
                        height: 240,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            _previewJson.isEmpty ? '（目前無資料）' : _previewJson,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              height: 1.45,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    '說明：\n'
                    '• 此預覽為即時組合的單一 JSON：包含所有藝人(CardItem)與小卡(MiniCard)，by_owner 以 title 關聯。\n'
                    '• 匯入為覆蓋式，請先確認內容正確再操作。\n'
                    '• 若日後更改藝人 title，舊檔匯入時 by_owner 對不上將不會合併。\n'
                    '• 匯出內容不包含本機圖片路徑（localPath），在其他裝置匯入後，如需使用本機圖片，請重新指定。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _muted(context),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 專輯資料預覽（Albums）—— 完全同樣風格
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '專輯資料預覽（Albums）',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      // 檔案匯入
                      IconButton(
                        tooltip: '匯入專輯 JSON 檔',
                        icon: const Icon(Icons.upload_outlined),
                        onPressed: _importAlbumFromFile,
                      ),
                      // 檔案匯出
                      IconButton(
                        tooltip: '匯出專輯 JSON 檔',
                        icon: const Icon(Icons.download_outlined),
                        onPressed: _albumPreviewJson.isEmpty
                            ? null
                            : _exportAlbumToJsonFile,
                      ),
                      // 文字貼上匯入
                      IconButton(
                        tooltip: '以文字貼上匯入',
                        icon: const Icon(Icons.edit_note_outlined),
                        onPressed: () => _onImportAlbumJson(context),
                      ),
                      // 文字複製
                      IconButton(
                        tooltip: '複製專輯 JSON',
                        icon: const Icon(Icons.copy_all_outlined),
                        onPressed: _albumPreviewJson.isEmpty
                            ? null
                            : _copyAlbumPreview,
                      ),
                      // 摺疊
                      IconButton(
                        tooltip: _albumCollapsed ? '展開' : '摺疊',
                        icon: Icon(
                          _albumCollapsed
                              ? Icons.unfold_more
                              : Icons.unfold_less,
                        ),
                        onPressed: () =>
                            setState(() => _albumCollapsed = !_albumCollapsed),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    '目前專輯數量：$albumCount',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: _muted(context)),
                  ),
                  if (_albumMetaLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _albumMetaLine,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: _muted(context)),
                    ),
                  ],
                  const SizedBox(height: 8),

                  if (!_albumCollapsed)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _codeBg(context),
                      ),
                      child: SizedBox(
                        height: 240,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            _albumPreviewJson.isEmpty
                                ? '（目前沒有專輯資料）'
                                : _albumPreviewJson,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              height: 1.45,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    '說明：\n'
                    '• JSON 格式為 List<SimpleAlbum>，與 SharedPreferences("albums_json") 儲存格式相同。\n'
                    '• 匯入為覆蓋式，會直接取代目前所有專輯資料，請先備份再操作。\n'
                    '• 單曲圖片（coverLocalPath）僅保留路徑欄位，不會自動下載或搬移檔案。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _muted(context),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 監聽小工具
extension _ListenExt on ChangeNotifier {
  void _listenersAdd(VoidCallback cb) => addListener(cb);
  void _listenersRemove(VoidCallback cb) => removeListener(cb);
}
