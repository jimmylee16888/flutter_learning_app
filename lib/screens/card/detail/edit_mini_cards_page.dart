import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart';

class EditMiniCardsPage extends StatefulWidget {
  const EditMiniCardsPage({super.key, required this.initial});
  final List<MiniCardData> initial;

  @override
  State<EditMiniCardsPage> createState() => _EditMiniCardsPageState();
}

class _EditMiniCardsPageState extends State<EditMiniCardsPage> {
  late List<MiniCardData> _cards;

  // 全頁蒐集到的「專輯 / 卡種」清單，提供每張卡做下拉與新增
  late final Set<String> _allAlbums;
  late final Set<String> _allCardTypes;

  @override
  void initState() {
    super.initState();
    _cards = List.of(widget.initial);

    _allAlbums = {
      for (final c in _cards)
        if ((c.album ?? '').isNotEmpty) c.album!,
    };
    _allCardTypes = {
      for (final c in _cards)
        if ((c.cardType ?? '').isNotEmpty) c.cardType!,
    };
  }

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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Image(
                          image: imageProviderOf(c),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                        // 左上：本地圖提示
                        if (_isLocalOnly(c))
                          Positioned(
                            left: 0,
                            top: 0,
                            child: _miniBadgeIcon(
                              Icons.sd_card,
                              tooltip: '本地圖片',
                            ),
                          ),
                        // 右下：含背面提示
                        if (_hasBackImage(c))
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: _miniBadgeIcon(Icons.flip, tooltip: '含背面圖片'),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    c.note.isEmpty ? '(無敘述)' : c.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        _fmtDateTime(c.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      // 精簡資訊徽章列
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if ((c.language ?? '').isNotEmpty)
                            _chip(
                              text: c.language!,
                              icon: Icons.language_outlined,
                            ),
                          if ((c.album ?? '').isNotEmpty)
                            _chip(text: c.album!, icon: Icons.album_outlined),
                          if ((c.cardType ?? '').isNotEmpty)
                            _chip(
                              text: c.cardType!,
                              icon: Icons.style_outlined,
                            ),
                          if (c.tags.isNotEmpty)
                            _chip(
                              text: '標籤 ${c.tags.length}',
                              icon: Icons.sell_outlined,
                            ),
                          // 正面來源：網址 / 本地（只顯示其一，簡潔）
                          if ((c.imageUrl ?? '').isNotEmpty)
                            _chip(text: 'URL', icon: Icons.link_outlined)
                          else if ((c.localPath ?? '').isNotEmpty)
                            _chip(
                              text: '本地',
                              icon: Icons.photo_library_outlined,
                            ),
                        ],
                      ),
                    ],
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
                            builder: (_) => MiniCardEditorDialog(
                              initial: c,
                              allAlbums: _allAlbums,
                              allCardTypes: _allCardTypes,
                            ),
                          );
                          if (edited != null) {
                            setState(() {
                              _cards[i] = edited;
                              // 同步分類集合（保險）
                              if ((edited.album ?? '').isNotEmpty)
                                _allAlbums.add(edited.album!);
                              if ((edited.cardType ?? '').isNotEmpty) {
                                _allCardTypes.add(edited.cardType!);
                              }
                            });
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
            builder: (_) => MiniCardEditorDialog(
              allAlbums: _allAlbums,
              allCardTypes: _allCardTypes,
            ),
          );
          if (created != null) {
            setState(() => _cards.add(created));
            if ((created.album ?? '').isNotEmpty) {
              _allAlbums.add(created.album!);
            }
            if ((created.cardType ?? '').isNotEmpty) {
              _allCardTypes.add(created.cardType!);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ===== Helpers used by the list cells =====

  bool _hasBackImage(MiniCardData c) =>
      (c.backImageUrl ?? '').isNotEmpty || (c.backLocalPath ?? '').isNotEmpty;

  bool _isLocalOnly(MiniCardData c) =>
      (c.imageUrl ?? '').isEmpty && (c.localPath ?? '').isNotEmpty;

  String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _chip({required String text, IconData? icon}) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color.onSurfaceVariant),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color.onSurfaceVariant,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadgeIcon(IconData icon, {String? tooltip}) {
    final bg = Colors.black.withOpacity(0.55);
    final fg = Colors.white;
    final w = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: fg),
    );
    return tooltip == null ? w : Tooltip(message: tooltip, child: w);
  }
}

enum _ImageMode { byUrl, byLocal }

class MiniCardEditorDialog extends StatefulWidget {
  const MiniCardEditorDialog({
    super.key,
    this.initial,
    required this.allAlbums,
    required this.allCardTypes,
  });

  final MiniCardData? initial;
  final Set<String> allAlbums;
  final Set<String> allCardTypes;

  @override
  State<MiniCardEditorDialog> createState() => _MiniCardEditorDialogState();
}

class _MiniCardEditorDialogState extends State<MiniCardEditorDialog> {
  // 分頁：0 正面 / 1 背面
  int _side = 0;

  // 正面
  _ImageMode _frontMode = _ImageMode.byUrl;
  late TextEditingController _frontUrl;
  String? _frontLocal;

  // 背面
  _ImageMode _backMode = _ImageMode.byUrl;
  late TextEditingController _backUrl;
  String? _backLocal;

  // 基本欄位
  final _name = TextEditingController();
  final _serial = TextEditingController();
  final _note = TextEditingController();

  // 語言（固定選項）
  static const _languages = <String>['', '中', '英', '日', '韓', '德'];
  String _language = '';

  // 專輯 / 卡種（單選 + 可新增）
  String? _album;
  String? _cardType;

  // 標籤
  final _newTag = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();

    _frontUrl = TextEditingController(text: widget.initial?.imageUrl ?? '');
    _backUrl = TextEditingController(text: widget.initial?.backImageUrl ?? '');

    _frontLocal = (widget.initial?.localPath?.isNotEmpty ?? false)
        ? widget.initial!.localPath
        : null;
    _backLocal = (widget.initial?.backLocalPath?.isNotEmpty ?? false)
        ? widget.initial!.backLocalPath
        : null;

    if ((_frontLocal ?? '').isNotEmpty &&
        (widget.initial?.imageUrl ?? '').isEmpty) {
      _frontMode = _ImageMode.byLocal;
    }
    if ((_backLocal ?? '').isNotEmpty &&
        (widget.initial?.backImageUrl ?? '').isEmpty) {
      _backMode = _ImageMode.byLocal;
    }

    _name.text = widget.initial?.name ?? '';
    _serial.text = widget.initial?.serial ?? '';
    _note.text = widget.initial?.note ?? '';

    _language = widget.initial?.language ?? '';

    _album = widget.initial?.album;
    if ((_album ?? '').isNotEmpty) widget.allAlbums.add(_album!);

    _cardType = widget.initial?.cardType;
    if ((_cardType ?? '').isNotEmpty) widget.allCardTypes.add(_cardType!);

    _tags = List.of(widget.initial?.tags ?? const <String>[]);
  }

  @override
  void dispose() {
    _frontUrl.dispose();
    _backUrl.dispose();
    _name.dispose();
    _serial.dispose();
    _note.dispose();
    _newTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit ? '編輯小卡' : '新增小卡'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // === 正面 / 背面 分頁：滑動開關 ===
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 280,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _side,
                    padding: const EdgeInsets.all(4),
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('正面'),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('背面'),
                      ),
                    },
                    onValueChanged: (v) => setState(() => _side = v ?? 0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_side == 0)
                _buildFrontEditor(context)
              else
                _buildBackEditor(context),
              const SizedBox(height: 16),

              // ====== 基本資訊 ======
              _textField(
                context,
                controller: _name,
                label: '名稱',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 8),
              _textField(
                context,
                controller: _serial,
                label: '序號',
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 8),

              // 語言（下拉）
              DropdownButtonFormField<String>(
                value: _languages.contains(_language) ? _language : '',
                decoration: const InputDecoration(
                  labelText: '語言',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.language_outlined),
                ),
                items: _languages
                    .map(
                      (x) => DropdownMenuItem(
                        value: x,
                        child: Text(x.isEmpty ? '(未設定)' : x),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _language = v ?? ''),
              ),
              const SizedBox(height: 8),

              // 專輯（下拉 + 新增）
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (widget.allAlbums.contains(_album)
                          ? _album
                          : null),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '專輯',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.album_outlined),
                      ),
                      items: widget.allAlbums
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _album = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: '新增專輯',
                    onPressed: () async {
                      final v = await _promptText(context, '新增專輯', '輸入專輯名稱');
                      if (v != null && v.trim().isNotEmpty) {
                        setState(() {
                          widget.allAlbums.add(v.trim());
                          _album = v.trim();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 卡種（下拉 + 新增）
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (widget.allCardTypes.contains(_cardType)
                          ? _cardType
                          : null),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: '卡種',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.style_outlined),
                      ),
                      items: widget.allCardTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _cardType = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: '新增卡種',
                    onPressed: () async {
                      final v = await _promptText(context, '新增卡種', '輸入卡種名稱');
                      if (v != null && v.trim().isNotEmpty) {
                        setState(() {
                          widget.allCardTypes.add(v.trim());
                          _cardType = v.trim();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 備註
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '備註',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // 標籤
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '標籤',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _tags)
                    InputChip(
                      label: Text(t),
                      onDeleted: () => setState(() => _tags.remove(t)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newTag,
                      decoration: const InputDecoration(
                        hintText: '新增標籤…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      final v = _newTag.text.trim();
                      if (v.isNotEmpty && !_tags.contains(v)) {
                        setState(() {
                          _tags.add(v);
                          _newTag.clear();
                        });
                      }
                    },
                    child: const Text('加入'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _save, child: const Text('儲存')),
      ],
    );
  }

  String _titleOf(MiniCardData c) {
    final name = (c.name ?? '').trim();
    final note = c.note.trim();
    if (name.isNotEmpty && note.isNotEmpty) return '$name · $note';
    if (name.isNotEmpty) return name;
    if (note.isNotEmpty) return note;
    return '(無敘述)';
  }

  // ====== 子區塊：正面編輯 ======
  Widget _buildFrontEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('正面圖片', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Center(
          child: SizedBox(
            width: 260,
            child: CupertinoSlidingSegmentedControl<_ImageMode>(
              groupValue: _frontMode,
              padding: const EdgeInsets.all(4),
              children: const {
                _ImageMode.byUrl: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('網址'),
                ),
                _ImageMode.byLocal: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('本地'),
                ),
              },
              onValueChanged: (v) =>
                  setState(() => _frontMode = v ?? _ImageMode.byUrl),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_frontMode == _ImageMode.byUrl) ...[
          TextField(
            controller: _frontUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: '正面圖片網址',
              prefixIcon: Icon(Icons.link_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (_frontUrl.text.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _frontUrl.text,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(context),
              ),
            ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final p = await pickAndCopyToLocal();
                    if (p != null) setState(() => _frontLocal = p);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_frontLocal == null ? '選本地照片' : '已選：本地'),
                ),
              ),
              const SizedBox(width: 8),
              if (_frontLocal != null)
                IconButton(
                  tooltip: '清除本地',
                  onPressed: () => setState(() => _frontLocal = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_frontLocal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_frontLocal!),
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(context),
              ),
            ),
        ],
      ],
    );
  }

  // ====== 子區塊：背面編輯 ======
  Widget _buildBackEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('背面圖片（可留空）', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Center(
          child: SizedBox(
            width: 260,
            child: CupertinoSlidingSegmentedControl<_ImageMode>(
              groupValue: _backMode,
              padding: const EdgeInsets.all(4),
              children: const {
                _ImageMode.byUrl: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('網址'),
                ),
                _ImageMode.byLocal: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text('本地'),
                ),
              },
              onValueChanged: (v) =>
                  setState(() => _backMode = v ?? _ImageMode.byUrl),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_backMode == _ImageMode.byUrl) ...[
          TextField(
            controller: _backUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: '背面圖片網址',
              prefixIcon: Icon(Icons.link_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _backUrl.clear()),
              icon: const Icon(Icons.delete_outline),
              label: const Text('清除網址'),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final p = await pickAndCopyToLocal();
                    if (p != null) setState(() => _backLocal = p);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_backLocal == null ? '選本地照片' : '已選：本地'),
                ),
              ),
              const SizedBox(width: 8),
              if (_backLocal != null)
                IconButton(
                  tooltip: '清除本地',
                  onPressed: () => setState(() => _backLocal = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_backLocal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_backLocal!),
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(context),
              ),
            ),
        ],
        // 一鍵清除（不論模式）
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _backUrl.clear();
              _backLocal = null;
            }),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('清除背面圖'),
          ),
        ),
      ],
    );
  }

  // ====== 儲存 ======
  Future<void> _save() async {
    final now = DateTime.now();
    final id = widget.initial?.id ?? now.millisecondsSinceEpoch.toString();

    // 正面：必填（網址或本地）
    String? imageUrl;
    String? localPath;
    if (_frontMode == _ImageMode.byUrl) {
      final url = _frontUrl.text.trim();
      if (url.isEmpty) {
        _toast('請輸入正面圖片網址或切換為本地');
        return;
      }
      try {
        localPath = await downloadImageToLocal(url, preferName: id);
        imageUrl = url;
      } catch (e) {
        _toast('下載正面失敗：$e');
        return;
      }
    } else {
      if (_frontLocal == null) {
        _toast('請選擇正面本地照片或切回網址');
        return;
      }
      localPath = _frontLocal;
      // 若希望保留原遠端連結（例如原本就是網址，後來改本地），可保留；否則設成 null。
      imageUrl = widget.initial?.imageUrl;
    }

    // 背面：可留空
    String? backImageUrl;
    String? backLocalPath;
    if (_backMode == _ImageMode.byUrl) {
      backImageUrl = _backUrl.text.trim().isEmpty ? null : _backUrl.text.trim();
      backLocalPath = null;
    } else {
      backLocalPath = _backLocal;
      backImageUrl = null;
    }

    // 語言：空字串視為 null
    final language = _language.isEmpty ? null : _language;

    final data = MiniCardData(
      id: id,
      imageUrl: imageUrl,
      localPath: localPath,
      backImageUrl: backImageUrl,
      backLocalPath: backLocalPath,
      name: _name.text.trim().isEmpty ? null : _name.text.trim(),
      serial: _serial.text.trim().isEmpty ? null : _serial.text.trim(),
      language: language,
      album: (_album ?? '').isEmpty ? null : _album,
      cardType: (_cardType ?? '').isEmpty ? null : _cardType,
      note: _note.text,
      tags: _tags,
      createdAt: widget.initial?.createdAt ?? now,
    );

    // 把專輯/卡種同步回全集合（供其他卡的下拉選單使用）
    if ((data.album ?? '').isNotEmpty) widget.allAlbums.add(data.album!);
    if ((data.cardType ?? '').isNotEmpty)
      widget.allCardTypes.add(data.cardType!);

    if (!mounted) return;
    Navigator.pop(context, data);
  }

  // ====== 小工具 ======
  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _textField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }

  Future<String?> _promptText(
    BuildContext context,
    String title,
    String hint,
  ) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('新增'),
          ),
        ],
      ),
    );
  }

  Widget _previewFallback(BuildContext context) => Container(
    height: 120,
    color: Theme.of(context).colorScheme.surfaceVariant,
    alignment: Alignment.center,
    child: const Text('預覽失敗'),
  );
}
