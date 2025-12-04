// lib/screens/card/cards_view.dart
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart'; // kIsWeb / debugPrint
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/card_item.dart';
import '../../widgets/photo_quote_card.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';
import 'package:flutter_learning_app/utils/no_cors_image/no_cors_image.dart'; // Web CORS 避開元件
import '../../l10n/l10n.dart'; // ← i18n
import '../../widgets/app_popups.dart';

// ⬇️ 改成從 CardItemStore 取資料
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';

import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  String _keyword = '';
  String? _selectedCat;

  // 讚（愛心）資料：用於置頂與圖示切換
  final Map<String, DateTime> _likedAt = {}; // id -> 最近按愛心時間
  final Set<String> _liked = {}; // id 是否點愛心

  static const _tileRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final store = context.watch<CardItemStore>(); // 取得 CardItemStore
    final items = _filtered(store.cardItems);

    return Scaffold(
      body: Column(
        children: [
          _frostedSearchBar(),
          // Category chips
          SizedBox(
            height: 56,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: Text(l.filterAll),
                  selected: _selectedCat == null,
                  onSelected: (_) => setState(() => _selectedCat = null),
                ),
                const SizedBox(width: 8),
                ...store.categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onLongPress: () async {
                        final ok = await showConfirm(
                          context,
                          title: l.deleteCategoryTitle,
                          message: l.deleteCategoryMessage(cat),
                          okLabel: l.delete,
                          cancelLabel: l.cancel,
                        );
                        if (ok) {
                          store.removeCategory(cat);
                          if (_selectedCat == cat) _selectedCat = null;
                          if (mounted) setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.deletedCategoryToast(cat)),
                            ),
                          );
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
          Expanded(child: _layout(items)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCardFlow,
        icon: const Icon(Icons.add),
        label: Text(l.addCard),
      ),
    );
  }

  // ====== Frosted Glass 搜尋列 ======
  Widget _frostedSearchBar() {
    final l = context.l10n;
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
                hintText: l.searchHint,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _keyword = ''),
                        tooltip: l.clear,
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
    final l = context.l10n;
    final n = items.length;
    if (n == 0) return Center(child: Text(l.noCards));
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
    return GridView.count(
      padding: const EdgeInsets.all(6),
      crossAxisCount: 2,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      childAspectRatio: 3 / 2.5,
      children: [for (final it in items) _buildTile(it)],
    );
  }

  // ====== 上層照片可滑（位移限制 < 下層寬度），下層編輯/刪除；圓角無縫 ======
  Widget _buildTile(CardItem it) {
    final l = context.l10n;
    final store = context.read<CardItemStore>();
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final primary = theme.colorScheme.primary;

    final BorderRadius outerR = BorderRadius.circular(_tileRadius); // 外層統一裁切
    final BorderRadius innerR = BorderRadius.circular(
      _tileRadius + 0.8,
    ); // 內層略大，避免細縫

    const double bgRatio = 0.40; // 下層區塊寬度 = 卡片寬 * 0.40
    const double dragInset = 12.0; // 上層最大拖動距離 = 下層寬 - 這個像素
    const double triggerRatio = 0.66; // 觸發門檻（相對 dragLimit）

    final bool isLiked = _liked.contains(it.id);

    return Padding(
      key: ValueKey('tile-${it.id}'),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, c) {
          // 依比例算理想值
          final double rawAction = c.maxWidth * bgRatio;

          // 在小螢幕更安全的下限 / 上限
          const double minAction = 80.0;
          const double maxAction = 220.0;

          // 不得超過「卡片寬的一半 - 安全邊距」，避免 Row 溢位
          final double halfGuard = (c.maxWidth / 2) - 6;

          // 先套上下限，再跟 halfGuard 取較小值
          double actionW = rawAction.clamp(minAction, maxAction);
          actionW = actionW.clamp(0, halfGuard);

          if (actionW.isNaN || actionW.isInfinite || actionW < 0) {
            actionW = 0;
          }

          // 拖動距離也做保護
          final double dragLimit = (actionW - dragInset).clamp(0.0, actionW);

          double dx = 0; // 左負右正（限制在 ±dragLimit）

          Future<void> _animateBack(StateSetter setStateSB) async {
            setStateSB(() => dx = 0);
          }

          Future<void> _handleEnd(StateSetter setStateSB) async {
            final double threshold = dragLimit * triggerRatio;
            if (dx >= threshold) {
              await _editCardFlow(it);
              await _animateBack(setStateSB);
            } else if (dx <= -threshold) {
              final miniStore = context.read<MiniCardStore>();

              final ok = await showConfirm(
                context,
                title: l.deleteCardTitle,
                // 🔔 建議在 l10n 裡加一個新字串，例如：
                // deleteCardAndMiniCardsMessage(name)：
                // 「確定要刪除「{name}」嗎？此動作也會一併刪除此人物底下的小卡。」
                message: l.deleteCardAndMiniCardsMessage(it.title),
                okLabel: l.delete,
                cancelLabel: l.cancel,
              );
              if (ok) {
                store.removeCard(it.id);
                await miniStore.removeByOwner(it.title);
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.deletedCardToast(it.title))),
                  );
                }
              } else {
                await _animateBack(setStateSB);
              }
            }
          }

          // Web 假本地('url:...') 判斷：遇到就用 NoCorsImage
          final String localPath = it.localPath ?? '';
          final bool hasRemote = (it.imageUrl?.isNotEmpty ?? false);

          final bool isWeb = kIsWeb;
          final bool isFakeLocalUrlOnWeb =
              isWeb && localPath.startsWith('url:');

          // 只有真正的本地檔案（或 data:）才算本地
          final bool hasRealLocal =
              localPath.isNotEmpty && !isFakeLocalUrlOnWeb;

          final bool useImageProvider = (!isWeb || hasRealLocal);
          final bool useNoCors = (isWeb && !hasRealLocal && hasRemote);

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

                // 上層：照片（位移限制在 ±dragLimit）
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (d) {
                        setStateSB(() {
                          dx = (dx + d.delta.dx).clamp(-dragLimit, dragLimit);
                        });
                      },
                      onHorizontalDragEnd: (_) => _handleEnd(setStateSB),
                      onHorizontalDragCancel: () => _handleEnd(setStateSB),
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: Offset(dx / c.maxWidth, 0),
                        child: ClipRRect(
                          borderRadius: innerR,
                          clipBehavior: Clip.antiAlias,
                          child: PhotoQuoteCard(
                            key: ValueKey('card-${it.id}'),
                            image: useImageProvider
                                ? imageProviderOfCardItem(it)
                                : null,
                            imageWidget: useNoCors
                                ? NoCorsImage(
                                    it.imageUrl!,
                                    fit: BoxFit.cover,
                                    borderRadius: _tileRadius + 0.8,
                                  )
                                : null,
                            title: it.title,
                            birthday: it.birthday,
                            quote: it.quote,

                            // ✅ 新增：把 CardItem 的欄位往下傳
                            stageName: it.stageName,
                            group: it.group,
                            origin: it.origin,
                            note: it.note,

                            initiallyLiked: isLiked,
                            onLikeChanged: (liked) {
                              setState(() {
                                if (liked) {
                                  _liked.add(it.id);
                                  _likedAt[it.id] = DateTime.now();
                                } else {
                                  _liked.remove(it.id);
                                  _likedAt.remove(it.id);
                                }
                              });
                            },
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

  List<CardItem> _filtered(List<CardItem> src) {
    // 先做類別/關鍵字過濾
    final filtered = src.where((c) {
      final okCat =
          (_selectedCat == null) || c.categories.contains(_selectedCat);
      if (!okCat) return false;
      if (_keyword.trim().isEmpty) return true;
      final k = _keyword.toLowerCase();
      return c.title.toLowerCase().contains(k) ||
          c.quote.toLowerCase().contains(k);
    }).toList();

    // 再依「最近按愛心時間」排序：有 likedAt 的排前面，越新越前
    filtered.sort((a, b) {
      final ta = _likedAt[a.id];
      final tb = _likedAt[b.id];
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta); // 新 → 舊
    });

    return filtered;
  }

  Future<void> _addCardFlow() async {
    final created = await showDialog<CardItem>(
      context: context,
      builder: (_) => const _EditCardDialog(),
    );
    if (created != null) {
      context.read<CardItemStore>().upsertCard(created);
      setState(() {});
    }
  }

  Future<void> _editCardFlow(CardItem item) async {
    final edited = await showDialog<CardItem>(
      context: context,
      builder: (_) => _EditCardDialog(initial: item),
    );
    if (edited != null) {
      context.read<CardItemStore>().upsertCard(edited);
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.updatedCardToast)));
    }
  }

  Future<void> _showCardActions(CardItem item) async {
    final l = context.l10n;
    final store = context.read<CardItemStore>();

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.editCard),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.label_important_outline),
              title: Text(l.categoryAssignOrAdd),
              onTap: () => Navigator.pop(context, 'cat'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.delete),
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
      final miniStore = context.read<MiniCardStore>();

      final ok = await showConfirm(
        context,
        title: l.deleteCardTitle,
        message: l.deleteCardAndMiniCardsMessage(item.title),
        okLabel: l.delete,
        cancelLabel: l.cancel,
      );
      if (ok) {
        store.removeCard(item.id);
        await miniStore.removeByOwner(item.title);
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.deletedCardToast(item.title))));
      }
      return;
    }

    if (action == 'cat') {
      final picked = await showDialog<List<String>>(
        context: context,
        builder: (_) => _CategoryPickerDialog(
          all: store.categories.toList(),
          selected: item.categories,
        ),
      );
      if (picked != null) {
        for (final c in picked) {
          if (!store.categories.contains(c)) {
            store.addCategory(c);
          }
        }
        store.setCardCategories(item.id, picked);
        setState(() {});
      }
    }
  }
}

// ====== 建立/編輯卡片 Dialog ======
class _EditCardDialog extends StatefulWidget {
  const _EditCardDialog({this.initial});
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

  // ✅ 新增欄位
  final _stageName = TextEditingController();
  final _group = TextEditingController();
  final _origin = TextEditingController();
  final _note = TextEditingController();

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

      _url.text = i.imageUrl ?? '';

      // ✅ 帶入新欄位
      _stageName.text = i.stageName ?? '';
      _group.text = i.group ?? '';
      _origin.text = i.origin ?? '';
      _note.text = i.note ?? '';

      // ⭐ 修正預設模式：只在「只有本地、沒有網址」時才當本地模式
      final hasLocal = (i.localPath ?? '').isNotEmpty;
      final hasUrl = _url.text.isNotEmpty;

      if (hasLocal && !hasUrl) {
        // 真・純本地卡片
        _mode = _ImageMode.byLocal;
        _pickedLocalPath = i.localPath;
      } else if (hasUrl) {
        // 只要有網址（不管有沒有本地快取），都視為「網址模式」
        _mode = _ImageMode.byUrl;
        // 如果之後切到本地模式，還是可以用這個路徑
        _pickedLocalPath = i.localPath;
      } else {
        // 都沒有，就先給網址模式，等使用者輸入
        _mode = _ImageMode.byUrl;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final store = context.watch<CardItemStore>();

    return AppAlertDialog(
      title: Text(widget.initial == null ? l.newCardTitle : l.editCardTitle),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: l.nameRequiredLabel,
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 260,
                  child: CupertinoSlidingSegmentedControl<_ImageMode>(
                    groupValue: _mode,
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
                        setState(() => _mode = v ?? _ImageMode.byUrl),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              if (_mode == _ImageMode.byUrl) ...[
                TextField(
                  controller: _url,
                  decoration: InputDecoration(
                    labelText: l.imageUrl,
                    isDense: true,
                    prefixIcon: const Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (_url.text.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? NoCorsImage(
                            _url.text,
                            height: 120,
                            fit: BoxFit.cover,
                            borderRadius: 8,
                          )
                        : Image.network(
                            _url.text,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _fallbackPreview(context),
                          ),
                  ),
              ] else ...[
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l.pickFromGallery),
                  onPressed: () async {
                    final p = await pickAndCopyToLocal();
                    if (p != null) setState(() => _pickedLocalPath = p);
                  },
                ),
                const SizedBox(height: 8),
                if (_pickedLocalPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: imageProviderForLocalPath(_pickedLocalPath!),
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackPreview(context),
                    ),
                  ),
              ],

              const SizedBox(height: 8),
              TextField(
                controller: _quote,
                decoration: InputDecoration(
                  labelText: l.quoteOptionalLabel,
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
                            ? l.pickBirthdayOptional
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

              const SizedBox(height: 12),

              // ✅ 其他資訊區塊（暱稱／團體／來源／備註）
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.extraInfoSectionTitle, // 例如「其他資訊」
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stageName,
                      decoration: InputDecoration(
                        labelText: l.fieldStageNameLabel, // 暱稱 / 藝名
                        isDense: true,
                        prefixIcon: const Icon(Icons.tag_faces_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _group,
                      decoration: InputDecoration(
                        labelText: l.fieldGroupLabel, // 團體 / 系列
                        isDense: true,
                        prefixIcon: const Icon(Icons.group_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _origin,
                decoration: InputDecoration(
                  labelText: l.fieldOriginLabel, // 卡片來源
                  isDense: true,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l.fieldNoteLabel, // 備註
                  isDense: true,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.edit_note_outlined),
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: -8,
                  children: [
                    for (final c in store.categories)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () async {
                          final ok = await showConfirm(
                            context,
                            title: l.deleteCategoryTitle,
                            message: l.deleteCategoryMessage(c),
                            okLabel: l.delete,
                            cancelLabel: l.cancel,
                          );
                          if (ok) {
                            store.removeCategory(c);
                            setState(() => _cats.remove(c));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l.deletedCategoryToast(c)),
                                ),
                              );
                            }
                          }
                        },
                        child: FilterChip(
                          label: Text(c),
                          selected: _cats.contains(c),
                          onSelected: (v) => setState(
                            () => v ? _cats.add(c) : _cats.remove(c),
                          ),
                        ),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l.addCategory),
                      onPressed: () async {
                        final name = await showPrompt(
                          context,
                          title: l.addCategory,
                          hintText: l.newCategoryNameHint,
                          okLabel: l.add,
                          cancelLabel: l.cancel,
                        );
                        if (name != null && name.trim().isNotEmpty) {
                          final n = name.trim();
                          if (!store.categories.contains(n)) {
                            store.addCategory(n);
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
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final t = _title.text.trim();
            if (t.isEmpty) return;

            // 🔒 檢查名稱是否重複（不分大小寫，排除自己）
            final lower = t.toLowerCase();
            final selfId = widget.initial?.id;
            final exists = store.cardItems.any(
              (c) => c.id != selfId && c.title.trim().toLowerCase() == lower,
            );

            if (exists) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.cardNameAlreadyExists(t))),
              );
              return;
            }

            final id =
                widget.initial?.id ??
                DateTime.now().millisecondsSinceEpoch.toString();

            String? imageUrl;
            String? localPath;

            if (_mode == _ImageMode.byUrl) {
              final url = _url.text.trim();
              if (url.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.inputImageUrl)));
                return;
              }

              // ⭐ 取得舊的 url / localPath
              final oldUrl = widget.initial?.imageUrl?.trim();
              final oldLocalPath = widget.initial?.localPath;

              imageUrl = url;

              // ⭐ 判斷網址是否有變
              final bool urlChanged = (oldUrl == null) || (oldUrl != url);

              if (!urlChanged &&
                  oldLocalPath != null &&
                  oldLocalPath.isNotEmpty) {
                // ✅ 網址沒變，而且以前就有本地快取 → 直接沿用，不重抓
                localPath = oldLocalPath;
              } else {
                // ✅ 網址有變（或以前沒快取）→ 強制重新下載
                try {
                  // 你可以沿用 id，讓舊檔被覆蓋
                  localPath = await downloadImageToLocal(url, preferName: id);
                } catch (e) {
                  debugPrint('downloadImageToLocal failed: $e');
                  localPath = null;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.downloadFailed)));
                }
              }
            } else {
              // 📂 本地模式
              if (_pickedLocalPath == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.pickLocalPhoto)));
                return;
              }
              localPath = _pickedLocalPath!;
              // 本地模式保持原本 imageUrl（向下相容）
              imageUrl = widget.initial?.imageUrl;
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
                stageName: _stageName.text.trim().isEmpty
                    ? null
                    : _stageName.text.trim(),
                group: _group.text.trim().isEmpty ? null : _group.text.trim(),
                origin: _origin.text.trim().isEmpty
                    ? null
                    : _origin.text.trim(),
                note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              ),
            );
          },
          child: Text(l.save),
        ),
      ],
    );
  }

  Widget _fallbackPreview(BuildContext context) => Container(
    height: 120,
    alignment: Alignment.center,
    color: Theme.of(context).colorScheme.surfaceVariant,
    child: Text(context.l10n.previewFailed),
  );
}

class _CategoryPickerDialog extends StatefulWidget {
  const _CategoryPickerDialog({required this.all, required this.selected});
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
    final l = context.l10n;
    final store = context.read<CardItemStore>();

    return AppAlertDialog(
      title: Text(l.assignCategoryTitle),
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
                        onChanged: (v) => setState(
                          () => v == true ? _sel.add(cat) : _sel.remove(cat),
                        ),
                      ),
                      title: Text(cat),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l.deleteCategoryTooltip,
                        onPressed: () async {
                          final ok = await showConfirm(
                            context,
                            title: l.deleteCategoryTitle,
                            message: l.deleteCategoryMessage(cat),
                            okLabel: l.delete,
                            cancelLabel: l.cancel,
                          );
                          if (ok) {
                            store.removeCategory(cat);
                            setState(() {
                              _sel.remove(cat);
                              widget.all.remove(cat);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.deletedCategoryToast(cat)),
                              ),
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
                    decoration: InputDecoration(
                      hintText: l.newCategoryNameHint,
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
                      store.addCategory(name);
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
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _sel.toList()),
          child: Text(l.confirm),
        ),
      ],
    );
  }
}
