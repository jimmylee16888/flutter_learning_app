// lib/screens/detail/mini_cards/mini_cards_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;

import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io.dart';
import '../edit_mini_cards_page.dart';

import 'scan_qr_page.dart';
import 'qr_preview_dialog.dart';
import '../../../../services/qr_codec.dart' as codec;
import '../../../../services/qr_image_builder.dart';
import 'widgets/flip_big_card.dart';
import 'widgets/mini_card_front.dart';
import 'widgets/mini_card_back.dart';
import 'widgets/tool_card.dart';
import 'package:flutter/services.dart'; // ← 新增

class MiniCardsPage extends StatefulWidget {
  const MiniCardsPage({
    super.key,
    required this.title,
    required this.cards,
    this.initialIndex = 0,
  });
  final String title;
  final List<MiniCardData> cards;
  final int initialIndex;

  @override
  State<MiniCardsPage> createState() => _MiniCardsPageState();
}

class _MiniCardsPageState extends State<MiniCardsPage> {
  // 可選：若要後端模式，上傳/下載卡片的 API base
  static const String _kApiBase = 'https://YOUR_BACKEND_HOST';

  // ---- Toast / Snack ----
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  void _snack(String msg, {SnackBarAction? action, int seconds = 3}) {
    final m = _messengerKey.currentState;
    if (m == null) return;
    m.clearSnackBars();
    m.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: seconds),
        action: action,
      ),
    );
  }

  late List<MiniCardData> _cards = List.of(widget.cards);
  final Set<String> _activeTags = {};

  static const int _kQrSafeLimit = 500; // 直接內嵌 QR 長度上限

  bool _exists(String? p) =>
      p != null && p.isNotEmpty && io.File(p).existsSync();
  bool _canShareQr(MiniCardData c) => (c.imageUrl ?? '').isNotEmpty;

  // —— PageView 狀態 —— //
  int get _pageCount => _cards.length + 2;
  int _computeInitialPage() {
    if (_cards.isEmpty) return 0;
    final want = widget.initialIndex + 1;
    return want.clamp(1, _pageCount - 2);
  }

  late final PageController _pc = PageController(
    initialPage: _computeInitialPage(),
    viewportFraction: 0.78,
  );
  double _page = 1.0;
  int _currentPageRound() => (_pc.hasClients && _pc.page != null)
      ? _pc.page!.round()
      : _pc.initialPage;

  @override
  void initState() {
    super.initState();
    _page = _pc.initialPage.toDouble();
    double last = _page;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pc.addListener(() {
        if (!_pc.hasClients) return;
        final p = _pc.page ?? last;
        if ((p - last).abs() > 0.01) {
          last = p;
          if (mounted) setState(() => _page = p);
        }
      });
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Future<bool> _popWithResult() async {
    Navigator.pop(context, _cards);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    return WillPopScope(
      onWillPop: _popWithResult,
      child: ScaffoldMessenger(
        key: _messengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text('$title 的小卡'),
            leading: BackButton(
              onPressed: () => Navigator.pop(context, _cards),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.upload_file),
                tooltip: '從 JSON 匯入',
                onPressed: _importFromJsonDialog,
              ),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: '匯出 JSON（可多張）',
                onPressed: () async {
                  final visible = _currentVisibleCards();
                  await _exportJsonFlow(visible);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 0),
              // 標籤篩選列
              Builder(
                builder: (_) {
                  final allTags = _cards.expand((c) => c.tags).toSet().toList()
                    ..sort();
                  if (allTags.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allTags
                          .map(
                            (t) => FilterChip(
                              label: Text(t),
                              selected: _activeTags.contains(t),
                              onSelected: (v) => setState(() {
                                v ? _activeTags.add(t) : _activeTags.remove(t);
                                if (_pc.hasClients) _pc.jumpToPage(0);
                              }),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
              // 內容
              Builder(
                builder: (_) {
                  final visibleCards = _currentVisibleCards();
                  final pageCount = visibleCards.length + 2;

                  return Expanded(
                    child: PageView.builder(
                      controller: _pc,
                      itemCount: pageCount,
                      allowImplicitScrolling: true,
                      itemBuilder: (context, i) {
                        final scale = (1 - ((_page - i).abs() * 0.12)).clamp(
                          0.86,
                          1.0,
                        );

                        if (i == 0 || i == pageCount - 1) {
                          return Align(
                            alignment: const Alignment(0, -0.2), // 往上移一點
                            child: AnimatedScale(
                              scale: scale,
                              duration: const Duration(milliseconds: 200),
                              child: ToolCard(
                                onScan: _scanAndImport,
                                onEdit: () async {
                                  final updated =
                                      await Navigator.push<List<MiniCardData>>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditMiniCardsPage(
                                            initial: _cards,
                                          ),
                                        ),
                                      );
                                  if (updated != null && mounted) {
                                    setState(() => _cards = updated);
                                  }
                                },
                              ),
                            ),
                          );
                        }

                        final card = visibleCards[i - 1];
                        return Align(
                          alignment: const Alignment(0, -0.2), // 往上移一點
                          child: AnimatedScale(
                            scale: scale,
                            duration: const Duration(milliseconds: 200),
                            child: SizedBox(
                              width: 320,
                              height: 480,
                              child: FlipBigCard(
                                front: MiniCardFront(card: card),
                                back: MiniCardBack(
                                  card: card,
                                  onChanged: (updated) {
                                    final idx = _cards.indexWhere(
                                      (x) => x.id == updated.id,
                                    );
                                    if (idx >= 0) {
                                      setState(() => _cards[idx] = updated);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (ctx) {
              final visibleCards = _currentVisibleCards();
              final pageCount = visibleCards.length + 2;
              final isAtLeftTool = _currentPageRound() == 0;
              final isAtRightTool = _currentPageRound() == pageCount - 1;

              return FloatingActionButton.extended(
                onPressed: () async {
                  if (isAtLeftTool) {
                    _scanAndImport();
                    return;
                  }
                  if (isAtRightTool) {
                    // 右側工具卡 → 提供「多選」或「單張」動作
                    await _rightToolActions(visibleCards);
                    return;
                  }
                  // 中間卡片 → 單張分享選單
                  final idx = _currentPageRound() - 1;
                  if (idx >= 0 && idx < visibleCards.length) {
                    await _shareOptionsForCard(context, visibleCards[idx]);
                  }
                },
                icon: Icon(
                  isAtLeftTool
                      ? Icons.qr_code_scanner
                      : (isAtRightTool ? Icons.ios_share : Icons.ios_share),
                ),
                label: Text(
                  isAtLeftTool ? '掃描' : (isAtRightTool ? '分享' : '分享此卡'),
                ),
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  List<MiniCardData> _currentVisibleCards() => _activeTags.isEmpty
      ? _cards
      : _cards.where((c) => c.tags.any(_activeTags.contains)).toList();

  // ===== 掃描 / 分享 =====
  Future<void> _scanAndImport() async {
    final results = await Navigator.push<List<MiniCardData>>(
      context,
      MaterialPageRoute(builder: (_) => const ScanQrPage()),
    );
    if (results == null || results.isEmpty) return;

    int added = 0;
    for (final r in results) {
      final exists = _cards.any((c) => c.id == r.id);
      final toInsert = exists
          ? r.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
          : r;
      _cards.add(toInsert);
      added++;
    }
    if (mounted) setState(() {});
    if (mounted) _snack('已匯入 $added 張小卡');
  }

  // 右側工具卡：提供「多選分享/匯出」或「選一張分享」
  Future<void> _rightToolActions(List<MiniCardData> visible) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.collections),
              title: const Text('分享多張卡片（多選）'),
              subtitle: const Text('先勾選卡片，之後選擇「分享照片」或「匯出 JSON」'),
              onTap: () async {
                Navigator.pop(context); // ← 用 context 關閉面板
                await _pickAndShareOrExport(
                  visible, // ← 用傳進來的清單
                  // preselect: {...}                 // （右側工具卡沒有單一卡片可預選，先不預選）
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_1),
              title: const Text('選一張分享…'),
              onTap: () async {
                Navigator.pop(context); // ← 同上
                await _chooseAndShare(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 單張：先挑卡再開單張分享選單
  Future<void> _chooseAndShare(BuildContext context) async {
    if (_cards.isEmpty) return;
    final chosen = await showModalBottomSheet<MiniCardData>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: 420,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = _cards[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: imageProviderOf(c),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  c.note.isEmpty ? '(無敘述)' : c.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pop(context, c),
              );
            },
          ),
        ),
      ),
    );
    if (chosen != null) await _shareOptionsForCard(context, chosen);
  }

  // 多選清單（簡單 checkbox 版）
  Future<List<MiniCardData>?> _pickMultipleCards(
    List<MiniCardData> source, {
    bool jsonOnly = false, // 只允許可轉 JSON 的卡片
    Set<String>? preselect, // 預設勾選
  }) async {
    final sel = <String>{...(preselect ?? const <String>{})};

    return showModalBottomSheet<List<MiniCardData>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        // 🔧 用 StatefulBuilder 包起來，才能在底sheet內 setState
        child: StatefulBuilder(
          builder: (modalCtx, setModalState) => DraggableScrollableSheet(
            expand: false,
            builder: (sheetCtx, ctrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          jsonOnly ? '選擇要分享（JSON）的卡片' : '選擇要分享/匯出的卡片',
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(modalCtx, <MiniCardData>[]),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () {
                          final picked = source
                              .where((c) => sel.contains(c.id))
                              .toList();
                          Navigator.pop(modalCtx, picked);
                        },
                        child: const Text('確定'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    itemCount: source.length,
                    itemBuilder: (ctx, i) {
                      final c = source[i];
                      final checked = sel.contains(c.id);
                      final allowed = !jsonOnly || _cardJsonAllowed(c);

                      return CheckboxListTile(
                        value: checked,
                        onChanged: allowed
                            ? (v) => setModalState(() {
                                if (v == true) {
                                  sel.add(c.id);
                                } else {
                                  sel.remove(c.id);
                                }
                              })
                            : null, // 不允許的直接 disabled
                        title: Text(
                          c.note.isNotEmpty ? c.note : '(無敘述)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: allowed ? null : const Text('含本地照片，無法轉 JSON'),
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            image: imageProviderOf(c),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 多選後：選擇「分享照片」或「匯出 JSON」
  Future<void> _multiShareOrExportFlow(List<MiniCardData> picked) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text('分享多張照片（${picked.length} 張）'),
              onTap: () async {
                Navigator.pop(context);
                await _shareMultiplePhotos(picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('匯出 JSON'),
              subtitle: const Text('本地照片將被略過'),
              onTap: () async {
                Navigator.pop(context);
                await _exportJsonFlow(picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 逐張呼叫原本單張分享（避免額外依賴）
  Future<void> _shareMultiplePhotos(List<MiniCardData> list) async {
    int ok = 0, fail = 0;
    for (final c in list) {
      try {
        await sharePhoto(c);
        ok++;
      } catch (_) {
        fail++;
      }
    }
    _snack('已嘗試分享 ${list.length} 張，成功 $ok / 失敗 $fail', seconds: 4);
  }

  // 分享選項
  Future<void> _shareOptionsForCard(BuildContext ctx, MiniCardData c) async {
    showModalBottomSheet(
      context: ctx,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_canShareQr(c))
              ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('分享 QR code'),
                subtitle: const Text('大檔案會自動切換以後端傳送，掃描端皆可接收'),
                onTap: () async {
                  final pageCtx = this.context;
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 80));
                  _showQrForCard(pageCtx, widget.title, c);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('無法以 QR 分享'),
                subtitle: const Text('此卡沒有圖片網址'),
                onTap: () {
                  Navigator.pop(ctx);
                  _snack('此卡沒有圖片網址，僅能直接分享照片');
                },
              ),

            // 單張照片
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('直接分享此張照片'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await sharePhoto(c);
                } catch (e) {
                  if (mounted) _snack('分享失敗：$e');
                }
              },
            ),

            // ✅ 整合後的「多張卡片」入口：勾選 → 再選分享模式（照片或 JSON）
            ListTile(
              leading: const Icon(Icons.collections),
              title: const Text('分享多張卡片（多選）'),
              subtitle: const Text('直接分享照片 / 匯出 JSON'),
              // ✅ 整合後的一頁式流程
              onTap: () async {
                Navigator.pop(ctx);
                await _pickAndShareOrExport(
                  _currentVisibleCards(),
                  preselect: {c.id}, // 預先勾選目前這張
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // === 依長度決定「直接內嵌」或「後端傳送」 ===
  Future<void> _showQrForCard(
    BuildContext context,
    String owner,
    MiniCardData card,
  ) async {
    if ((card.imageUrl ?? '').isEmpty) {
      if (!mounted) return;
      _snack('這張小卡沒有網址，改用「分享整張照片」喔');
      return;
    }

    final jsonForDialog = jsonEncode({
      'type': 'mini_card_v2',
      'owner': owner,
      'card': _cardToQrJson(card),
    });

    _printJson('Share-Single', jsonForDialog);

    Map<String, dynamic> payload = {
      'type': 'mini_card_v2',
      'owner': owner,
      'card': _cardToQrJson(card),
    };
    String data = codec.QrCodec.encodePackedJson(payload);

    if (data.length > _kQrSafeLimit) {
      payload = {
        'type': 'mini_card_v1',
        'owner': owner,
        'card': _cardToSlimQrJson(card),
      };
      data = codec.QrCodec.encodePackedJson(payload);
    }

    bool backendMode = false;
    if (data.length > _kQrSafeLimit) {
      backendMode = true;
      data = card.id; // 掃描端用 id 呼叫 API 取完整資料
    }

    final pngBytes = await QrImageBuilder.buildPngBytes(
      data,
      220,
      quietZone: 24,
    );

    if (pngBytes == null) {
      if (!mounted) return;
      _snack('生成 QR 影像失敗');
      return;
    }
    if (!mounted) return;

    final hint = backendMode ? '後端模式（走 API）' : '直接內嵌';

    await QrPreviewDialog.show(
      context,
      pngBytes,
      transportHint: hint,
      jsonText: jsonForDialog,
    );

    if (backendMode) {
      _snack('此 QR 僅包含卡片 ID，掃描端會連線後端取得完整內容', seconds: 4);
    }
  }

  /// （如果你真的要上傳給後端）
  Future<String> _uploadCardToBackend(String owner, MiniCardData card) async {
    final uri = Uri.parse('$_kApiBase/api/cards');
    final body = jsonEncode({
      'type': 'mini_card_v2',
      'owner': owner,
      'card': _cardToQrJson(card),
    });
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);
    final id = decoded['id'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('回應缺少 id');
    }
    return id;
  }

  // ---- 匯入 / 匯出 JSON ----

  // 匯入：貼上文字（支援單張/多張）
  Future<void> _importFromJsonDialog() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('貼上 JSON 文字'),
        content: TextField(
          controller: controller,
          maxLines: 12,
          decoration: const InputDecoration(
            hintText: '支援 mini_card_bundle_v2/v1 或 mini_card_v2/v1',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, controller.text.trim()),
            child: const Text('匯入'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;

    try {
      final list = await _parseAnyJson(text);
      int added = 0;
      for (final r in list) {
        final exists = _cards.any((c) => c.id == r.id);
        final toInsert = exists
            ? r.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
            : r;
        _cards.add(toInsert);
        added++;
      }
      if (mounted) setState(() {});
      if (mounted) _snack('已自 JSON 匯入 $added 張小卡');
    } catch (e) {
      if (mounted) _snack('匯入失敗：$e');
    }
  }

  // 匯出：把可轉 JSON 的卡片打包成 bundle，顯示在對話框並可複製
  Future<void> _exportJsonFlow(List<MiniCardData> source) async {
    final allowed = source.where(_cardJsonAllowed).toList();
    final skipped = source.length - allowed.length;

    if (allowed.isEmpty) {
      _snack('選取的卡片都包含本地圖片，無法轉 JSON');
      return;
    }

    final bundle = {
      'type': 'mini_card_bundle_v2',
      'owner': widget.title,
      'count': allowed.length,
      'cards': allowed.map(_cardToQrJson).toList(),
    };

    final s = const JsonEncoder.withIndent('  ').convert(bundle);
    _printJson('Export-Bundle', s);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('匯出 JSON'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (skipped > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '已略過 $skipped 張含本地照片的卡片',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: TextField(
                  controller: TextEditingController(text: s),
                  readOnly: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('複製'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: s));
              _snack('已複製 JSON');
            },
          ),
        ],
      ),
    );
  }

  // 匯入：自動判斷單張或多張
  Future<List<MiniCardData>> _parseAnyJson(String text) async {
    final decoded = jsonDecode(text);

    if (decoded is! Map) throw const FormatException('JSON 不是物件');

    final type = decoded['type'];
    if (type == 'mini_card_bundle_v2' || type == 'mini_card_bundle_v1') {
      return _parseBundle(decoded);
    }
    if (type == 'mini_card_v2' || type == 'mini_card_v1') {
      final cardMap = Map<String, dynamic>.from(decoded['card'] as Map);
      return [await _inflateOneFromMap(cardMap)];
    }
    throw const FormatException('不支援的 type');
  }

  // 多張 bundle 解析
  Future<List<MiniCardData>> _parseBundle(Map data) async {
    final List list = data['cards'] as List? ?? const [];
    final out = <MiniCardData>[];
    for (final e in list) {
      final c = await _inflateOneFromMap(Map<String, dynamic>.from(e as Map));
      out.add(c);
    }
    return out;
  }

  // 單張：下載遠端圖片到本地；若 back 有遠端也會下載
  Future<MiniCardData> _inflateOneFromMap(Map<String, dynamic> map) async {
    var card = MiniCardData.fromJson(map);

    if ((card.imageUrl ?? '').isNotEmpty) {
      try {
        final p = await downloadImageToLocal(
          card.imageUrl!,
          preferName: card.id,
        );
        card = card.copyWith(localPath: p);
      } catch (_) {}
    }
    if ((card.backImageUrl ?? '').isNotEmpty) {
      try {
        final p2 = await downloadImageToLocal(
          card.backImageUrl!,
          preferName: '${card.id}_back',
        );
        card = card.copyWith(backLocalPath: p2);
      } catch (_) {}
    }
    return card;
  }

  // —— JSON 允許判斷：前面必須是遠端網址；背面若有本地也禁止 —— //
  bool _cardJsonAllowed(MiniCardData c) {
    final frontOk = (c.imageUrl ?? '').isNotEmpty; // 前面必須是 URL
    final backLocalOnly =
        (c.backLocalPath ?? '').isNotEmpty && (c.backImageUrl ?? '').isEmpty;
    return frontOk && !backLocalOnly;
  }

  Map<String, dynamic> _cardToQrJson(MiniCardData c) => {
    'id': c.id,
    'imageUrl': c.imageUrl,
    'backImageUrl': c.backImageUrl,
    'note': c.note,
    'name': c.name,
    'serial': c.serial,
    'language': c.language,
    'album': c.album,
    'cardType': c.cardType,
    'tags': c.tags,
    'createdAt': c.createdAt.toIso8601String(),
  };

  Map<String, dynamic> _cardToSlimQrJson(MiniCardData c) => {
    'id': c.id,
    'imageUrl': c.imageUrl,
    'note': c.note,
  };

  bool _isFrontLocalOnly(MiniCardData c) =>
      (c.imageUrl ?? '').isEmpty && (c.localPath ?? '').isNotEmpty;

  String _frontSourceLabel(MiniCardData c) => (c.imageUrl ?? '').isNotEmpty
      ? '網址'
      : ((c.localPath ?? '').isNotEmpty ? '本地' : '無');

  String _backSourceLabel(MiniCardData c) {
    if ((c.backImageUrl ?? '').isNotEmpty) return '網址';
    if ((c.backLocalPath ?? '').isNotEmpty) return '本地';
    return '無';
  }

  Future<void> _pickAndShareOrExport(
    List<MiniCardData> source, {
    Set<String>? preselect,
  }) async {
    final sel = <String>{...(preselect ?? const <String>{})};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: StatefulBuilder(
          builder: (modalCtx, setModalState) => DraggableScrollableSheet(
            expand: false,
            builder: (sheetCtx, ctrl) => Column(
              children: [
                // 標題列
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      const Expanded(child: Text('選擇要分享的卡片')),
                      TextButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        child: const Text('關閉'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 8),

                // 勾選清單
                Expanded(
                  child: ListView.builder(
                    controller: ctrl,
                    itemCount: source.length,
                    itemBuilder: (ctx, i) {
                      final c = source[i];
                      final checked = sel.contains(c.id);

                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) => setModalState(() {
                          if (v == true) {
                            sel.add(c.id);
                          } else {
                            sel.remove(c.id);
                          }
                        }),
                        // 圖片縮圖
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            image: imageProviderOf(c),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // 文字
                        title: Text(
                          c.note.isNotEmpty ? c.note : '(無敘述)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: _hasLocal(c) ? const Text('含本地圖片') : null,
                      );
                    },
                  ),
                ),

                // 提示 + 底部兩個按鈕
                const Divider(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '提示：匯出 JSON 只包含有「圖片網址」的卡片；含本地照片將自動略過。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      // 左：分享照片（無限制）
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.ios_share),
                          label: const Text('分享照片'),
                          onPressed: sel.isEmpty
                              ? null
                              : () async {
                                  final picked = source
                                      .where((c) => sel.contains(c.id))
                                      .toList();
                                  Navigator.pop(modalCtx); // 關底部
                                  await _shareMultiplePhotos(picked);
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 右：匯出 JSON（遇本地先提醒）
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.data_object),
                          label: const Text('匯出 JSON'),
                          onPressed: sel.isEmpty
                              ? null
                              : () async {
                                  final picked = source
                                      .where((c) => sel.contains(c.id))
                                      .toList();
                                  final allowed = picked
                                      .where(_cardJsonAllowed)
                                      .toList();
                                  final blocked =
                                      picked.length - allowed.length;

                                  Future<void> doExport() async {
                                    Navigator.pop(modalCtx); // 關底部
                                    if (allowed.isEmpty) {
                                      _snack('選取的卡片都包含本地圖片，無法轉 JSON');
                                    } else {
                                      await _exportJsonFlow(allowed);
                                    }
                                  }

                                  if (blocked > 0) {
                                    // 有本地圖 → 先詢問
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('包含本地圖片'),
                                        content: Text(
                                          '共有 $blocked 張含本地圖片，無法輸出到 JSON。\n要只輸出其餘可用的 ${allowed.length} 張嗎？',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('取消'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('只輸出可用的'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) await doExport();
                                  } else {
                                    await doExport();
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasLocal(MiniCardData c) =>
      (c.localPath?.isNotEmpty ?? false) ||
      (c.backLocalPath?.isNotEmpty ?? false);
}

void _printJson(String tag, String json) {
  debugPrint('==== $tag JSON ====', wrapWidth: 1024);
  debugPrint(json, wrapWidth: 1024);
  debugPrint('==== end of $tag ====', wrapWidth: 1024);
}
