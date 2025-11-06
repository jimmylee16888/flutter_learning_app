import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/l10n.dart';
import '../../../../../models/mini_card_data.dart';
import '../../../../../utils/mini_card_io/mini_card_io.dart';
import '../../../../../utils/no_cors_image/no_cors_image.dart';
import '../../edit_mini_cards_page.dart';

class MiniCardBack extends StatefulWidget {
  const MiniCardBack({super.key, required this.card, required this.onChanged});

  final MiniCardData card;
  final ValueChanged<MiniCardData> onChanged;

  @override
  State<MiniCardBack> createState() => _MiniCardBackState();
}

class _MiniCardBackState extends State<MiniCardBack> {
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = widget.card;

    final hasBackUrl = (c.backImageUrl ?? '').isNotEmpty;
    final hasBackLocal =
        (c.backLocalPath ?? '').isNotEmpty && !(kIsWeb && (c.backLocalPath?.startsWith('url:') ?? false));
    final hasBackImage = hasBackUrl || hasBackLocal;
    final canClearBack = hasBackImage;

    final d =
        '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')} '
        '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}';

    // 決定背面要顯示的圖片 widget（Web + URL → NoCorsImage）
    final Widget? backImage = hasBackImage
        ? (kIsWeb && !hasBackLocal && hasBackUrl)
              ? NoCorsImage(c.backImageUrl!, fit: BoxFit.cover, borderRadius: _radius)
              : Image(
                  image: hasBackLocal ? imageProviderForLocalPath(c.backLocalPath!) : NetworkImage(c.backImageUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey)),
                )
        : null;

    return Card(
      color: hasBackImage ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (backImage != null) Positioned.fill(child: backImage),

          if (hasBackImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                  ),
                ),
              ),
            ),

          // 右上角動作：清除背面圖 / 編輯資訊
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canClearBack) ...[
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: hasBackImage ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.06),
                      foregroundColor: hasBackImage ? Colors.white : Colors.black87,
                    ),
                    tooltip: l.clearBackImage,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmAndClearBackImage,
                  ),
                  const SizedBox(width: 6),
                ],
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: hasBackImage ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.06),
                    foregroundColor: hasBackImage ? Colors.white : Colors.black87,
                  ),
                  icon: const Icon(Icons.info_outline),
                  tooltip: l.editCard,
                  onPressed: _editInfo,
                ),
              ],
            ),
          ),

          // 內容
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: hasBackImage
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.tags
                                .map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          c.note,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(d, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
                      ],
                    )
                  : Center(
                      child: Text(
                        (c.name?.trim().isNotEmpty == true ? c.name! : (c.note.isNotEmpty ? c.note : l.common_unnamed))
                            .trim(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndClearBackImage() async {
    final l = context.l10n;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.clearBackImage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.clear)),
        ],
      ),
    );
    if (ok == true && mounted) {
      final c = widget.card;
      final updated = c.copyWith(backImageUrl: null, backLocalPath: null);
      widget.onChanged(updated);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.updatedCardToast)));

      setState(() {});
    }
  }

  Future<void> _editInfo() async {
    final c = widget.card;

    final albums = <String>{if ((c.album ?? '').isNotEmpty) c.album!};
    final types = <String>{if ((c.cardType ?? '').isNotEmpty) c.cardType!};

    final edited = await showDialog<MiniCardData>(
      context: context,
      builder: (_) => MiniCardEditorDialog(initial: c, allAlbums: albums, allCardTypes: types),
    );
    if (edited != null && mounted) {
      widget.onChanged(edited);
    }
  }
}
