import 'package:flutter/material.dart';
import '../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart';
import 'dart:io'; // ← 為了 Image.file 與 File(...)

class EditMiniCardsPage extends StatefulWidget {
  const EditMiniCardsPage({super.key, required this.initial});
  final List<MiniCardData> initial;

  @override
  State<EditMiniCardsPage> createState() => _EditMiniCardsPageState();
}

class _EditMiniCardsPageState extends State<EditMiniCardsPage> {
  late List<MiniCardData> _cards = List.of(widget.initial);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯小卡'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, _cards),
            icon: const Icon(Icons.save_outlined),
            label: const Text('儲存'),
          ),
        ],
      ),
      body: _cards.isEmpty
          ? const Center(child: Text('目前沒有小卡，點右下＋新增'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _cards.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final c = _cards[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
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
                  subtitle: Text(
                    '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')} '
                    '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: '編輯',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final edited = await showDialog<MiniCardData>(
                            context: context,
                            builder: (_) => MiniCardEditorDialog(initial: c),
                          );
                          if (edited != null) {
                            setState(() => _cards[i] = edited);
                          }
                        },
                      ),
                      IconButton(
                        tooltip: '刪除',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _cards.removeAt(i)),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<MiniCardData>(
            context: context,
            builder: (_) => const MiniCardEditorDialog(),
          );
          if (created != null) {
            setState(() => _cards.add(created));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MiniCardEditorDialog extends StatefulWidget {
  const MiniCardEditorDialog({super.key, this.initial});
  final MiniCardData? initial;

  @override
  State<MiniCardEditorDialog> createState() => _MiniCardEditorDialogState();
}

enum _ImageMode { byUrl, byLocal }

class _MiniCardEditorDialogState extends State<MiniCardEditorDialog> {
  _ImageMode _mode = _ImageMode.byUrl;
  late final TextEditingController _url = TextEditingController(
    text: widget.initial?.imageUrl ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initial?.note ?? '',
  );
  String? _pickedLocalPath;

  @override
  void initState() {
    super.initState();
    if ((widget.initial?.localPath ?? '').isNotEmpty) {
      _mode = _ImageMode.byLocal;
      _pickedLocalPath = widget.initial!.localPath;
    } else if ((widget.initial?.imageUrl ?? '').isNotEmpty) {
      _mode = _ImageMode.byUrl;
    }
  }

  @override
  void dispose() {
    _url.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit ? '編輯小卡' : '新增小卡'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<_ImageMode>(
              segments: const [
                ButtonSegment(value: _ImageMode.byUrl, label: Text('以網址')),
                ButtonSegment(value: _ImageMode.byLocal, label: Text('本地照片')),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 12),
            if (_mode == _ImageMode.byUrl) ...[
              TextField(
                controller: _url,
                decoration: const InputDecoration(
                  labelText: '圖片網址',
                  hintText: 'https://example.com/photo.jpg',
                  prefixIcon: Icon(Icons.link_outlined),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              if (_url.text.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _url.text,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _previewFallback(context),
                  ),
                ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('從相簿選擇'),
                onPressed: () async {
                  final p = await pickAndCopyToLocal();
                  if (p != null) setState(() => _pickedLocalPath = p);
                },
              ),
              const SizedBox(height: 12),
              if (_pickedLocalPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_pickedLocalPath!),
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _previewFallback(context),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: '反面一句話 / 描述',
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final now = DateTime.now();
            final id =
                widget.initial?.id ?? now.millisecondsSinceEpoch.toString();

            String? imageUrl;
            String? localPath;

            if (_mode == _ImageMode.byUrl) {
              if (_url.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('請輸入圖片網址')));
                return;
              }
              try {
                localPath = await downloadImageToLocal(
                  _url.text.trim(),
                  preferName: id,
                );
                imageUrl = _url.text.trim();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('下載失敗：$e')));
                }
                return;
              }
            } else {
              if (_pickedLocalPath == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('請選擇本地照片')));
                return;
              }
              localPath = _pickedLocalPath!;
              imageUrl = widget.initial?.imageUrl;
            }

            final data = MiniCardData(
              id: id,
              imageUrl: imageUrl,
              localPath: localPath,
              note: _note.text.trim(),
              createdAt: widget.initial?.createdAt ?? now,
            );
            if (!mounted) return;
            Navigator.pop(context, data);
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }

  Widget _previewFallback(BuildContext context) => Container(
    height: 120,
    color: Theme.of(context).colorScheme.surfaceVariant,
    alignment: Alignment.center,
    child: const Text('預覽失敗'),
  );
}
