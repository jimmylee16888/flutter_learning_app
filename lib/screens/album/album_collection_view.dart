// lib/screens/album/album_collection_view.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/services/album/album_store.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart'
    as mc;

import 'album_editor_page.dart';
import 'album_detail_page.dart';

class AlbumCollectionView extends StatefulWidget {
  const AlbumCollectionView({super.key});

  static const double _tileRadius = 16.0;

  @override
  State<AlbumCollectionView> createState() => _AlbumCollectionViewState();
}

class _AlbumCollectionViewState extends State<AlbumCollectionView> {
  /// 被選取的 album id 集合
  final Set<String> _selectedIds = {};

  bool get _isSelecting => _selectedIds.isNotEmpty;

  void _clearSelection() {
    setState(_selectedIds.clear);
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  // ----------------- 匯入 JSON -----------------

  Future<void> _onImportJson(BuildContext context) async {
    final l = context.l10n;
    final controller = TextEditingController();

    final jsonStr = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.albumImportJsonTitle),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              maxLines: 14,
              decoration: InputDecoration(
                hintText: l.albumImportJsonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(l.import),
            ),
          ],
        );
      },
    );

    if (jsonStr == null || jsonStr.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(jsonStr);

      final store = context.read<AlbumStore>();

      if (decoded is Map<String, dynamic>) {
        // 單一專輯
        final album = SimpleAlbum.fromJson(decoded);
        await store.add(album);
      } else if (decoded is List) {
        // 多張專輯
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final album = SimpleAlbum.fromJson(item);
            await store.add(album);
          }
        }
      } else {
        throw const FormatException('Invalid JSON format');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.albumImportSuccess)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.albumImportFailed('$e'))));
    }
  }

  // ----------------- 匯出 JSON（多選） -----------------

  Future<void> _onExportSelected(BuildContext context) async {
    if (_selectedIds.isEmpty) return;

    final l = context.l10n;
    final store = context.read<AlbumStore>();
    final albums = store.albums
        .where((a) => _selectedIds.contains(a.id))
        .toList(growable: false);

    if (albums.isEmpty) return;

    // 單張 => 直接輸出物件
    // 多張 => 輸出陣列
    final Object jsonData;
    if (albums.length == 1) {
      jsonData = albums.first.toJson();
    } else {
      jsonData = albums.map((a) => a.toJson()).toList(growable: false);
    }

    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonData);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.exportJson),
        content: SizedBox(
          width: 520,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: TextField(
              controller: TextEditingController(text: jsonStr),
              readOnly: true,
              maxLines: null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
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
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.copiedJsonToast)));
            },
          ),
        ],
      ),
    );

    // 匯出完順便清除選取
    _clearSelection();
  }

  // ----------------- 新增按鈕動作：新增專輯 or 匯入 JSON -----------------

  Future<void> _onFabAdd(BuildContext context) async {
    final l = context.l10n;

    final action = await showModalBottomSheet<_AddAlbumAction>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.library_add),
                title: Text(l.albumAddNewAlbum), // 建議在 l10n 裡加這個 key
                onTap: () => Navigator.pop(ctx, _AddAlbumAction.newAlbum),
              ),
              ListTile(
                leading: const Icon(Icons.file_upload_outlined),
                title: Text(l.albumImportJsonTitle),
                onTap: () => Navigator.pop(ctx, _AddAlbumAction.importJson),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case _AddAlbumAction.newAlbum:
        final newAlbum = await Navigator.of(context).push<SimpleAlbum>(
          MaterialPageRoute(builder: (_) => const AlbumEditorPage()),
        );
        if (newAlbum != null && context.mounted) {
          await context.read<AlbumStore>().add(newAlbum);
        }
        break;
      case _AddAlbumAction.importJson:
        await _onImportJson(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return Scaffold(
      // ✅ 不要 AppBar
      body: SafeArea(
        child: Consumer<AlbumStore>(
          builder: (context, store, _) {
            final albums = store.albums;

            if (albums.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Expanded(
                      child: Center(
                        child: Text(
                          l.albumCollectionEmptyHint,
                          style: text.bodyMedium?.copyWith(color: cs.outline),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 選取模式的小工具列（不是 AppBar，只是普通 Row）
                  if (_isSelecting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: l.commonCancel,
                            onPressed: _clearSelection,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedIds.length} selected',
                            style: text.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: albums.length,
                      itemBuilder: (ctx, i) {
                        final a = albums[i];
                        final selected = _selectedIds.contains(a.id);
                        return _AlbumTile(
                          album: a,
                          radius: AlbumCollectionView._tileRadius,
                          selectionMode: _isSelecting,
                          selected: selected,
                          onToggleSelected: () => _toggleSelected(a.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // ✅ FAB：一般模式 = 新增 / 匯入選單；選取模式 = 匯出 JSON
      floatingActionButton: _isSelecting
          ? FloatingActionButton.extended(
              onPressed: () => _onExportSelected(context),
              icon: const Icon(Icons.ios_share_outlined),
              label: Text(l.exportJson),
            )
          : FloatingActionButton(
              onPressed: () => _onFabAdd(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}

enum _AddAlbumAction { newAlbum, importJson }

/// 單一專輯卡片，可左右滑動，邏輯/顏色跟 CardsView 一樣
class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    required this.album,
    required this.radius,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelected,
  });

  final SimpleAlbum album;
  final double radius;

  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final l = context.l10n;
    final store = context.read<AlbumStore>();

    final BorderRadius outerR = BorderRadius.circular(radius);

    const double bgRatio = 0.40;
    const double dragInset = 12.0;
    const double triggerRatio = 0.66;

    final Color errorColor = cs.error;
    final Color primary = cs.primary;

    final artistsLabel = (album.artists.isEmpty)
        ? ''
        : album.artists.join(' · ');

    return Padding(
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (ctx, c) {
          // ===== 計算左右可以滑動的寬度（跟 card_view 同一套）=====
          final double rawAction = c.maxWidth * bgRatio;
          const double minAction = 80.0;
          const double maxAction = 220.0;
          final double halfGuard = (c.maxWidth / 2) - 6;

          double actionW = rawAction.clamp(minAction, maxAction);
          actionW = actionW.clamp(0, halfGuard);
          if (actionW.isNaN || actionW.isInfinite || actionW < 0) {
            actionW = 0;
          }

          final double dragLimit = (actionW - dragInset).clamp(0.0, actionW);
          double dx = 0; // 左負右正

          Future<void> animateBack(StateSetter setStateSB) async {
            setStateSB(() => dx = 0);
          }

          Future<void> handleEnd(StateSetter setStateSB) async {
            // 選擇模式下關閉滑動行為
            if (selectionMode) {
              await animateBack(setStateSB);
              return;
            }

            final double threshold = dragLimit * triggerRatio;
            if (dx >= threshold) {
              // 👉 右滑：編輯
              final edited = await Navigator.of(context).push<SimpleAlbum>(
                MaterialPageRoute(
                  builder: (_) => AlbumEditorPage(initial: album),
                ),
              );
              if (edited != null && context.mounted) {
                await store.update(edited);
              }
              await animateBack(setStateSB);
            } else if (dx <= -threshold) {
              // 👉 左滑：刪除
              final ok =
                  await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l.albumDeleteConfirmTitle),
                      content: Text(l.albumDeleteConfirmMessage(album.title)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l.commonCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l.albumSwipeDelete),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (ok) {
                await store.remove(album.id);
              } else {
                await animateBack(setStateSB);
              }
            } else {
              await animateBack(setStateSB);
            }
          }

          return ClipRRect(
            borderRadius: outerR,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 下層：編輯 / 刪除背景
                Positioned.fill(
                  child: Row(
                    children: [
                      SizedBox(
                        width: actionW,
                        child: Container(
                          color: primary.withOpacity(0.12),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Icon(Icons.edit, color: errorColor, size: 22),
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      SizedBox(
                        width: actionW,
                        child: Container(
                          color: errorColor.withOpacity(0.15),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Icon(
                            Icons.delete,
                            color: errorColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 上層：實際專輯卡片，限制左右滑動距離
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    final borderSide = selected
                        ? BorderSide(color: cs.primary, width: 2)
                        : BorderSide.none;

                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: selectionMode
                          ? null
                          : (d) {
                              setStateSB(() {
                                dx = (dx + d.delta.dx).clamp(
                                  -dragLimit,
                                  dragLimit,
                                );
                              });
                            },
                      onHorizontalDragEnd: selectionMode
                          ? null
                          : (_) => handleEnd(setStateSB),
                      onHorizontalDragCancel: selectionMode
                          ? null
                          : () => handleEnd(setStateSB),
                      onLongPress: onToggleSelected,
                      onTap: () {
                        if (selectionMode) {
                          onToggleSelected();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AlbumDetailPage(album: album),
                            ),
                          );
                        }
                      },
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: Offset(dx / c.maxWidth, 0),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: outerR,
                            side: borderSide, // ✅ 選取外框
                          ),
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _AlbumCoverImage(album: album, cs: cs),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      album.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    if (artistsLabel.isNotEmpty)
                                      Text(
                                        artistsLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodySmall?.copyWith(
                                          color: cs.outline,
                                        ),
                                      ),
                                    if (album.year != null)
                                      Text(
                                        album.year.toString(),
                                        style: text.bodySmall?.copyWith(
                                          color: cs.outline,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 封面圖片（支援 coverUrl / coverLocalPath）
class _AlbumCoverImage extends StatelessWidget {
  const _AlbumCoverImage({required this.album, required this.cs});

  final SimpleAlbum album;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    if (album.coverLocalPath != null && album.coverLocalPath!.isNotEmpty) {
      return Image(
        image: mc.imageProviderForLocalPath(album.coverLocalPath!),
        fit: BoxFit.cover,
      );
    }

    if ((album.coverUrl ?? '').isEmpty) {
      return Container(
        color: cs.surfaceVariant,
        child: const Icon(Icons.album, size: 40),
      );
    }

    return Image.network(
      album.coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: cs.surfaceVariant,
        child: const Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }
}
