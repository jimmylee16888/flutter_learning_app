// lib/screens/detail/mini_cards/mini_cards_page.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ← 新增
import 'dart:convert'; // ← 已有/保留
import 'dart:io' as io;

import '../../../models/mini_card_data.dart';
import '../../../utils/mini_card_io.dart';
import '../edit_mini_cards_page.dart';

import 'scan_qr_page.dart';
import 'qr_preview_dialog.dart';
import 'services/qr_codec.dart' as codec;
import 'services/qr_image_builder.dart';
import 'widgets/flip_big_card.dart';
import 'widgets/mini_card_front.dart';
import 'widgets/mini_card_back.dart';
import 'widgets/tool_card.dart';

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
  // === 設定你的後端位址 ===
  static const String _kApiBase =
      'https://YOUR_BACKEND_HOST'; // e.g. https://api.example.com

  // ---- 統一訊息入口 ----
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

  static const int _kQrSafeLimit = 500; // 直接內嵌 QR 的長度上限（你原本的值）

  bool _exists(String? p) =>
      p != null && p.isNotEmpty && io.File(p).existsSync();
  bool _canShareQr(MiniCardData c) => (c.imageUrl ?? '').isNotEmpty;

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
              // 內容 PageView
              Builder(
                builder: (_) {
                  final visibleCards = _activeTags.isEmpty
                      ? _cards
                      : _cards
                            .where((c) => c.tags.any(_activeTags.contains))
                            .toList();
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
                          return Center(
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
                        return Center(
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
                                    if (idx >= 0)
                                      setState(() => _cards[idx] = updated);
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
              final visibleCards = _activeTags.isEmpty
                  ? _cards
                  : _cards
                        .where((c) => c.tags.any(_activeTags.contains))
                        .toList();
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
                    _chooseAndShare(context);
                    return;
                  }
                  final idx = _currentPageRound() - 1;
                  if (idx >= 0 && idx < visibleCards.length) {
                    await _shareOptionsForCard(context, visibleCards[idx]);
                  }
                },
                icon: Icon(
                  isAtLeftTool
                      ? Icons.qr_code_scanner
                      : (isAtRightTool ? Icons.qr_code_2 : Icons.ios_share),
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

  Future<void> _chooseAndShare(BuildContext context) async {
    if (_cards.isEmpty) return;
    final chosen = await showModalBottomSheet<MiniCardData>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: 40,
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
                subtitle: const Text('大檔案會自動切換以後端傳送，掃描端都可接收'),
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
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('直接分享整張照片'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await sharePhoto(c);
                } catch (e) {
                  if (mounted) _snack('分享失敗：$e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // === 重點：依長度決定「直接內嵌」或「後端傳送」 ===
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

    // 用於 Dialog「JSON 分頁」與列印
    final jsonForDialog = jsonEncode({
      'type': 'mini_card_v2',
      'owner': owner,
      'card': _cardToQrJson(card),
    });

    // ★★★ 在這裡列印到 terminal ★★★
    _printJson('Share-Single', jsonForDialog);

    // 接著照你原本流程：v2→v1→超過上限改走後端...
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

    // 判斷是否要走後端模式（只放 id）
    bool backendMode = false;
    if (data.length > _kQrSafeLimit) {
      backendMode = true;
      data = card.id; // 掃描端用 id 呼叫 API 取完整資料
    }

    // 產生 QR 圖
    final pngBytes = await QrImageBuilder.buildPngBytes(
      data,
      220, // 圖素邊長
      quietZone: 24, // 白邊大一點，掃描更穩
    );

    if (pngBytes == null) {
      if (!mounted) return;
      _snack('生成 QR 影像失敗');
      return;
    }
    if (!mounted) return;

    final hint = backendMode ? '後端模式（走 API）' : '直接內嵌';

    // 打開「QR / JSON」切換的預覽對話框
    await QrPreviewDialog.show(
      context,
      pngBytes,
      transportHint: hint,
      jsonText: jsonForDialog,
    );

    // 走後端模式時，可以順便提示
    if (backendMode) {
      _snack('此 QR 僅包含卡片 ID，掃描端會連線後端取得完整內容', seconds: 4);
    }
  }

  /// 上傳到後端，回傳後端產生的 card id（掃描端會用這個 id 去 GET）
  Future<String> _uploadCardToBackend(String owner, MiniCardData card) async {
    final uri = Uri.parse('$_kApiBase/api/cards'); // 你後端的上傳端點
    // 上傳內容：用 v2 的 json（與掃描端一致，後端儲存後用 GET 回傳）
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

  // ---- 匯入 / 匯出 JSON（保留） ----
  Future<void> _importFromJsonDialog() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('貼上 JSON 文字'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: '貼上 mini_card_bundle_v1 的 JSON 內容…',
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
      final list = await _parseBundleJson(text);
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

  Future<List<MiniCardData>> _parseBundleJson(String text) async {
    final decoded = jsonDecode(text);
    if (decoded is! Map) throw const FormatException('JSON 不是物件');

    final type = decoded['type'];
    if (type != 'mini_card_bundle_v2' && type != 'mini_card_bundle_v1') {
      throw const FormatException('需為 mini_card_bundle_v2 或 v1');
    }

    final List list = decoded['cards'] as List? ?? const [];
    final out = <MiniCardData>[];

    for (final e in list) {
      var card = MiniCardData.fromJson(Map<String, dynamic>.from(e as Map));
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
      out.add(card);
    }
    return out;
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
}

void _printJson(String tag, String json) {
  // debugPrint 會自動分段輸出過長字串，給個 wrapWidth 比較穩
  debugPrint('==== $tag JSON ====', wrapWidth: 1024);
  debugPrint(json, wrapWidth: 1024);
  debugPrint('==== end of $tag ====', wrapWidth: 1024);
}
