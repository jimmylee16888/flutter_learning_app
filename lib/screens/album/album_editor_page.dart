// lib/screens/album/album_editor_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/models/simple_album.dart' show AlbumTrack;
import 'package:flutter_learning_app/services/album/album_store.dart';
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';

// 已有的小卡圖片儲存工具，可以拿來處理本地圖片
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart'
    as mc;

class AlbumEditorPage extends StatefulWidget {
  const AlbumEditorPage({super.key, this.initial});

  final SimpleAlbum? initial;

  @override
  State<AlbumEditorPage> createState() => _AlbumEditorPageState();
}

enum _CoverMode { url, local }

class _AlbumEditorPageState extends State<AlbumEditorPage> {
  final _titleCtrl = TextEditingController();
  final _languageCtrl = TextEditingController();
  final _versionCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  final _coverUrlCtrl = TextEditingController();
  String? _coverLocalPath;
  _CoverMode _coverMode = _CoverMode.url;

  // Link 一行，展開才顯示
  bool _linksExpanded = false;
  final _ytCtrl = TextEditingController();
  final _ytmCtrl = TextEditingController();
  final _spCtrl = TextEditingController();

  // 多作者
  final _artistInputCtrl = TextEditingController();
  final List<String> _artists = [];

  // 歌曲清單
  final List<AlbumTrack> _tracks = [];

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    if (a != null) {
      _titleCtrl.text = a.title;
      _languageCtrl.text = a.language ?? '';
      _versionCtrl.text = a.version ?? '';
      if (a.year != null) _yearCtrl.text = a.year.toString();

      _artists.addAll(a.artists);

      _coverUrlCtrl.text = a.coverUrl ?? '';
      _coverLocalPath = a.coverLocalPath;
      if (_coverLocalPath != null && _coverLocalPath!.isNotEmpty) {
        _coverMode = _CoverMode.local;
      } else {
        _coverMode = _CoverMode.url;
      }

      _ytCtrl.text = a.youtubeUrl ?? '';
      _ytmCtrl.text = a.youtubeMusicUrl ?? '';
      _spCtrl.text = a.spotifyUrl ?? '';
      _linksExpanded =
          _ytCtrl.text.isNotEmpty ||
          _ytmCtrl.text.isNotEmpty ||
          _spCtrl.text.isNotEmpty;

      _tracks.addAll(a.tracks);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _languageCtrl.dispose();
    _versionCtrl.dispose();
    _yearCtrl.dispose();
    _coverUrlCtrl.dispose();
    _ytCtrl.dispose();
    _ytmCtrl.dispose();
    _spCtrl.dispose();
    _artistInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final isEdit = widget.initial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l.albumDialogEditTitle : l.albumDialogAddTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSave,
            tooltip: l.save,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== 封面預覽 + 基本資訊 =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverPreview(cs),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleCtrl,
                        decoration: InputDecoration(
                          labelText: l.albumDialogFieldTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _languageCtrl,
                              decoration: InputDecoration(
                                labelText: l.albumFieldLanguage,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _versionCtrl,
                              decoration: InputDecoration(
                                labelText: l.albumFieldVersion,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _yearCtrl,
                        decoration: InputDecoration(
                          labelText: l.albumDialogFieldYear,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== 封面來源選擇（URL / 本地）=====
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 260,
                child: CupertinoSlidingSegmentedControl<_CoverMode>(
                  groupValue: _coverMode,
                  padding: const EdgeInsets.all(4),
                  children: {
                    _CoverMode.url: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(l.imageByUrl), // 或 l.albumCoverFromUrlLabel
                    ),
                    _CoverMode.local: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        l.imageByLocal,
                      ), // 或 l.albumCoverFromLocalLabel
                    ),
                  },
                  onValueChanged: (v) {
                    setState(() => _coverMode = v ?? _CoverMode.url);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (_coverMode == _CoverMode.url) ...[
              TextField(
                controller: _coverUrlCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldCover,
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}), // 預覽同步更新
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l.pickFromGallery),
                      onPressed: () async {
                        final path = await mc.pickAndCopyToLocal();
                        if (path != null) {
                          setState(() {
                            _coverLocalPath = path;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // ===== 多作者（artists list + 建議）=====
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l.albumFieldArtistsLabel, style: text.titleSmall),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: -4,
              children: [
                for (final a in _artists)
                  InputChip(
                    label: Text(a),
                    onDeleted: () {
                      setState(() => _artists.remove(a));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _artistInputCtrl,
              decoration: InputDecoration(
                labelText: l.albumFieldArtistsInputHint,
                prefixIcon: const Icon(Icons.person_search_outlined),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) {
                final name = v.trim();
                if (name.isEmpty) return;
                if (!_artists.contains(name)) {
                  setState(() {
                    _artists.add(name);
                    _artistInputCtrl.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 4),
            _buildArtistSuggestions(),

            const SizedBox(height: 16),

            // ===== Link 一列 + 展開詳細輸入 =====
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.link_outlined),
              title: Text(l.albumLinksSectionTitle),
              subtitle: Text(
                _linksSummary.isEmpty
                    ? l.albumLinksCollapsedHint
                    : _linksSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: Icon(
                  _linksExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() => _linksExpanded = !_linksExpanded);
                },
              ),
            ),
            if (_linksExpanded) ...[
              const SizedBox(height: 4),
              TextField(
                controller: _ytCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldYoutube,
                  prefixIcon: const Icon(Icons.play_circle_fill),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ytmCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldYtmusic,
                  prefixIcon: const Icon(Icons.music_note),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _spCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldSpotify,
                  prefixIcon: const Icon(Icons.graphic_eq),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ===== 歌曲區塊 =====
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.albumTracksSectionTitle,
                    style: text.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _onAddTrack,
                  icon: const Icon(Icons.add),
                  label: Text(l.albumAddTrackButtonLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_tracks.isEmpty)
              Text(
                l.albumNoTracksHint,
                style: text.bodySmall?.copyWith(color: cs.outline),
              )
            else
              // 🔥 可重排 + 左滑刪除的歌曲列表
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tracks.length,
                buildDefaultDragHandles: false,
                onReorder: _onReorderTrack,
                itemBuilder: (context, index) {
                  final t = _tracks[index];
                  return Dismissible(
                    key: ValueKey(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: cs.error.withOpacity(0.15),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.delete, color: cs.error),
                    ),
                    onDismissed: (_) {
                      setState(() {
                        _tracks.removeWhere((x) => x.id == t.id);
                      });
                    },
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _buildTrackThumbnail(t, cs),
                          title: Text(t.title),
                          subtitle: _TrackPlatformLabels(track: t),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _onEditTrack(index),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                            ],
                          ),
                          onTap: () => _onEditTrack(index),
                        ),
                        const Divider(height: 8),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPreview(ColorScheme cs) {
    Widget content;
    if (_coverMode == _CoverMode.local &&
        _coverLocalPath != null &&
        _coverLocalPath!.isNotEmpty) {
      content = Image(
        image: mc.imageProviderForLocalPath(_coverLocalPath!),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (_coverUrlCtrl.text.isNotEmpty) {
      content = Image.network(
        _coverUrlCtrl.text,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 120,
          height: 120,
          color: cs.surfaceVariant,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    } else {
      content = Container(
        width: 120,
        height: 120,
        color: cs.surfaceVariant,
        child: const Icon(Icons.album, size: 40),
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(16), child: content);
  }

  /// 每首歌縮圖：優先用單曲圖片，其次用專輯封面，再不行顯示 Icon
  Widget _buildTrackThumbnail(AlbumTrack t, ColorScheme cs) {
    ImageProvider? provider;

    // 1️⃣ 單曲本地
    if (t.coverLocalPath != null && t.coverLocalPath!.isNotEmpty) {
      provider = mc.imageProviderForLocalPath(t.coverLocalPath!);

      // 2️⃣ 單曲 URL
    } else if (t.coverUrl != null && t.coverUrl!.isNotEmpty) {
      provider = NetworkImage(t.coverUrl!);

      // 3️⃣ 專輯本地（編輯頁用 _coverLocalPath）
    } else if (_coverMode == _CoverMode.local &&
        _coverLocalPath != null &&
        _coverLocalPath!.isNotEmpty) {
      provider = mc.imageProviderForLocalPath(_coverLocalPath!);

      // 4️⃣ 專輯 URL（編輯頁用 _coverUrlCtrl）
    } else if (_coverMode == _CoverMode.url && _coverUrlCtrl.text.isNotEmpty) {
      provider = NetworkImage(_coverUrlCtrl.text);
    }

    if (provider != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(image: provider, width: 48, height: 48, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note),
    );
  }

  /// 從 CardItem + 既有專輯找出可能的作者名字做建議
  Widget _buildArtistSuggestions() {
    final l = context.l10n;
    final cardStore = context.read<CardItemStore>();
    final albumStore = context.read<AlbumStore>();

    final keyword = _artistInputCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l.albumArtistsSuggestionHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    final candidates = <String>{};

    for (final c in cardStore.cardItems) {
      candidates.add(c.title);
      if ((c.stageName ?? '').isNotEmpty) {
        candidates.add(c.stageName!);
      }
      if ((c.group ?? '').isNotEmpty) {
        candidates.add(c.group!);
      }
    }

    for (final a in albumStore.albums) {
      candidates.addAll(a.artists);
    }

    final matched = candidates
        .where(
          (name) =>
              name.toLowerCase().contains(keyword) && !_artists.contains(name),
        )
        .take(8)
        .toList();

    if (matched.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: -4,
      children: [
        for (final m in matched)
          ActionChip(
            label: Text(m),
            onPressed: () {
              setState(() {
                _artists.add(m);
                _artistInputCtrl.clear();
              });
            },
          ),
      ],
    );
  }

  String get _linksSummary {
    final parts = <String>[];
    if (_ytCtrl.text.trim().isNotEmpty) parts.add('YouTube');
    if (_ytmCtrl.text.trim().isNotEmpty) parts.add('YT Music');
    if (_spCtrl.text.trim().isNotEmpty) parts.add('Spotify');
    return parts.join(' · ');
  }

  Future<void> _onAddTrack() async {
    final l = context.l10n;
    final result = await showDialog<AlbumTrack>(
      context: context,
      builder: (_) => _TrackEditorDialog(title: l.albumTrackDialogAddTitle),
    );
    if (result != null) {
      setState(() => _tracks.add(result));
    }
  }

  Future<void> _onEditTrack(int index) async {
    final l = context.l10n;
    final track = _tracks[index];
    final result = await showDialog<AlbumTrack>(
      context: context,
      builder: (_) => _TrackEditorDialog(
        title: l.albumTrackDialogEditTitle,
        initial: track,
      ),
    );
    if (result != null) {
      setState(() => _tracks[index] = result);
    }
  }

  void _onReorderTrack(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _tracks.removeAt(oldIndex);
      _tracks.insert(newIndex, item);
    });
  }

  Future<void> _onSave() async {
    final l = context.l10n;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.albumTitleRequiredMessage)));
      return;
    }

    final id =
        widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    int? year;
    if (_yearCtrl.text.trim().isNotEmpty) {
      year = int.tryParse(_yearCtrl.text.trim());
    }

    String? coverUrl;
    String? coverLocalPath;
    if (_coverMode == _CoverMode.url) {
      if (_coverUrlCtrl.text.trim().isNotEmpty) {
        coverUrl = _coverUrlCtrl.text.trim();
      }
    } else {
      if (_coverLocalPath == null || _coverLocalPath!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.albumCoverLocalRequiredMessage)),
        );
        return;
      }
      coverLocalPath = _coverLocalPath;
    }

    final album = SimpleAlbum(
      id: id,
      title: title,
      artists: List.unmodifiable(_artists),
      language: _languageCtrl.text.trim().isEmpty
          ? null
          : _languageCtrl.text.trim(),
      version: _versionCtrl.text.trim().isEmpty
          ? null
          : _versionCtrl.text.trim(),
      year: year,
      coverUrl: coverUrl,
      coverLocalPath: coverLocalPath,
      youtubeUrl: _ytCtrl.text.trim().isEmpty ? null : _ytCtrl.text.trim(),
      youtubeMusicUrl: _ytmCtrl.text.trim().isEmpty
          ? null
          : _ytmCtrl.text.trim(),
      spotifyUrl: _spCtrl.text.trim().isEmpty ? null : _spCtrl.text.trim(),
      tracks: List.unmodifiable(_tracks),
    );

    Navigator.of(context).pop(album);
  }
}

/// 歌曲的平台文字（YouTube · YT Music · Spotify）
class _TrackPlatformLabels extends StatelessWidget {
  const _TrackPlatformLabels({required this.track});

  final AlbumTrack track;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final labels = <String>[];
    if (track.youtubeUrl?.isNotEmpty ?? false) labels.add('YouTube');
    if (track.youtubeMusicUrl?.isNotEmpty ?? false) labels.add('YT Music');
    if (track.spotifyUrl?.isNotEmpty ?? false) labels.add('Spotify');

    if (labels.isEmpty) return const SizedBox.shrink();

    return Text(
      labels.join(' · '),
      style: text.bodySmall?.copyWith(color: cs.outline),
    );
  }
}

enum _TrackImageMode { url, local }

/// 新增/編輯歌曲 Dialog（支援自訂圖片）
class _TrackEditorDialog extends StatefulWidget {
  const _TrackEditorDialog({required this.title, this.initial});

  final String title;
  final AlbumTrack? initial;

  @override
  State<_TrackEditorDialog> createState() => _TrackEditorDialogState();
}

class _TrackEditorDialogState extends State<_TrackEditorDialog> {
  final _titleCtrl = TextEditingController();
  final _ytCtrl = TextEditingController();
  final _ytmCtrl = TextEditingController();
  final _spCtrl = TextEditingController();

  String? _coverLocalPath;
  final _coverUrlCtrl = TextEditingController();

  _TrackImageMode _imageMode = _TrackImageMode.url;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _titleCtrl.text = t.title;
      _ytCtrl.text = t.youtubeUrl ?? '';
      _ytmCtrl.text = t.youtubeMusicUrl ?? '';
      _spCtrl.text = t.spotifyUrl ?? '';
      _coverLocalPath = t.coverLocalPath;
      _coverUrlCtrl.text = t.coverUrl ?? '';
    }
    if (_coverLocalPath != null && _coverLocalPath!.isNotEmpty) {
      _imageMode = _TrackImageMode.local;
    } else if (_coverUrlCtrl.text.trim().isNotEmpty) {
      _imageMode = _TrackImageMode.url;
    } else {
      _imageMode = _TrackImageMode.url;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _ytCtrl.dispose();
    _ytmCtrl.dispose();
    _spCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 歌曲標題
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l.albumTrackFieldTitle),
              ),
              const SizedBox(height: 12),

              // 單曲圖片（可選，預設用專輯圖）
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.albumTrackImageLabel, // 例如「歌曲圖片（可選）」
                ),
              ),
              const SizedBox(height: 4),

              // 👇 跟 CardView 類似的 URL / Local 切換
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 260,
                  child: CupertinoSlidingSegmentedControl<_TrackImageMode>(
                    groupValue: _imageMode,
                    padding: const EdgeInsets.all(4),
                    children: {
                      _TrackImageMode.url: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(l.imageByUrl),
                      ),
                      _TrackImageMode.local: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(l.imageByLocal),
                      ),
                    },
                    onValueChanged: (v) {
                      setState(() => _imageMode = v ?? _TrackImageMode.url);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (_imageMode == _TrackImageMode.local) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(l.pickFromGallery),
                        onPressed: () async {
                          final path = await mc.pickAndCopyToLocal();
                          if (path != null) {
                            setState(() {
                              _coverLocalPath = path;
                            });
                          }
                        },
                      ),
                    ),
                    if (_coverLocalPath != null &&
                        _coverLocalPath!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l.albumTrackClearImageTooltip,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _coverLocalPath = null);
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (_coverLocalPath != null && _coverLocalPath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: mc.imageProviderForLocalPath(_coverLocalPath!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.albumTrackImageUseAlbumHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: cs.outline),
                    ),
                  ),
              ] else ...[
                TextField(
                  controller: _coverUrlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Image URL (optional)', // 之後可改 l10n
                    prefixIcon: const Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}), // 讓下面預覽即時刷新
                ),
                const SizedBox(height: 8),
                if (_coverUrlCtrl.text.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _coverUrlCtrl.text.trim(),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: cs.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.albumTrackImageUseAlbumHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: cs.outline),
                    ),
                  ),
              ],

              // 各平台連結
              TextField(
                controller: _ytCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldYoutube,
                  prefixIcon: const Icon(Icons.play_circle_fill),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ytmCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldYtmusic,
                  prefixIcon: const Icon(Icons.music_note),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _spCtrl,
                decoration: InputDecoration(
                  labelText: l.albumDialogFieldSpotify,
                  prefixIcon: const Icon(Icons.graphic_eq),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        FilledButton(onPressed: _onConfirm, child: Text(l.confirm)),
      ],
    );
  }

  void _onConfirm() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final id =
        widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final track = AlbumTrack(
      id: id,
      title: title,
      youtubeUrl: _ytCtrl.text.trim().isNotEmpty ? _ytCtrl.text.trim() : null,
      youtubeMusicUrl: _ytmCtrl.text.trim().isNotEmpty
          ? _ytmCtrl.text.trim()
          : null,
      spotifyUrl: _spCtrl.text.trim().isNotEmpty ? _spCtrl.text.trim() : null,
      coverLocalPath: _coverLocalPath != null && _coverLocalPath!.isNotEmpty
          ? _coverLocalPath
          : null,
      coverUrl: _coverUrlCtrl.text.trim().isNotEmpty
          ? _coverUrlCtrl.text.trim()
          : null, // 👈 新增
    );

    Navigator.pop(context, track);
  }
}
