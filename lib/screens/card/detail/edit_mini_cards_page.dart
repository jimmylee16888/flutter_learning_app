import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/mini_card_data.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart';
import 'package:flutter_learning_app/utils/no_cors_image.dart';
import '../../../l10n/l10n.dart'; // ← i18n

class EditMiniCardsPage extends StatefulWidget {
  const EditMiniCardsPage({super.key, required this.initial});
  final List<MiniCardData> initial;

  @override
  State<EditMiniCardsPage> createState() => _EditMiniCardsPageState();
}

class _EditMiniCardsPageState extends State<EditMiniCardsPage> {
  late List<MiniCardData> _cards;
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
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.editMiniCards),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, _cards),
            icon: const Icon(Icons.save_outlined),
            label: Text(l.save),
          ),
        ],
      ),
      body: _cards.isEmpty
          ? Center(child: Text(l.noMiniCardsEmptyList))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _cards.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final c = _cards[i];

                // 判斷是否只有遠端 URL（Web 時要用 NoCorsImage）
                final hasLocal =
                    (c.localPath ?? '').isNotEmpty &&
                    !(kIsWeb && (c.localPath?.startsWith('url:') ?? false));
                final hasRemote = (c.imageUrl ?? '').isNotEmpty;

                final thumb = (kIsWeb && !hasLocal && hasRemote)
                    ? NoCorsImage(
                        c.imageUrl!,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                        borderRadius: 8,
                      )
                    : Image(
                        image: imageProviderOf(c),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        thumb,
                        if (_isLocalOnly(c))
                          Positioned(
                            left: 0,
                            top: 0,
                            child: _miniBadgeIcon(
                              Icons.sd_card,
                              tooltip: l.miniLocalImageBadge,
                            ),
                          ),
                        if (_hasBackImage(c))
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: _miniBadgeIcon(
                              Icons.flip,
                              tooltip: l.miniHasBackBadge,
                            ),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    c.note.isEmpty ? l.common_unnamed : c.note,
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
                              text: l.tagsCount(c.tags.length),
                              icon: Icons.sell_outlined,
                            ),
                          if ((c.imageUrl ?? '').isNotEmpty)
                            _chip(text: l.common_url, icon: Icons.link_outlined)
                          else if ((c.localPath ?? '').isNotEmpty)
                            _chip(
                              text: l.common_local,
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
                        tooltip: l.edit,
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
                              if ((edited.album ?? '').isNotEmpty) {
                                _allAlbums.add(edited.album!);
                              }
                              if ((edited.cardType ?? '').isNotEmpty) {
                                _allCardTypes.add(edited.cardType!);
                              }
                            });
                          }
                        },
                      ),
                      IconButton(
                        tooltip: l.delete,
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
            if ((created.album ?? '').isNotEmpty)
              _allAlbums.add(created.album!);
            if ((created.cardType ?? '').isNotEmpty) {
              _allCardTypes.add(created.cardType!);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

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
  int _side = 0;

  _ImageMode _frontMode = _ImageMode.byUrl;
  late TextEditingController _frontUrl;
  String? _frontLocal;

  _ImageMode _backMode = _ImageMode.byUrl;
  late TextEditingController _backUrl;
  String? _backLocal;

  final _name = TextEditingController();
  final _serial = TextEditingController();
  final _note = TextEditingController();

  static const _languages = <String>['', '中', '英', '日', '韓', '德'];
  String _language = '';

  String? _album;
  String? _cardType;

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
    final l = context.l10n;
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit ? l.miniCardEditTitle : l.miniCardNewTitle),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 280,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _side,
                    padding: const EdgeInsets.all(4),
                    children: {
                      0: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(l.frontSide),
                      ),
                      1: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(l.backSide),
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

              _textField(
                context,
                controller: _name,
                label: l.nameLabel,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 8),
              _textField(
                context,
                controller: _serial,
                label: l.serialNumber,
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _languages.contains(_language) ? _language : '',
                decoration: InputDecoration(
                  labelText: l.language,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.language_outlined),
                ),
                items: _languages
                    .map(
                      (x) => DropdownMenuItem(
                        value: x,
                        child: Text(x.isEmpty ? l.birthdayNotChosen : x),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _language = v ?? ''),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (widget.allAlbums.contains(_album)
                          ? _album
                          : null),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l.album,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.album_outlined),
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
                    tooltip: l.addAlbum,
                    onPressed: () async {
                      final v = await _promptText(
                        context,
                        l.addAlbum,
                        l.enterAlbumName,
                      );
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

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: (widget.allCardTypes.contains(_cardType)
                          ? _cardType
                          : null),
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l.cardType,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.style_outlined),
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
                    tooltip: l.addCardType,
                    onPressed: () async {
                      final v = await _promptText(
                        context,
                        l.addCardType,
                        l.enterCardTypeName,
                      );
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

              TextField(
                controller: _note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.noteLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.tagsLabel,
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
                      decoration: InputDecoration(
                        hintText: l.newTagHint,
                        border: const OutlineInputBorder(),
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
                    child: Text(l.add),
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
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }

  Widget _buildFrontEditor(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.frontImageTitle, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Center(
          child: SizedBox(
            width: 260,
            child: CupertinoSlidingSegmentedControl<_ImageMode>(
              groupValue: _frontMode,
              padding: const EdgeInsets.all(4),
              children: {
                _ImageMode.byUrl: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.imageByUrl),
                ),
                _ImageMode.byLocal: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.imageByLocal),
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
            decoration: InputDecoration(
              labelText: l.frontImageUrlLabel,
              prefixIcon: const Icon(Icons.link_outlined),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          if (_frontUrl.text.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? NoCorsImage(
                      _frontUrl.text,
                      height: 120,
                      fit: BoxFit.cover,
                      borderRadius: 8,
                    )
                  : Image.network(
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
                  label: Text(
                    _frontLocal == null
                        ? l.pickFromGallery
                        : l.localPickedLabel,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_frontLocal != null)
                IconButton(
                  tooltip: l.clearLocal,
                  onPressed: () => setState(() => _frontLocal = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_frontLocal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: imageProviderForLocalPath(_frontLocal!),
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(context),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBackEditor(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.backImageTitleOptional,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Center(
          child: SizedBox(
            width: 260,
            child: CupertinoSlidingSegmentedControl<_ImageMode>(
              groupValue: _backMode,
              padding: const EdgeInsets.all(4),
              children: {
                _ImageMode.byUrl: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.imageByUrl),
                ),
                _ImageMode.byLocal: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.imageByLocal),
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
            decoration: InputDecoration(
              labelText: l.backImageUrlLabel,
              prefixIcon: const Icon(Icons.link_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _backUrl.clear()),
              icon: const Icon(Icons.delete_outline),
              label: Text(l.clearUrl),
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
                  label: Text(
                    _backLocal == null ? l.pickFromGallery : l.localPickedLabel,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_backLocal != null)
                IconButton(
                  tooltip: l.clearLocal,
                  onPressed: () => setState(() => _backLocal = null),
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_backLocal != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: imageProviderForLocalPath(_backLocal!),
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _previewFallback(context),
              ),
            ),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() {
              _backUrl.clear();
              _backLocal = null;
            }),
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(l.clearBackImage),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l = context.l10n;
    final now = DateTime.now();
    final id = widget.initial?.id ?? now.millisecondsSinceEpoch.toString();

    String? imageUrl;
    String? localPath;
    if (_frontMode == _ImageMode.byUrl) {
      final url = _frontUrl.text.trim();
      if (url.isEmpty) {
        _toast(l.errorFrontImageUrlRequired);
        return;
      }
      try {
        // Web 端 downloadImageToLocal 會回 'url:...'，App 端會實存到檔案
        localPath = await downloadImageToLocal(url, preferName: id);
        imageUrl = url;
      } catch (_) {
        _toast(l.downloadFailed);
        return;
      }
    } else {
      if (_frontLocal == null) {
        _toast(l.errorFrontLocalRequired);
        return;
      }
      localPath = _frontLocal;
      imageUrl = widget.initial?.imageUrl;
    }

    String? backImageUrl;
    String? backLocalPath;
    if (_backMode == _ImageMode.byUrl) {
      backImageUrl = _backUrl.text.trim().isEmpty ? null : _backUrl.text.trim();
      backLocalPath = null;
    } else {
      backLocalPath = _backLocal;
      backImageUrl = null;
    }

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

    if (!mounted) return;
    Navigator.pop(context, data);
  }

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
          decoration: InputDecoration(hintText: hint),
          controller: ctrl,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(context.l10n.add),
          ),
        ],
      ),
    );
  }

  Widget _previewFallback(BuildContext context) => Container(
    height: 120,
    color: Theme.of(context).colorScheme.surfaceVariant,
    alignment: Alignment.center,
    child: Text(context.l10n.previewFailed),
  );
}
