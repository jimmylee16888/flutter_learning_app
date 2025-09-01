import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io.dart';
import '../../../../screens/detail/edit_mini_cards_page.dart';

class MiniCardBack extends StatefulWidget {
  const MiniCardBack({super.key, required this.card, required this.onChanged});

  final MiniCardData card;
  final ValueChanged<MiniCardData> onChanged;

  @override
  State<MiniCardBack> createState() => _MiniCardBackState();
}

class _MiniCardBackState extends State<MiniCardBack> {
  @override
  Widget build(BuildContext context) {
    final c = widget.card;

    final hasBackUrl = (c.backImageUrl ?? '').isNotEmpty;
    final hasBackLocal = (c.backLocalPath ?? '').isNotEmpty;
    final hasBackImage = hasBackUrl || hasBackLocal; // 是否有背面可顯示
    final canClearBack = hasBackUrl || hasBackLocal; // 是否可清除背面圖

    final d =
        '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')} '
        '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      color: hasBackImage
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Colors.white, // 沒圖時白底
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (hasBackImage)
            Positioned.fill(
              child: Image(
                image: hasBackLocal
                    ? FileImage(File(c.backLocalPath!)) as ImageProvider
                    : NetworkImage(c.backImageUrl!),
                fit: BoxFit.cover,
              ),
            ),

          // 只有有圖才加漸層
          if (hasBackImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
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
                      backgroundColor: hasBackImage
                          ? Colors.black.withOpacity(0.35)
                          : Colors.black.withOpacity(0.06),
                      foregroundColor: hasBackImage
                          ? Colors.white
                          : Colors.black87,
                    ),
                    tooltip: '清除背面圖',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmAndClearBackImage,
                  ),
                  const SizedBox(width: 6),
                ],
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: hasBackImage
                        ? Colors.black.withOpacity(0.35)
                        : Colors.black.withOpacity(0.06),
                    foregroundColor: hasBackImage
                        ? Colors.white
                        : Colors.black87,
                  ),
                  icon: const Icon(Icons.info_outline),
                  tooltip: '編輯資訊',
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
                                .map(
                                  (t) => Chip(
                                    label: Text(t),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
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
                        Text(
                          d,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    )
                  : Center(
                      // 沒圖時：白底＋名稱置中（退而求其次用 note）
                      child: Text(
                        (c.name?.trim().isNotEmpty == true
                                ? c.name!
                                : (c.note.isNotEmpty ? c.note : '（無名稱）'))
                            .trim(),
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.black87),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndClearBackImage() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除背面圖片？'),
        content: const Text('將同時移除背面網址與本地檔。清除後若正面是遠端圖片，就可以分享 QR / JSON。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final c = widget.card;
      final updated = c.copyWith(backImageUrl: null, backLocalPath: null);
      widget.onChanged(updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已清除背面圖片')));
      setState(() {}); // 觸發重繪（背景變白、按鈕隱藏）
    }
  }

  Future<void> _editInfo() async {
    final c = widget.card;

    // 至少帶入當前卡片已有的專輯 / 卡種，避免必填參數報錯
    final albums = <String>{if ((c.album ?? '').isNotEmpty) c.album!};
    final types = <String>{if ((c.cardType ?? '').isNotEmpty) c.cardType!};

    final edited = await showDialog<MiniCardData>(
      context: context,
      builder: (_) => MiniCardEditorDialog(
        initial: c,
        allAlbums: albums,
        allCardTypes: types,
      ),
    );
    if (edited != null && mounted) {
      widget.onChanged(edited);
    }
  }

  Widget _field(
    BuildContext ctx,
    String label,
    TextEditingController ctl, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
