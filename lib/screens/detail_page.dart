import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 詳細頁：上方大圖＋愛心，下面資訊＋可左右滑動的小卡區域
class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    required this.image,
    required this.title,
    this.birthday,
    required this.quote,
    this.initiallyLiked = false,
  });

  final ImageProvider image; // 大圖
  final String title; // 名稱/標題（用來當作儲存 key 的一部分）
  final DateTime? birthday; // 生日（可選）
  final String quote; // 給粉絲的一句話
  final bool initiallyLiked;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late bool _liked = widget.initiallyLiked;

  // 小卡資料
  List<MiniCardData> _miniCards = [];

  // ----------- SharedPreferences Key（可依需求改：確保唯一） -----------
  String get _cardsKey => 'miniCards:${widget.title}';
  String get _likedKey => 'liked:${widget.title}';

  @override
  void initState() {
    super.initState();
    _loadPersisted();
  }

  Future<void> _loadPersisted() async {
    final sp = await SharedPreferences.getInstance();

    // liked
    _liked = sp.getBool(_likedKey) ?? widget.initiallyLiked;

    // cards
    final raw = sp.getString(_cardsKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(MiniCardData.fromJson)
          .toList();
      _miniCards = list;
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveLiked() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_likedKey, _liked);
  }

  Future<void> _saveCards() async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(_miniCards.map((e) => e.toJson()).toList());
    await sp.setString(_cardsKey, raw);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.birthday;
    final bdayText = b == null
        ? '—'
        : '${b.year}-${b.month.toString().padLeft(2, '0')}-${b.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: '編輯小卡',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.of(context)
                  .push<List<MiniCardData>>(
                    MaterialPageRoute(
                      builder: (_) => EditMiniCardsPage(initial: _miniCards),
                    ),
                  );
              if (updated != null) {
                setState(() => _miniCards = updated);
                await _saveCards(); // ← 儲存
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // 上方圖片 + 愛心
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: widget.image, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FilledButton.tonalIcon(
                    onPressed: () async {
                      setState(() => _liked = !_liked);
                      await _saveLiked(); // ← 儲存
                    },
                    icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                    label: Text(_liked ? '已收藏' : '收藏'),
                  ),
                ),
              ],
            ),
          ),
          // 資訊
          ListTile(
            leading: const Icon(Icons.cake_outlined),
            title: const Text('生日'),
            subtitle: Text(bdayText),
          ),
          const Divider(height: 0),

          // 一句話
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              '給粉絲的一句話',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              '“${widget.quote}”',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          // 小卡區塊（左右滑動）
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text('粉絲小卡', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (_miniCards.isEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.of(context)
                          .push<List<MiniCardData>>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditMiniCardsPage(initial: _miniCards),
                            ),
                          );
                      if (updated != null) {
                        setState(() => _miniCards = updated);
                        await _saveCards(); // ← 儲存
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新增'),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: _miniCards.isEmpty
                ? Center(
                    child: Text(
                      '尚無小卡，點右上角「編輯」新增',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final d = _miniCards[i];
                      return SizedBox(
                        width: 160,
                        child: FlipMiniCard(
                          front: _MiniCardFront(imageUrl: d.imageUrl),
                          back: _MiniCardBack(text: d.note, date: d.createdAt),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: _miniCards.length,
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/* -------------------- 小卡資料型別（可序列化） -------------------- */
class MiniCardData {
  MiniCardData({
    required this.id,
    required this.imageUrl,
    required this.note,
    required this.createdAt,
  });

  final String id; // 唯一鍵（可用時間戳）
  final String imageUrl; // 照片網址/路徑
  final String note; // 反面的一句話/描述
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MiniCardData.fromJson(Map<String, dynamic> json) => MiniCardData(
    id: json['id'] as String,
    imageUrl: json['imageUrl'] as String,
    note: json['note'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/* -------------------- 翻牌小卡（正反面） -------------------- */
class FlipMiniCard extends StatefulWidget {
  const FlipMiniCard({super.key, required this.front, required this.back});

  final Widget front;
  final Widget back;

  @override
  State<FlipMiniCard> createState() => _FlipMiniCardState();
}

class _FlipMiniCardState extends State<FlipMiniCard> {
  bool _showFront = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFront = !_showFront),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _showFront ? 0 : 1),
        duration: const Duration(milliseconds: 350),
        builder: (context, val, child) {
          final angle = val * math.pi;
          final isFront = val < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透視
              ..rotateY(angle),
            child: isFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

/* -------------------- 小卡正面 -------------------- */
class _MiniCardFront extends StatelessWidget {
  const _MiniCardFront({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Ink.image(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
        child: const SizedBox.expand(),
      ),
    );
  }
}

/* -------------------- 小卡反面 -------------------- */
class _MiniCardBack extends StatelessWidget {
  const _MiniCardBack({required this.text, required this.date});
  final String text;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(d, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/* -------------------- 編輯頁：新增/編輯/刪除小卡 -------------------- */
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
                    child: Image.network(
                      c.imageUrl,
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

/* -------------------- 小卡編輯對話框（輸入圖片網址＋敘述） -------------------- */
class MiniCardEditorDialog extends StatefulWidget {
  const MiniCardEditorDialog({super.key, this.initial});
  final MiniCardData? initial;

  @override
  State<MiniCardEditorDialog> createState() => _MiniCardEditorDialogState();
}

class _MiniCardEditorDialogState extends State<MiniCardEditorDialog> {
  late final TextEditingController _url = TextEditingController(
    text: widget.initial?.imageUrl ?? '',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.initial?.note ?? '',
  );

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
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: '圖片網址',
                hintText: 'https://example.com/photo.jpg',
                prefixIcon: Icon(Icons.image_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: '反面一句話 / 描述',
                prefixIcon: Icon(Icons.edit_note_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            if (_url.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _url.text,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Text('預覽失敗'),
                    );
                  },
                ),
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
          onPressed: () {
            final now = DateTime.now();
            final data = MiniCardData(
              id: widget.initial?.id ?? now.millisecondsSinceEpoch.toString(),
              imageUrl: _url.text.trim(),
              note: _note.text.trim(),
              createdAt: widget.initial?.createdAt ?? now,
            );
            Navigator.pop(context, data);
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
}
