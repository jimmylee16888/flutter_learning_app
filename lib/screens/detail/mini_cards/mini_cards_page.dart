// lib/screens/detail/mini_cards/mini_cards_page.dart
import 'package:flutter/material.dart';
import '../../../models/mini_card_data.dart';
import '../../../utils/mini_card_io.dart';
import '../edit_mini_cards_page.dart';

import 'scan_qr_page.dart';
import 'qr_preview_dialog.dart';
import 'services/qr_codec.dart';
import 'services/qr_image_builder.dart';
import 'widgets/flip_big_card.dart';
import 'widgets/mini_card_front.dart';
import 'widgets/mini_card_back.dart';
import 'widgets/tool_card.dart';

import 'dart:convert';
import 'package:flutter/services.dart'; // Clipboard

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
  late List<MiniCardData> _cards = List.of(widget.cards);

  bool _isQrEligible(MiniCardData c) => (c.imageUrl ?? '').isNotEmpty;

  // 多小卡
  static const int _kQrSafeLimit = 1800; // 你的穩定上限

  String _buildQrDataForCards(String owner, List<MiniCardData> cards) {
    // 只放必要欄位，縮短長度；且只打包有網址的卡
    final usable = cards.where((c) => (c.imageUrl ?? '').isNotEmpty).toList();
    final payload = {
      'type': usable.length == 1 ? 'mini_card_v1' : 'mini_card_bundle_v1',
      'owner': owner,
      'cards': usable
          .map((c) => {'id': c.id, 'imageUrl': c.imageUrl, 'note': c.note})
          .toList(),
    };
    return QrCodec.encodePackedJson(payload);
  }

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
  bool get _isAtLeftTool => _currentPageRound() == 0;
  bool get _isAtRightTool => _currentPageRound() == _pageCount - 1;

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
      child: Scaffold(
        appBar: AppBar(
          title: Text('$title 的小卡'),
          leading: BackButton(onPressed: () => Navigator.pop(context, _cards)),
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
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _pageCount,
                allowImplicitScrolling: true,
                itemBuilder: (context, i) {
                  final scale = (1 - ((_page - i).abs() * 0.12)).clamp(
                    0.86,
                    1.0,
                  );
                  if (i == 0 || i == _pageCount - 1) {
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
                                    builder: (_) =>
                                        EditMiniCardsPage(initial: _cards),
                                  ),
                                );
                            if (updated != null && mounted)
                              setState(() => _cards = updated);
                          },
                        ),
                      ),
                    );
                  }
                  final card = _cards[i - 1];
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
                            text: card.note,
                            date: card.createdAt,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (_isAtLeftTool) return _scanAndImport();
            if (_isAtRightTool) return _chooseAndShare(context);
            final idx = _currentPageRound() - 1;
            if (idx >= 0 && idx < _cards.length) {
              await _shareOptionsForCard(context, _cards[idx]);
            }
          },
          icon: Icon(
            _isAtLeftTool
                ? Icons.qr_code_scanner
                : _isAtRightTool
                ? Icons.qr_code_2
                : Icons.ios_share,
          ),
          label: Text(
            _isAtLeftTool
                ? '掃描'
                : _isAtRightTool
                ? '分享'
                : '分享此卡',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // ===== 行為：掃描 / 分享 =====
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
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已匯入 $added 張小卡')));
    }
  }

  Future<void> _chooseAndShare(BuildContext context) async {
    if (_cards.isEmpty) return;
    final chosen = await showModalBottomSheet<MiniCardData>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: 360,
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
            if ((c.imageUrl ?? '').isNotEmpty)
              ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('分享「圖片網址」QR code'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showQrForCard(ctx, widget.title, c);
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
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('分享失敗：$e')));
                  }
                }
              },
            ),

            // ✅ 新增：分享多張小卡
            const Divider(height: 12),
            ListTile(
              leading: const Icon(Icons.collections),
              title: const Text('分享多張小卡'),
              subtitle: const Text('可勾選多張；含本地上傳者將於匯出時提醒'),
              onTap: () {
                Navigator.pop(ctx); // 先關閉目前 bottom sheet
                _chooseAndShareMulti(context); // 開啟多選流程
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQrForCard(
    BuildContext context,
    String owner,
    MiniCardData card,
  ) async {
    if ((card.imageUrl ?? '').isEmpty) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('這張小卡沒有網址，改用「分享整張照片」喔')));
      return;
    }

    final payload = {
      'type': 'mini_card_v1',
      'owner': owner,
      'card': {'id': card.id, 'imageUrl': card.imageUrl, 'note': card.note},
    };
    final data = QrCodec.encodePackedJson(payload);

    if (data.length > 1800) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('QR 資料過長（${data.length}）無法生成')));
      }
      return;
    }

    final pngBytes = await QrImageBuilder.buildPngBytes(
      data,
      280,
      quietZone: 24,
    );
    if (pngBytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('生成 QR 影像失敗')));
      }
      return;
    }
    if (!context.mounted) return;
    await QrPreviewDialog.show(context, pngBytes);
  }

  Future<void> _sharePhotos(List<MiniCardData> cards) async {
    for (final c in cards) {
      try {
        await sharePhoto(c);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('分享照片失敗：$e')));
      }
    }
  }

  /// 顯示多張卡片的 QR 輪播（每張卡一個 QR，左右滑動切換）
  void _showQrCarousel(
    BuildContext context,
    String owner,
    List<MiniCardData> cards,
  ) {
    if (cards.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('沒有可用的卡片（需要有圖片網址）')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '分享 QR（${cards.length}）',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 300,
                  height: 340,
                  child: PageView.builder(
                    itemCount: cards.length,
                    itemBuilder: (_, i) {
                      final c = cards[i];
                      final payload = {
                        'type': 'mini_card_v1',
                        'owner': owner,
                        'card': {
                          'id': c.id,
                          'imageUrl': c.imageUrl,
                          'note': c.note,
                        },
                      };
                      final data = QrCodec.encodePackedJson(payload);
                      return FutureBuilder(
                        future: QrImageBuilder.buildPngBytes(data, 320),
                        builder: (ctx, snap) {
                          final bytes = snap.data;
                          return Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: bytes == null
                                      ? const CircularProgressIndicator()
                                      : ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 320,
                                            maxHeight: 320,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Image.memory(
                                              bytes,
                                              filterQuality: FilterQuality.none,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.note.isEmpty ? '(無敘述)' : c.note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final controller = TextEditingController();
                      final text = await showDialog<String>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('用JSON匯入小卡'),
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
                              onPressed: () =>
                                  Navigator.pop(dCtx, controller.text.trim()),
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
                              ? r.copyWith(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                )
                              : r;
                          _cards.add(toInsert);
                          added++;
                        }
                        if (mounted) setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已自 JSON 匯入 $added 張小卡')),
                          );
                        }
                        if (mounted) Navigator.of(context).maybePop();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('匯入失敗：$e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('從 JSON 匯入'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseAndShareMulti(BuildContext context) async {
    if (_cards.isEmpty) return;

    final selected = <String>{};

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setM) {
            final pickedCards = _cards
                .where((c) => selected.contains(c.id))
                .toList();
            final qrEligible = pickedCards.where(_isQrEligible).toList();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '選擇要分享的小卡（可多選）',
                            style: Theme.of(ctx).textTheme.titleMedium,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setM(() {
                              if (selected.length == _cards.length) {
                                selected.clear();
                              } else {
                                selected
                                  ..clear()
                                  ..addAll(_cards.map((e) => e.id));
                              }
                            });
                          },
                          icon: const Icon(Icons.select_all),
                          label: Text(
                            selected.length == _cards.length ? '全不選' : '全選',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: MediaQuery.of(ctx).size.height * 0.5,
                      child: ListView.separated(
                        itemCount: _cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final c = _cards[i];
                          final picked = selected.contains(c.id);
                          final canQr = _isQrEligible(c);
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                image: imageProviderOf(c),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              c.note.isEmpty ? '(無敘述)' : c.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(canQr ? '可產生 JSON' : '無網址（僅能分享照片）'),
                            trailing: Checkbox(
                              value: picked,
                              onChanged: (_) => setM(() {
                                picked
                                    ? selected.remove(c.id)
                                    : selected.add(c.id);
                              }),
                            ),
                            onTap: () => setM(() {
                              picked
                                  ? selected.remove(c.id)
                                  : selected.add(c.id);
                            }),
                          );
                        },
                      ),
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '提示：若要貼上他人分享的多張小卡，可到頁面右上角「從 JSON 匯入」。',
                            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: selected.isEmpty
                                ? null
                                : () async {
                                    final list = _cards
                                        .where((c) => selected.contains(c.id))
                                        .toList();
                                    await _sharePhotos(list);
                                  },
                            icon: const Icon(Icons.ios_share),
                            label: Text('分享照片 (${selected.length})'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: pickedCards.isEmpty
                                ? null
                                : () async {
                                    // 分出可用與本地端
                                    final exportable = pickedCards
                                        .where(_isQrEligible)
                                        .toList(); // 有 imageUrl
                                    final localOnly = pickedCards
                                        .where((c) => !_isQrEligible(c))
                                        .toList(); // 無 imageUrl

                                    if (localOnly.isNotEmpty) {
                                      // 跳提醒：本地端無法產生 JSON
                                      final proceed = await showDialog<bool>(
                                        context: context,
                                        builder: (dCtx) => AlertDialog(
                                          title: const Text('部分選取為本地上傳'),
                                          content: Text(
                                            '共有 ${localOnly.length} 張為本地上傳，無法產生 JSON。\n'
                                            '是否僅導出其餘 ${exportable.length} 張可用的小卡？',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dCtx, false),
                                              child: const Text('返回修改'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(dCtx, true),
                                              child: const Text('只導出可用'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (proceed != true) return; // 返回修改
                                    }

                                    if (exportable.isEmpty) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('沒有可用的小卡可產生 JSON'),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    // 只用可用的卡產生 JSON 並顯示可複製對話框
                                    final json = _buildBundleJson(
                                      widget.title,
                                      exportable,
                                    );
                                    await _showExportJsonDialog(context, json);
                                  },
                            icon: const Icon(Icons.code),
                            label: const Text('匯出 JSON 文字'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _shareSelectedAsQr(
    BuildContext context,
    String owner,
    List<MiniCardData> picked,
  ) async {
    // 只保留可做 QR 的
    final qrs = picked.where((c) => (c.imageUrl ?? '').isNotEmpty).toList();
    if (qrs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('選取的小卡沒有圖片網址，無法以 QR 分享')));
      }
      return;
    }

    // 先嘗試「一張 QR 裝多卡」
    final data = _buildQrDataForCards(owner, qrs);

    if (data.length <= _kQrSafeLimit) {
      final png = await QrImageBuilder.buildPngBytes(data, 320);
      if (png == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('生成 QR 影像失敗')));
        }
        return;
      }
      await QrPreviewDialog.show(context, png);
      return;
    }

    // 超長：提醒 + 建議使用輪播
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('資料太多，無法生成單一 QR'),
        content: Text(
          '已選 ${qrs.length} 張卡，QR 內容長度為 ${data.length}（上限約 $_kQrSafeLimit）。\n'
          '建議改用「多張 QR 輪播」方式讓對方依序掃描。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              _showQrCarousel(context, owner, qrs); // 直接改用輪播
            },
            icon: const Icon(Icons.qr_code_2),
            label: const Text('改用輪播'),
          ),
        ],
      ),
    );
  }

  /// 把多張卡打包成可讀 JSON（只保留必要欄位）
  String _buildBundleJson(String owner, List<MiniCardData> cards) {
    final payload = {
      'type': 'mini_card_bundle_v1',
      'owner': owner,
      'cards': cards
          .map(
            (c) => {
              'id': c.id,
              'imageUrl': c.imageUrl, // 本地卡會是 null
              'note': c.note, // 若太長可自行截斷以縮短文字
              'createdAt': c.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };
    // 若想更短可用 jsonEncode(payload)；這裡排版較好讀
    return jsonEncode(payload);
  }

  /// 顯示「導出 JSON」對話框，讓使用者複製
  Future<void> _showExportJsonDialog(BuildContext ctx, String jsonText) async {
    final controller = TextEditingController(text: jsonText);
    await showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('多張小卡 JSON'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: TextField(
            controller: controller,
            maxLines: null,
            readOnly: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('關閉'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: controller.text));
              if (ctx.mounted) {
                Navigator.pop(dCtx); // ✅ 複製後直接關閉 dialog
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(const SnackBar(content: Text('已複製到剪貼簿')));
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('複製'),
          ),
        ],
      ),
    );
  }

  /// 解析貼上的 JSON 並轉為卡片清單（自動下載有網址的圖片）
  Future<List<MiniCardData>> _parseBundleJson(String text) async {
    final decoded = jsonDecode(text);
    if (decoded is! Map || decoded['type'] != 'mini_card_bundle_v1') {
      throw const FormatException('非 mini_card_bundle_v1');
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
      out.add(card);
    }
    return out;
  }

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已自 JSON 匯入 $added 張小卡')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('匯入失敗：$e')));
      }
    }
  }
}
