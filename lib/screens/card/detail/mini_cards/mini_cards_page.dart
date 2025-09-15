// lib/screens/detail/mini_cards/mini_cards_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning_app/services/utils/qr/qr_codec.dart' as codec;
import 'package:flutter_learning_app/services/utils/qr/qr_image_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' as io;

import '../../../../l10n/l10n.dart'; // ← i18n
import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io.dart';
import '../edit_mini_cards_page.dart';

// ⚠️ 加上前綴，避免與另一個檔案中的同名類別衝突
import 'scan_qr_page.dart' as scan;
import 'qr_preview_dialog.dart' as qr;

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
  static const String _kApiBase = 'https://YOUR_BACKEND_HOST';

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

  static const int _kQrSafeLimit = 500;

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
    final l = context.l10n;

    return WillPopScope(
      onWillPop: _popWithResult,
      child: ScaffoldMessenger(
        key: _messengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l.miniCardsOf(widget.title)),
            leading: BackButton(
              onPressed: () => Navigator.pop(context, _cards),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.upload_file),
                tooltip: l.importFromJsonTooltip,
                onPressed: _importFromJsonDialog,
              ),
              IconButton(
                icon: const Icon(Icons.download),
                tooltip: l.exportJsonMultiTooltip,
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
              // tag filter row
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
                            alignment: const Alignment(0, -0.2),
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
                          alignment: const Alignment(0, -0.2),
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
              final l = ctx.l10n;
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
                    await _rightToolActions(visibleCards);
                    return;
                  }
                  final idx = _currentPageRound() - 1;
                  if (idx >= 0 && idx < visibleCards.length) {
                    await _shareOptionsForCard(context, visibleCards[idx]);
                  }
                },
                icon: Icon(
                  isAtLeftTool ? Icons.qr_code_scanner : Icons.ios_share,
                ),
                label: Text(
                  isAtLeftTool
                      ? l.scan
                      : (isAtRightTool ? l.share : l.shareThisCard),
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

  // ===== scan / share =====
  Future<void> _scanAndImport() async {
    final l = context.l10n;
    final results = await Navigator.push<List<MiniCardData>>(
      context,
      MaterialPageRoute(builder: (_) => const scan.ScanQrPage()),
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
    if (mounted) _snack(l.importedMiniCardsToast(added));
  }

  Future<void> _rightToolActions(List<MiniCardData> visible) async {
    final l = context.l10n;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.collections),
              title: Text(l.shareMultipleCards),
              subtitle: Text(l.shareMultipleCardsSubtitle),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndShareOrExport(visible);
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_1),
              title: Text(l.shareOneCard),
              onTap: () async {
                Navigator.pop(context);
                await _chooseAndShare(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseAndShare(BuildContext context) async {
    final l = context.l10n;
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
                  c.note.isEmpty ? l.common_unnamed : c.note,
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

  Future<List<MiniCardData>?> _pickMultipleCards(
    List<MiniCardData> source, {
    bool jsonOnly = false,
    Set<String>? preselect,
  }) async {
    final l = context.l10n;
    final sel = <String>{...(preselect ?? const <String>{})};

    return showModalBottomSheet<List<MiniCardData>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
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
                          jsonOnly
                              ? l.selectCardsForJsonTitle
                              : l.selectCardsForShareOrExportTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(modalCtx, <MiniCardData>[]),
                        child: Text(l.cancel),
                      ),
                      FilledButton(
                        onPressed: () {
                          final picked = source
                              .where((c) => sel.contains(c.id))
                              .toList();
                          Navigator.pop(modalCtx, picked);
                        },
                        child: Text(l.confirm),
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
                            : null,
                        title: Text(
                          c.note.isNotEmpty ? c.note : l.common_unnamed,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: allowed
                            ? null
                            : Text(l.blockedLocalImageNote),
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

  Future<void> _multiShareOrExportFlow(List<MiniCardData> picked) async {
    final l = context.l10n;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l.shareMultiplePhotos(picked.length)),
              onTap: () async {
                Navigator.pop(context);
                await _shareMultiplePhotos(picked);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: Text(l.exportJson),
              subtitle: Text(l.exportJsonSkipLocalHint),
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

  Future<void> _shareMultiplePhotos(List<MiniCardData> list) async {
    final l = context.l10n;
    int ok = 0, fail = 0;
    for (final c in list) {
      try {
        await sharePhoto(c);
        ok++;
      } catch (_) {
        fail++;
      }
    }
    _snack(l.triedShareSummary(list.length, ok, fail), seconds: 4);
  }

  Future<void> _shareOptionsForCard(BuildContext ctx, MiniCardData c) async {
    final l = ctx.l10n;
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
                title: Text(l.shareQrCode),
                subtitle: Text(l.shareQrAutoBackendHint),
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
                title: Text(l.cannotShareByQr),
                subtitle: Text(l.noImageUrl),
                onTap: () {
                  Navigator.pop(ctx);
                  _snack(l.noImageUrlPhotoOnly);
                },
              ),

            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l.shareThisPhoto),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await sharePhoto(c);
                } catch (e) {
                  if (mounted) _snack(l.shareFailed('$e'));
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.collections),
              title: Text(l.shareMultipleCards),
              subtitle: Text(l.shareMultipleCardsSubtitle),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickAndShareOrExport(
                  _currentVisibleCards(),
                  preselect: {c.id},
                );
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
    final l = context.l10n;

    if ((card.imageUrl ?? '').isEmpty) {
      if (!mounted) return;
      _snack(l.noImageUrlPhotoOnly);
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
      data = card.id;
    }

    final pngBytes = await QrImageBuilder.buildPngBytes(
      data,
      220,
      quietZone: 24,
    );

    if (pngBytes == null) {
      if (!mounted) return;
      _snack(l.qrGenerationFailed);
      return;
    }
    if (!mounted) return;

    final hint = backendMode ? l.transportBackendHint : l.transportEmbeddedHint;

    await qr.QrPreviewDialog.show(
      context,
      pngBytes,
      transportHint: hint,
      jsonText: jsonForDialog,
    );

    if (backendMode) {
      _snack(l.qrIdOnlyNotice, seconds: 4);
    }
  }

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
      throw Exception('response ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body);
    final id = decoded['id'] as String?;
    if (id == null || id.isEmpty) {
      throw Exception('response missing id');
    }
    return id;
  }

  // ===== import / export JSON =====

  Future<void> _importFromJsonDialog() async {
    final l = context.l10n;
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(l.pasteJsonTitle),
        content: TextField(
          controller: controller,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: l.pasteJsonHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, controller.text.trim()),
            child: Text(l.import),
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
      if (mounted) _snack(l.importedFromJsonToast(added));
    } catch (e) {
      if (mounted) _snack(l.importFailed('$e'));
    }
  }

  Future<void> _exportJsonFlow(List<MiniCardData> source) async {
    final l = context.l10n;
    final allowed = source.where(_cardJsonAllowed).toList();
    final skipped = source.length - allowed.length;

    if (allowed.isEmpty) {
      _snack(l.cannotExportJsonAllLocal);
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
        title: Text(l.exportJson),
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
                      l.skippedLocalImagesCount(skipped),
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
            child: Text(l.close),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(l.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: s));
              _snack(l.copiedJsonToast);
            },
          ),
        ],
      ),
    );
  }

  Future<List<MiniCardData>> _parseAnyJson(String text) async {
    final decoded = jsonDecode(text);

    if (decoded is! Map) throw const FormatException('JSON is not an object');

    final type = decoded['type'];
    if (type == 'mini_card_bundle_v2' || type == 'mini_card_bundle_v1') {
      return _parseBundle(decoded);
    }
    if (type == 'mini_card_v2' || type == 'mini_card_v1') {
      final cardMap = Map<String, dynamic>.from(decoded['card'] as Map);
      return [await _inflateOneFromMap(cardMap)];
    }
    throw const FormatException('Unsupported type');
  }

  Future<List<MiniCardData>> _parseBundle(Map data) async {
    final List list = data['cards'] as List? ?? const [];
    final out = <MiniCardData>[];
    for (final e in list) {
      final c = await _inflateOneFromMap(Map<String, dynamic>.from(e as Map));
      out.add(c);
    }
    return out;
  }

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

  bool _cardJsonAllowed(MiniCardData c) {
    final frontOk = (c.imageUrl ?? '').isNotEmpty;
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
      ? context.l10n.common_url
      : ((c.localPath ?? '').isNotEmpty
            ? context.l10n.common_local
            : context.l10n.none);

  String _backSourceLabel(MiniCardData c) {
    if ((c.backImageUrl ?? '').isNotEmpty) return context.l10n.common_url;
    if ((c.backLocalPath ?? '').isNotEmpty) return context.l10n.common_local;
    return context.l10n.none;
  }

  Future<void> _pickAndShareOrExport(
    List<MiniCardData> source, {
    Set<String>? preselect,
  }) async {
    final l = context.l10n;
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
                // title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text(l.selectCardsToShareTitle)),
                      TextButton(
                        onPressed: () => Navigator.pop(modalCtx),
                        child: Text(l.close),
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

                      return CheckboxListTile(
                        value: checked,
                        onChanged: (v) => setModalState(() {
                          if (v == true) {
                            sel.add(c.id);
                          } else {
                            sel.remove(c.id);
                          }
                        }),
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image(
                            image: imageProviderOf(c),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          c.note.isNotEmpty ? c.note : l.common_unnamed,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: _hasLocal(c)
                            ? Text(l.hasImageUrlJsonOk)
                            : null,
                      );
                    },
                  ),
                ),

                const Divider(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.exportJsonOnlyUrlHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.ios_share),
                          label: Text(l.sharePhotos),
                          onPressed: sel.isEmpty
                              ? null
                              : () async {
                                  final picked = source
                                      .where((c) => sel.contains(c.id))
                                      .toList();
                                  Navigator.pop(modalCtx);
                                  await _shareMultiplePhotos(picked);
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.data_object),
                          label: Text(l.exportJson),
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
                                    Navigator.pop(modalCtx);
                                    if (allowed.isEmpty) {
                                      _snack(l.cannotExportJsonAllLocal);
                                    } else {
                                      await _exportJsonFlow(allowed);
                                    }
                                  }

                                  if (blocked > 0) {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(l.containsLocalImages),
                                        content: Text(
                                          l.containsLocalImagesDetail(
                                            blocked,
                                            allowed.length,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l.cancel),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(l.onlyExportUsable),
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
      ((c.localPath?.isNotEmpty ?? false) &&
          (c.imageUrl?.isNotEmpty ?? false)) ||
      ((c.backLocalPath?.isNotEmpty ?? false) &&
          (c.backImageUrl?.isNotEmpty ?? false));
}

void _printJson(String tag, String json) {
  debugPrint('==== $tag JSON ====', wrapWidth: 1024);
  debugPrint(json, wrapWidth: 1024);
  debugPrint('==== end of $tag ====', wrapWidth: 1024);
}
