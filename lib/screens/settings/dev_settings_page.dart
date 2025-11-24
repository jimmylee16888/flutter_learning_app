import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_learning_app/services/subscription_service.dart';
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:flutter_learning_app/models/card_item.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

// 控制tip_promoter是否限制一天一次
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_learning_app/utils/tip_prompter.dart';

// 👉 新增：拿 Firebase Token 用
import 'package:flutter_learning_app/services/auth/auth_controller.dart';

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

  // 預覽狀態
  String _previewJson = '';
  String _metaLine = '';
  bool _collapsed = false;

  CardItemStore? _cardStore;
  MiniCardStore? _miniStore;

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

    if (_cardStore != nextCard) {
      _cardStore?._listenersRemove(_rebuildPreview);
      _cardStore = nextCard.._listenersAdd(_rebuildPreview);
    }
    if (_miniStore != nextMini) {
      _miniStore?._listenersRemove(_rebuildPreview);
      _miniStore = nextMini.._listenersAdd(_rebuildPreview);
    }
    _rebuildPreview();
  }

  @override
  void dispose() {
    _cardStore?._listenersRemove(_rebuildPreview);
    _miniStore?._listenersRemove(_rebuildPreview);
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
    final cardsJson = {
      'categories': cardStore.categories,
      'items': cardStore.cardItems.map((e) {
        final j = e.toJson();
        j.remove('localPath');
        return j;
      }).toList(),
    };

    // 2) MiniCard
    final byOwner = <String, List<Map<String, dynamic>>>{};
    for (final owner in miniStore.owners()) {
      byOwner[owner] = miniStore.forOwner(owner).map((m) {
        final j = m.toJson();
        // 可視需要移除本機路徑欄位
        // j.remove('localPath');
        // j.remove('localImagePath');
        return j;
      }).toList();
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

  Future<void> _importAll() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (res == null || res.files.single.bytes == null) return;

      final raw = utf8.decode(res.files.single.bytes!);
      final obj = jsonDecode(raw) as Map<String, dynamic>;

      final cardsJson = (obj['card_item_store'] ?? {}) as Map<String, dynamic>;
      final minisJson = (obj['mini_card_store'] ?? {}) as Map<String, dynamic>;

      // 1) CardItem
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

      context.read<CardItemStore>().replaceAll(
        categories: categories,
        items: items,
      );

      // 2) MiniCard by_owner
      final byOwner =
          (minisJson['by_owner'] as Map<String, dynamic>? ?? const {});
      final miniStore = context.read<MiniCardStore>();

      int total = 0;
      for (final entry in byOwner.entries) {
        final ownerTitle = entry.key;
        final rawList = (entry.value as List? ?? const []);

        final List<MiniCardData> list = [];

        for (final raw in rawList) {
          final m = MiniCardData.fromJson((raw as Map).cast<String, dynamic>());

          MiniCardData cur = (m.idol == null || m.idol!.trim().isEmpty)
              ? m.copyWith(idol: ownerTitle)
              : m;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 匯入完成：CardItem ${items.length}、MiniCard $total'),
        ),
      );

      _rebuildPreview();
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

  Color _muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color _codeBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return cs.surfaceVariant.withOpacity(.55);
  }

  @override
  Widget build(BuildContext context) {
    final eff = SubscriptionService.I.effective.value;

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

          // 預覽（複製 + 匯入）
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
                        tooltip: '匯入 JSON',
                        icon: const Icon(Icons.upload_outlined),
                        onPressed: _importAll,
                      ),
                      IconButton(
                        tooltip: '複製',
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
