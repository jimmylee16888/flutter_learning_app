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

class DevSettingsPage extends StatefulWidget {
  const DevSettingsPage({super.key});
  @override
  State<DevSettingsPage> createState() => _DevSettingsPageState();
}

class _DevSettingsPageState extends State<DevSettingsPage> {
  bool _overrideEnabled = false;
  SubscriptionPlan _simPlan = SubscriptionPlan.free;
  bool _simActive = false;

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

  Future<void> _apply() async {
    await SubscriptionService.I.setDevOverride(
      enabled: _overrideEnabled,
      plan: _simPlan,
      isActive: _simActive,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已套用開發者模擬訂閱狀態')));
    setState(() {});
  }

  // ===== 組合目前資料（CardItem + MiniCard）為單一 JSON =====
  Map<String, dynamic> _buildPayload() {
    final cardStore = context.read<CardItemStore>();
    final miniStore = context.read<MiniCardStore>();

    final cardsJson = {
      'categories': cardStore.categories,
      'items': cardStore.cardItems.map((e) => e.toJson()).toList(),
    };

    final byOwner = <String, List<Map<String, dynamic>>>{};
    for (final owner in miniStore.owners()) {
      byOwner[owner] = miniStore
          .forOwner(owner)
          .map((m) => m.toJson())
          .toList();
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
      final items = (cardsJson['items'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map<CardItem>(CardItem.fromJson)
          .toList();

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
        final list = (entry.value as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map<MiniCardData>(MiniCardData.fromJson)
            .map(
              (m) => (m.idol == null || m.idol!.trim().isEmpty)
                  ? m.copyWith(idol: ownerTitle)
                  : m,
            )
            .toList();
        total += list.length;
        await miniStore.replaceCardsForIdol(idol: ownerTitle, next: list);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ 匯入完成：CardItem ${items.length}、MiniCard $total'),
        ),
      );

      _rebuildPreview(); // listener 會更新；這裡保險再觸發一次
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

  // ===== 顏色小工具（跟隨主題）=====
  Color _muted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  Color _codeBg(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // M3 建議：優先用 containerHighest，其次 surfaceVariant
    return (cs.surfaceContainerHighest ?? cs.surfaceVariant).withOpacity(.55);
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
                              // 跟著主題的前景色
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
                    '• 若日後更改藝人 title，舊檔匯入時 by_owner 對不上將不會合併。',
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
