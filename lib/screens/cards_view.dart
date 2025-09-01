import 'dart:io';
import 'dart:ui' as ui; // for ImageFilter.blur
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_settings.dart';
import '../models/card_item.dart';
import '../widgets/photo_quote_card.dart';
import 'package:flutter_learning_app/utils/mini_card_io.dart'; // 共用下載/挑圖/Provider

class CardsView extends StatefulWidget {
  const CardsView({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  String _keyword = '';
  String? _selectedCat;

  static const _tileRadius = 16.0;
  static const _tileMargin = EdgeInsets.all(12);

  @override
  Widget build(BuildContext context) {
    final items = _filtered(widget.settings.cardItems);

    return Scaffold(
      body: Column(
        children: [
          _frostedSearchBar(),
          // 分類 Chips
          SizedBox(
            height: 56,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: _selectedCat == null,
                  onSelected: (_) => setState(() => _selectedCat = null),
                ),
                const SizedBox(width: 8),
                // CardsView 的 build() 裡，分類 Chips 區塊
                ...widget.settings.categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onLongPress: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('刪除分類'),
                            content: Text('確定要刪除分類「$cat」嗎？\n（將同時自所有卡片移除該分類）'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('刪除'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          widget.settings.removeCategory(cat);
                          if (_selectedCat == cat)
                            _selectedCat = null; // 若當前選擇的剛好被刪
                          if (mounted) setState(() {});
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('已刪除分類：$cat')));
                        }
                      },
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCat == cat,
                        onSelected: (_) => setState(
                          () =>
                              _selectedCat = (_selectedCat == cat) ? null : cat,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 版面（沿用你之前 1/2/多張的規則）
          Expanded(child: _layout(items)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCardFlow,
        icon: const Icon(Icons.add),
        label: const Text('新增藝人卡'),
      ),
    );
  }

  // ====== Frosted Glass 搜尋列 ======
  Widget _frostedSearchBar() {
    final bg = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: bg.withOpacity(0.6),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: TextField(
              onChanged: (s) => setState(() => _keyword = s),
              decoration: InputDecoration(
                hintText: '搜尋人名／卡片內容',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _keyword = ''),
                        tooltip: '清除',
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====== 排版（1/2/多張）======
  Widget _layout(List<CardItem> items) {
    final n = items.length;
    if (n == 0) return const Center(child: Text('沒有卡片'));
    if (n == 1) {
      return Center(
        child: SizedBox(width: 350, height: 500, child: _buildTile(items[0])),
      );
    }
    if (n == 2) {
      return Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _buildTile(items[0]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _buildTile(items[1]),
            ),
          ),
        ],
      );
    }

    // ★ 重要：格子不設 spacing，改由 tile 內部 padding 控制
    return GridView.count(
      padding: const EdgeInsets.all(6),
      crossAxisCount: 2,
      crossAxisSpacing: 0, // ★
      mainAxisSpacing: 0, // ★
      childAspectRatio: 3 / 2.5,
      children: [for (final it in items) _buildTile(it)],
    );
  }

  // ====== 單一卡片（右滑編輯、左滑刪除；零間隙）======
  Widget _buildTile(CardItem it) {
    final errorColor = Theme.of(context).colorScheme.error;
    final primary = Theme.of(context).colorScheme.primary;

    // 背景做得比卡片更大一點的圓角，鋪在卡片下方
    Widget slideBg({
      required Alignment align,
      required Color color,
      required IconData icon,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_tileRadius + 6), // ← 關鍵：比卡片更大
        ),
        alignment: align,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Icon(icon, color: errorColor, size: 22),
      );
    }

    // 外距放在 Dismissible 外，避免邊緣出現底色
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Dismissible(
        key: ValueKey(it.id),
        direction: DismissDirection.horizontal,

        // 右滑：編輯
        background: slideBg(
          align: Alignment.centerLeft,
          color: primary.withOpacity(0.12),
          icon: Icons.edit,
        ),

        // 左滑：刪除
        secondaryBackground: slideBg(
          align: Alignment.centerRight,
          color: errorColor.withOpacity(0.15),
          icon: Icons.delete,
        ),

        confirmDismiss: (dir) async {
          if (dir == DismissDirection.startToEnd) {
            await _editCardFlow(it); // 右滑只開編輯，不真的 dismiss
            return false;
          }
          return await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('刪除卡片'),
                  content: Text('確定要刪除「${it.title}」嗎？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('刪除'),
                    ),
                  ],
                ),
              ) ??
              false;
        },

        onDismissed: (dir) {
          if (dir == DismissDirection.endToStart) {
            widget.settings.removeCard(it.id);
            setState(() {});
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('已刪除：${it.title}')));
          }
        },

        // ★ 只裁切卡片，不裁切背景
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_tileRadius),
          clipBehavior: Clip.hardEdge,
          child: PhotoQuoteCard(
            image: imageProviderOfCardItem(it), // ← 這個 helper 見下方
            title: it.title,
            birthday: it.birthday,
            quote: it.quote,
          ),
        ),
      ),
    );
  }

  // ====== 篩選 ======
  List<CardItem> _filtered(List<CardItem> src) {
    return src.where((c) {
      final okCat =
          (_selectedCat == null) || c.categories.contains(_selectedCat);
      if (!okCat) return false;
      if (_keyword.trim().isEmpty) return true;
      final k = _keyword.toLowerCase();
      return c.title.toLowerCase().contains(k) ||
          c.quote.toLowerCase().contains(k);
    }).toList();
  }

  // ====== 新增／編輯流程 ======
  Future<void> _addCardFlow() async {
    final created = await showDialog<CardItem>(
      context: context,
      builder: (_) => _EditCardDialog(settings: widget.settings),
    );
    if (created != null) {
      widget.settings.upsertCard(created);
      setState(() {});
    }
  }

  Future<void> _editCardFlow(CardItem item) async {
    final edited = await showDialog<CardItem>(
      context: context,
      builder: (_) => _EditCardDialog(settings: widget.settings, initial: item),
    );
    if (edited != null) {
      widget.settings.upsertCard(edited);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已更新卡片')));
    }
  }

  // ====== 卡片操作（長按）======
  Future<void> _showCardActions(CardItem item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('編輯卡片'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.label_important_outline),
              title: const Text('指派 / 新增分類'),
              onTap: () => Navigator.pop(context, 'cat'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('刪除'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => Navigator.pop(context, 'del'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'edit') {
      await _editCardFlow(item);
      return;
    }

    if (action == 'del') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('刪除卡片'),
          content: Text('確定要刪除「${item.title}」嗎？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('刪除'),
            ),
          ],
        ),
      );
      if (ok == true) {
        widget.settings.removeCard(item.id);
        setState(() {});
      }
      return;
    }

    if (action == 'cat') {
      final picked = await showDialog<List<String>>(
        context: context,
        builder: (_) => _CategoryPickerDialog(
          settings: widget.settings, // ← 新增這行
          all: widget.settings.categories.toList(),
          selected: item.categories,
        ),
      );

      if (picked != null) {
        for (final c in picked) {
          if (!widget.settings.categories.contains(c)) {
            widget.settings.addCategory(c);
          }
        }
        widget.settings.setCardCategories(item.id, picked);
        setState(() {});
      }
    }
  }
}

// ====== 建立/編輯卡片 Dialog ======
// 放在檔案底部原本的位置，整段覆蓋
class _EditCardDialog extends StatefulWidget {
  const _EditCardDialog({required this.settings, this.initial});
  final AppSettings settings;
  final CardItem? initial;

  @override
  State<_EditCardDialog> createState() => _EditCardDialogState();
}

enum _ImageMode { byUrl, byLocal }

class _EditCardDialogState extends State<_EditCardDialog> {
  final _title = TextEditingController();
  final _quote = TextEditingController();
  final Set<String> _cats = {};
  DateTime? _birthday;

  _ImageMode _mode = _ImageMode.byUrl;
  final _url = TextEditingController();
  String? _pickedLocalPath;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _title.text = i.title;
      _quote.text = i.quote;
      _birthday = i.birthday;
      _cats.addAll(i.categories);
      _url.text = i.imageUrl ?? '';
      if ((i.localPath ?? '').isNotEmpty) {
        _mode = _ImageMode.byLocal;
        _pickedLocalPath = i.localPath;
      } else if ((_url.text).isNotEmpty) {
        _mode = _ImageMode.byUrl;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? '新增卡片' : '編輯卡片'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: '名稱（必填）',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              // 圖片來源切換 → 改成滑動開關
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 260,
                  child: CupertinoSlidingSegmentedControl<_ImageMode>(
                    groupValue: _mode,
                    padding: const EdgeInsets.all(4),
                    children: const {
                      _ImageMode.byUrl: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('以網址'),
                      ),
                      _ImageMode.byLocal: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text('本地照片'),
                      ),
                    },
                    onValueChanged: (v) =>
                        setState(() => _mode = v ?? _ImageMode.byUrl),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (_mode == _ImageMode.byUrl) ...[
                TextField(
                  controller: _url,
                  decoration: const InputDecoration(
                    labelText: '圖片 URL',
                    isDense: true,
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (_url.text.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _url.text,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackPreview(context),
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
                const SizedBox(height: 8),
                if (_pickedLocalPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pickedLocalPath!),
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackPreview(context),
                    ),
                  ),
              ],

              const SizedBox(height: 8),
              TextField(
                controller: _quote,
                decoration: const InputDecoration(
                  labelText: '語錄（可選）',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        _birthday == null
                            ? '選擇生日（可選）'
                            : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                      ),
                      onPressed: () async {
                        final today = DateTime.now();
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _birthday ?? DateTime(today.year, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(today.year + 1),
                        );
                        if (d != null) setState(() => _birthday = d);
                      },
                    ),
                  ),
                ],
              ),

              const Divider(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: -8,
                  children: [
                    for (final c in widget.settings.categories)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('刪除分類'),
                              content: Text('確定要刪除分類「$c」嗎？\n（會從所有卡片移除）'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('刪除'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            // 1) 先從全域設定刪除（會同步清掉所有卡片中該分類）
                            widget.settings.removeCategory(c);
                            // 2) 再從對話框目前的選取集合移除，然後刷新畫面
                            setState(() => _cats.remove(c));
                            // 3) 提示
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('已刪除分類：$c')),
                              );
                            }
                          }
                        },
                        child: FilterChip(
                          label: Text(c),
                          selected: _cats.contains(c),
                          onSelected: (v) {
                            setState(() => v ? _cats.add(c) : _cats.remove(c));
                          },
                        ),
                      ),

                    // 仍保留「新增分類」按鈕
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('新增分類'),
                      onPressed: () async {
                        final name = await _promptNewCategory(context);
                        if (name != null && name.trim().isNotEmpty) {
                          final n = name.trim();
                          if (!widget.settings.categories.contains(n)) {
                            widget.settings.addCategory(n);
                          }
                          setState(() => _cats.add(n));
                        }
                      },
                    ),
                  ],
                ),
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
        FilledButton(
          onPressed: () async {
            final t = _title.text.trim();
            if (t.isEmpty) return;

            final id =
                widget.initial?.id ??
                DateTime.now().millisecondsSinceEpoch.toString();
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('下載失敗：$e')));
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
              imageUrl = widget.initial?.imageUrl; // 保留原網址（若有）
            }

            Navigator.pop(
              context,
              CardItem(
                id: id,
                title: t,
                imageUrl: imageUrl,
                localPath: localPath,
                quote: _quote.text.trim(),
                birthday: _birthday,
                categories: _cats.toList(),
              ),
            );
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }

  Widget _fallbackPreview(BuildContext context) => Container(
    height: 120,
    alignment: Alignment.center,
    color: Theme.of(context).colorScheme.surfaceVariant,
    child: const Text('預覽失敗'),
  );

  Future<String?> _promptNewCategory(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增分類'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '輸入分類名稱'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('新增'),
          ),
        ],
      ),
    );
  }
}

// 勾選／新增分類 Dialog
class _CategoryPickerDialog extends StatefulWidget {
  const _CategoryPickerDialog({
    required this.settings, // ← 新增
    required this.all,
    required this.selected,
  });
  final AppSettings settings; // ← 新增
  final List<String> all;
  final List<String> selected;

  @override
  State<_CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<_CategoryPickerDialog> {
  late Set<String> _sel;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sel = Set.of(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('指派分類'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final cat in widget.all)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: _sel.contains(cat),
                        onChanged: (v) => setState(() {
                          if (v == true)
                            _sel.add(cat);
                          else
                            _sel.remove(cat);
                        }),
                      ),
                      title: Text(cat),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '刪除分類',
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('刪除分類'),
                              content: Text('確定要刪除分類「$cat」嗎？\n（將同時自所有卡片移除該分類）'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('刪除'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            widget.settings.removeCategory(cat); // ← 直接刪
                            setState(() {
                              _sel.remove(cat);
                              widget.all.remove(cat); // 對話框內即時更新列表
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('已刪除分類：$cat')),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: '新增分類名稱',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final name = _ctrl.text.trim();
                    if (name.isEmpty) return;
                    if (!widget.all.contains(name)) {
                      widget.settings.addCategory(name); // 保持和全域同步
                      setState(() => widget.all.add(name));
                    }
                    setState(() => _sel.add(name));
                    _ctrl.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _sel.toList()),
          child: const Text('確定'),
        ),
      ],
    );
  }
}
