// lib/screens/album/album_detail_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/simple_album.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart'
    as mc;

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key, required this.album});

  final SimpleAlbum album;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    final artistsLabel = album.artists.isEmpty ? '' : album.artists.join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== 上半部：專輯封面 + 名稱 + 作者 =====
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildCover(cs),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(album.title, style: text.titleLarge),
                      const SizedBox(height: 4),
                      if (artistsLabel.isNotEmpty)
                        Text(
                          artistsLabel,
                          style: text.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (album.year != null ||
                          (album.language ?? '').isNotEmpty ||
                          (album.version ?? '').isNotEmpty)
                        const SizedBox(height: 4),
                      if (album.year != null)
                        Text(
                          l.albumDetailReleaseYear(album.year!.toString()),
                          style: text.bodySmall?.copyWith(color: cs.outline),
                        ),
                      if ((album.language ?? '').isNotEmpty)
                        Text(
                          l.albumDetailLanguage(album.language!),
                          style: text.bodySmall?.copyWith(color: cs.outline),
                        ),
                      if ((album.version ?? '').isNotEmpty)
                        Text(
                          l.albumDetailVersion(album.version!),
                          style: text.bodySmall?.copyWith(color: cs.outline),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildAlbumStreamingButtons(context),

            const SizedBox(height: 24),

            Text(l.albumTracksSectionTitle, style: text.titleMedium),
            const SizedBox(height: 8),
            if (album.tracks.isEmpty)
              Text(
                l.albumNoTracksHint,
                style: text.bodySmall?.copyWith(color: cs.outline),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: album.tracks.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final t = album.tracks[index];
                  return _TrackTile(album: album, track: t, index: index);
                },
              ),

            const SizedBox(height: 24),

            Text(
              l.albumDetailHint,
              style: text.bodySmall?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(ColorScheme cs) {
    if (album.coverLocalPath != null && album.coverLocalPath!.isNotEmpty) {
      return Image(
        image: mc.imageProviderForLocalPath(album.coverLocalPath!),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if ((album.coverUrl ?? '').isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: cs.surfaceVariant,
        child: const Icon(Icons.album, size: 40),
      );
    }

    return Image.network(
      album.coverUrl!,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 120,
        height: 120,
        color: cs.surfaceVariant,
        child: const Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }

  Widget _buildAlbumStreamingButtons(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final buttons = <Widget>[];

    if (album.youtubeUrl?.isNotEmpty ?? false) {
      buttons.add(
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
          ),
          onPressed: () => _open(album.youtubeUrl!),
          icon: const Icon(Icons.play_circle_fill),
          label: const Text('YouTube'),
        ),
      );
    }

    if (album.youtubeMusicUrl?.isNotEmpty ?? false) {
      buttons.add(
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.secondaryContainer,
            foregroundColor: cs.onSecondaryContainer,
          ),
          onPressed: () => _open(album.youtubeMusicUrl!),
          icon: const Icon(Icons.music_note),
          label: const Text('YT Music'),
        ),
      );
    }

    if (album.spotifyUrl?.isNotEmpty ?? false) {
      buttons.add(
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: cs.tertiaryContainer,
            foregroundColor: cs.onTertiaryContainer,
          ),
          onPressed: () => _open(album.spotifyUrl!),
          icon: const Icon(Icons.graphic_eq),
          label: const Text('Spotify'),
        ),
      );
    }

    if (buttons.isEmpty) {
      return Text(
        l.albumDetailNoStreaming,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: cs.outline),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ===== 每一首歌曲 Tile（帶縮圖）=====

class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.album,
    required this.track,
    required this.index,
  });

  final SimpleAlbum album;
  final AlbumTrack track;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final labels = <String>[];
    if (track.youtubeUrl?.isNotEmpty ?? false) labels.add('YouTube');
    if (track.youtubeMusicUrl?.isNotEmpty ?? false) labels.add('YT Music');
    if (track.spotifyUrl?.isNotEmpty ?? false) labels.add('Spotify');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildThumbnail(cs),
      title: Text(track.title, style: text.bodyLarge),
      subtitle: labels.isEmpty
          ? null
          : Text(
              labels.join(' · '),
              style: text.bodySmall?.copyWith(color: cs.outline),
            ),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (track.youtubeUrl?.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(Icons.play_circle_fill),
              tooltip: 'YouTube',
              onPressed: () => _open(track.youtubeUrl!),
            ),
          if (track.youtubeMusicUrl?.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(Icons.music_note),
              tooltip: 'YT Music',
              onPressed: () => _open(track.youtubeMusicUrl!),
            ),
          if (track.spotifyUrl?.isNotEmpty ?? false)
            IconButton(
              icon: const Icon(Icons.graphic_eq),
              tooltip: 'Spotify',
              onPressed: () => _open(track.spotifyUrl!),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme cs) {
    ImageProvider? provider;

    if (track.coverLocalPath != null && track.coverLocalPath!.isNotEmpty) {
      provider = mc.imageProviderForLocalPath(track.coverLocalPath!);
    } else if (album.coverLocalPath != null &&
        album.coverLocalPath!.isNotEmpty) {
      provider = mc.imageProviderForLocalPath(album.coverLocalPath!);
    } else if (album.coverUrl != null && album.coverUrl!.isNotEmpty) {
      provider = NetworkImage(album.coverUrl!);
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

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
