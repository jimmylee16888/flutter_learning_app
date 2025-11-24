// lib/screens/album/album_collection_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/services/album/album_store.dart';

import 'album_editor_page.dart';
import 'album_detail_page.dart';

class AlbumCollectionView extends StatelessWidget {
  const AlbumCollectionView({super.key});

  static const double _tileRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return Scaffold(
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
                    // Text(l.albumCollectionTitle, style: text.headlineSmall),
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
                  // Text(l.albumCollectionTitle, style: text.headlineSmall),
                  const SizedBox(height: 16),
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
                        return _AlbumTile(album: a, radius: _tileRadius);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAlbum = await Navigator.of(context).push<SimpleAlbum>(
            MaterialPageRoute(builder: (_) => const AlbumEditorPage()),
          );
          if (newAlbum != null && context.mounted) {
            await context.read<AlbumStore>().add(newAlbum);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 單一專輯卡片，可左右滑動，邏輯/顏色跟 CardsView 一樣
class _AlbumTile extends StatelessWidget {
  const _AlbumTile({required this.album, required this.radius});

  final SimpleAlbum album;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final l = context.l10n;
    final store = context.read<AlbumStore>();

    final BorderRadius outerR = BorderRadius.circular(radius);
    final BorderRadius innerR = BorderRadius.circular(radius + 0.8);

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
                // 下層：編輯 / 刪除背景（和 card_view 同色系）
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
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (d) {
                        setStateSB(() {
                          dx = (dx + d.delta.dx).clamp(-dragLimit, dragLimit);
                        });
                      },
                      onHorizontalDragEnd: (_) => handleEnd(setStateSB),
                      onHorizontalDragCancel: () => handleEnd(setStateSB),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailPage(album: album),
                          ),
                        );
                      },
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: Offset(dx / c.maxWidth, 0),
                        child: ClipRRect(
                          borderRadius: innerR,
                          clipBehavior: Clip.antiAlias,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
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
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    6,
                                    8,
                                    8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

/// 封面圖片（支援 coverUrl / 之後可以接 coverLocalPath）
class _AlbumCoverImage extends StatelessWidget {
  const _AlbumCoverImage({required this.album, required this.cs});

  final SimpleAlbum album;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
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
