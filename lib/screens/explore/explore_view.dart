import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';

import 'explore_item.dart';
import '../../services/explore_store.dart';
import 'draggable_card.dart';
import 'countdown_flip_card.dart';
import 'grid_paper.dart';
import 'hearts.dart';

// ad
import 'ad_config.dart';
import 'ad_provider.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});
  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView>
    with SingleTickerProviderStateMixin {
  final List<ExploreItem> _items = [];
  final _canvasKey = GlobalKey();

  AdRenderInfo? _adInfo;

  // hearts + balls 共用 ticker
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Size _canvasSize = Size.zero;
  final List<Heart> _hearts = [];

  // 儲存去抖
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _saveScheduled = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();

    AdProvider.I.initialize().then((_) {
      if (!mounted) return;
      setState(() => _adInfo = AdProvider.I.renderInfo);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loaded = await ExploreStore.I.load();
      setState(() {
        _items
          ..clear()
          ..addAll(loaded);
        // 補廣告
        if (!_items.any((e) => e.kind == ExploreKind.ad)) {
          _items.add(
            ExploreItem(
              kind: ExploreKind.ad,
              pos: const Offset(24, 120),
              w: 324, // 180*1.8
              h: 162, // 180*0.9
              deletable: false,
            ),
          );
          _persistNow();
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  List<Color> get _softPalette {
    final c = Theme.of(context).colorScheme;
    return [
      c.primaryContainer,
      c.secondaryContainer,
      c.tertiaryContainer,
      c.surfaceVariant,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onLongPressStart: (details) {
              final box =
                  _canvasKey.currentContext?.findRenderObject() as RenderBox?;
              final local =
                  box?.globalToLocal(details.globalPosition) ??
                  details.localPosition;
              _spawnHearts(local);
            },
            child: Stack(
              key: _canvasKey,
              children: [
                // 背景格線
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPaperPainter(
                      color: cs.outlineVariant.withOpacity(0.18),
                    ),
                  ),
                ),

                // 卡片 / 小球
                ..._items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;

                  if (it.kind == ExploreKind.ball) {
                    // 小球：用 BallBubble 處理拖曳 + 反彈 + 刪除
                    final d = it.ballDiameter;
                    final clamped = _clamp(it.pos, Size(d, d), _canvasSize);
                    if (clamped != it.pos) it.pos = clamped;

                    return Positioned(
                      left: it.pos.dx,
                      top: it.pos.dy,
                      width: d,
                      height: d,
                      child: _BallBubble(
                        item: it,
                        canvasSize: _canvasSize,
                        deletable: it.deletable,
                        onDelete: () {
                          setState(() => _items.removeAt(i));
                          _persistSoon();
                        },
                        onChanged: () {
                          _persistSoon();
                          setState(() {});
                        },
                      ),
                    );
                  }

                  // 其它種類：方卡/廣告
                  final isAd = it.kind == ExploreKind.ad;
                  final Size cardSize = Size(it.w, it.h);

                  it.pos = _clamp(it.pos, cardSize, _canvasSize);

                  return Positioned(
                    left: it.pos.dx,
                    top: it.pos.dy,
                    width: cardSize.width,
                    height: cardSize.height,
                    child: DraggableCard(
                      deletable: it.deletable,
                      onDelete: it.deletable
                          ? () {
                              setState(() => _items.removeAt(i));
                              _persistSoon();
                            }
                          : null,
                      onDragUpdate: (delta) {
                        setState(() {
                          it.pos = _clamp(
                            it.pos + delta,
                            cardSize,
                            _canvasSize,
                          );
                        });
                        _persistSoon();
                      },
                      // 長按才會出現的縮放把手
                      onResize: isAd
                          ? null
                          : (delta) {
                              setState(() {
                                const min = 100.0;
                                final maxW = _canvasSize.width - it.pos.dx - 8;
                                final maxH = _canvasSize.height - it.pos.dy - 8;
                                it.w = (it.w + delta.dx).clamp(min, maxW);
                                it.h = (it.h + delta.dy).clamp(min, maxH);
                              });
                              _persistSoon();
                            },
                      child: _buildCard(it, cs),
                    ),
                  );
                }),

                // hearts 動畫層
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: HeartsPainter(_hearts)),
                  ),
                ),

                // 右上：元件歸位
                Positioned(
                  right: 12,
                  top: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'reset',
                    tooltip: '元件歸位',
                    onPressed: () {
                      _resetLayout();
                      _persistSoon();
                    },
                    child: const Icon(Icons.grid_view),
                  ),
                ),

                // 右下：新增
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.add),
                    label: const Text('新增'),
                    onPressed: _showAddSheet,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===== UI =====

  Widget _buildCard(ExploreItem it, ColorScheme cs) {
    final bg = _softPalette[it.hashCode % _softPalette.length];
    const radius = 20.0;

    switch (it.kind) {
      case ExploreKind.photo:
        final img = _imageProviderOf(it);
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: DecoratedBox(
            decoration: BoxDecoration(color: bg),
            child: img == null
                ? _EmptyCenter(icon: Icons.photo, hint: '未選擇照片')
                : Image(image: img, fit: BoxFit.cover),
          ),
        );

      case ExploreKind.quote:
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: bg,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(14),
            child: Text(
              it.quote ?? 'Tap 以編輯引言',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: cs.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );

      case ExploreKind.countdown:
        return CountdownFlipCard(
          item: it,
          bg: bg,
          radius: radius,
          onToggle: () {
            setState(() => it.isBack = !it.isBack);
            _persistSoon();
          },
        );

      case ExploreKind.ad:
        final info = _adInfo;
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: () async {
              if (info == null) return;
              await info.onTap();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primaryContainer, cs.secondaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                if (info != null) Image(image: info.banner, fit: BoxFit.cover),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case ExploreKind.ball:
        return const SizedBox.shrink();
    }
  }

  /// ===== helpers =====

  Offset _clamp(Offset off, Size size, Size canvas) {
    final dx = off.dx
        .clamp(8.0, math.max(8.0, canvas.width - 8.0 - size.width))
        .toDouble();
    final dy = off.dy
        .clamp(8.0, math.max(8.0, canvas.height - 8.0 - size.height))
        .toDouble();
    return Offset(dx, dy);
  }

  ImageProvider? _imageProviderOf(ExploreItem it) {
    if ((it.imagePath ?? '').isNotEmpty) {
      final f = File(it.imagePath!);
      if (f.existsSync()) return FileImage(f);
    }
    if ((it.imageUrl ?? '').isNotEmpty) {
      return NetworkImage(it.imageUrl!);
    }
    return null;
  }

  Future<void> _showAddSheet() async {
    final cs = Theme.of(context).colorScheme;
    final kind = await showModalBottomSheet<ExploreKind>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(
            runSpacing: 8,
            children: [
              _AddTile(
                icon: Icons.photo,
                label: '照片卡',
                onTap: () => Navigator.pop(context, ExploreKind.photo),
              ),
              _AddTile(
                icon: Icons.format_quote,
                label: '引言卡',
                onTap: () => Navigator.pop(context, ExploreKind.quote),
              ),
              _AddTile(
                icon: Icons.event,
                label: '生日倒數',
                onTap: () => Navigator.pop(context, ExploreKind.countdown),
              ),
              _AddTile(
                icon: Icons.sports_baseball,
                label: '新增小球',
                onTap: () => Navigator.pop(context, ExploreKind.ball),
              ),
              Divider(color: cs.outlineVariant),
              ListTile(
                title: Text('廣告已內建', style: TextStyle(color: cs.outline)),
              ),
            ],
          ),
        ),
      ),
    );

    if (kind == null) return;

    // 預設尺寸
    final defaultW = 160.0;
    final defaultH = 160.0;

    final item = ExploreItem(
      kind: kind,
      w: defaultW,
      h: defaultH,
      pos: const Offset(24, 100),
      deletable: kind != ExploreKind.ad,
    );

    switch (kind) {
      case ExploreKind.photo:
        final picker = ImagePicker();
        final x = await picker.pickImage(source: ImageSource.gallery);
        if (x == null) return;
        item.imagePath = x.path;
        break;
      case ExploreKind.quote:
        final text = await _promptText('輸入一句話');
        if (text == null) return;
        item.quote = text;
        break;
      case ExploreKind.countdown:
        final t = await _promptText('偶像/事件名稱（例如：Sakura 生日）');
        if (t == null) return;
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );
        if (d == null) return;
        item.title = t;
        item.countdownDate = d;
        break;
      case ExploreKind.ball:
        final b = await _promptBall();
        if (b == null) return;
        item.ballEmoji = b.emoji;
        item.ballImagePath = b.imagePath;
        item.ballDiameter = b.diameter;
        // 以直徑同步外框 w/h
        item.w = b.diameter;
        item.h = b.diameter;

        // 隨機初速
        final r = math.Random();
        item.ballVx = (r.nextBool() ? 1 : -1) * (120 + r.nextDouble() * 140);
        item.ballVy = (r.nextBool() ? 1 : -1) * (120 + r.nextDouble() * 140);
        break;

      case ExploreKind.ad:
        break;
    }

    setState(() => _items.add(item));
    _persistSoon();
  }

  Future<String?> _promptText(String title) async {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  // 建立小球設定（emoji 或相片 + 大小）
  Future<_BallConfig?> _promptBall() async {
    final emojiCtl = TextEditingController(text: '🎈');
    double diameter = 80;
    String? imagePath;

    return showDialog<_BallConfig>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('新增小球'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emojiCtl,
                decoration: const InputDecoration(labelText: 'Emoji（留空則使用相片）'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('大小'),
                  Expanded(
                    child: Slider(
                      min: 48,
                      max: 160,
                      value: diameter,
                      onChanged: (v) => setState(() => diameter = v),
                    ),
                  ),
                  Text(diameter.toInt().toString()),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final x = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (x != null) setState(() => imagePath = x.path);
                },
                icon: const Icon(Icons.photo),
                label: Text(imagePath == null ? '選擇相片…' : '已選擇相片'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final e = emojiCtl.text.trim();
                Navigator.pop(
                  ctx,
                  _BallConfig(
                    emoji: e.isEmpty ? null : e,
                    imagePath: imagePath,
                    diameter: diameter,
                  ),
                );
              },
              child: const Text('確定'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetLayout() {
    const padding = 12.0;
    const gap = 12.0;

    final width = _canvasSize.width;
    final colW = (width - padding * 2 - gap) / 2;

    double x1 = padding;
    double x2 = padding + colW + gap;
    double y = padding + 56;

    setState(() {
      for (final it in _items) {
        if (it.kind == ExploreKind.ad || it.kind == ExploreKind.ball) continue;
        final szW = it.w, szH = it.h;
        final cardX = (x1 + (colW - szW) * 0.5)
            .clamp(8.0, width - 8.0 - szW)
            .toDouble();
        it.pos = Offset(cardX, y);
        if (x1 == padding) {
          x1 = x2;
        } else {
          x1 = padding;
          y += szH + gap;
        }
      }

      final ad = _items.firstWhere((e) => e.kind == ExploreKind.ad);
      final adSize = Size(ad.w, ad.h);
      final adX = (_canvasSize.width - adSize.width) / 2;
      final adY = (_canvasSize.height - adSize.height - padding);
      ad.pos = _clamp(Offset(adX, adY), adSize, _canvasSize);
    });
  }

  /// ===== hearts & balls =====
  void _spawnHearts(Offset center) {
    final rnd = math.Random();
    final n = 8 + rnd.nextInt(5);
    for (int i = 0; i < n; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 70 + rnd.nextDouble() * 140;
      final vx = math.cos(angle) * speed;
      final vy = math.sin(angle) * speed;
      _hearts.add(
        Heart(
          pos: center,
          vel: Offset(vx, vy),
          size: 14 + rnd.nextDouble() * 10,
          life: 1.0,
          color: Colors.pinkAccent.withOpacity(0.9 - rnd.nextDouble() * 0.2),
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (_lastTick == Duration.zero)
        ? 0.0
        : (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;
    if (dt == 0.0) return;

    // hearts
    if (_hearts.isNotEmpty) {
      const gravity = 180.0, damping = 0.75, fade = 0.5;
      for (final h in _hearts) {
        h.vel = h.vel + const Offset(0, gravity) * dt;
        var p = h.pos + h.vel * dt;
        final w = _canvasSize.width, hgt = _canvasSize.height, r = h.size;
        if (p.dx - r < 0) {
          p = Offset(r, p.dy);
          h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
        }
        if (p.dx + r > w) {
          p = Offset(w - r, p.dy);
          h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
        }
        if (p.dy - r < 0) {
          p = Offset(p.dx, r);
          h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
        }
        if (p.dy + r > hgt) {
          p = Offset(p.dx, hgt - r);
          h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
        }
        h.pos = p;
        h.life -= fade * dt;
      }
      _hearts.removeWhere((h) => h.life <= 0);
    }

    // balls
    for (final it in _items.where((e) => e.kind == ExploreKind.ball)) {
      final d = it.ballDiameter;
      var p = it.pos + Offset(it.ballVx, it.ballVy) * dt;

      const restitution = 0.9;
      const friction = 0.998;

      // 邊界（以左上角+直徑計）
      if (p.dx <= 8) {
        p = Offset(8, p.dy);
        it.ballVx = -it.ballVx * restitution;
      }
      if (p.dy <= 8) {
        p = Offset(p.dx, 8);
        it.ballVy = -it.ballVy * restitution;
      }
      if (p.dx + d >= _canvasSize.width - 8) {
        p = Offset(_canvasSize.width - 8 - d, p.dy);
        it.ballVx = -it.ballVx * restitution;
      }
      if (p.dy + d >= _canvasSize.height - 8) {
        p = Offset(p.dx, _canvasSize.height - 8 - d);
        it.ballVy = -it.ballVy * restitution;
      }

      it.pos = p;
      it.ballVx *= friction;
      it.ballVy *= friction;
    }

    if (mounted) setState(() {});
  }

  /// ===== 持久化 =====
  void _persistSoon() {
    final now = DateTime.now();
    if (_saveScheduled) return;
    final diff = now.difference(_lastSave);
    if (diff.inMilliseconds >= 300) {
      _persistNow();
    } else {
      _saveScheduled = true;
      Future.delayed(Duration(milliseconds: 300 - diff.inMilliseconds), () {
        _saveScheduled = false;
        _persistNow();
      });
    }
  }

  void _persistNow() {
    _lastSave = DateTime.now();
    ExploreStore.I.save(_items);
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: cs.primaryContainer,
        child: Icon(icon, color: cs.onPrimaryContainer),
      ),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _EmptyCenter extends StatelessWidget {
  const _EmptyCenter({required this.icon, required this.hint});
  final IconData icon;
  final String hint;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: cs.outline),
          const SizedBox(height: 8),
          Text(hint, style: TextStyle(color: cs.outline)),
        ],
      ),
    );
  }
}

/// ===== 小球元件（可拖動、長按顯示刪除、放 emoji 或相片） =====
class _BallBubble extends StatefulWidget {
  const _BallBubble({
    required this.item,
    required this.canvasSize,
    required this.onChanged,
    this.deletable = true,
    this.onDelete,
  });

  final ExploreItem item;
  final Size canvasSize;
  final VoidCallback onChanged;
  final bool deletable;
  final VoidCallback? onDelete;

  @override
  State<_BallBubble> createState() => _BallBubbleState();
}

class _BallBubbleState extends State<_BallBubble> {
  bool _dragging = false;
  bool _showTools = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final d = it.ballDiameter;

    return GestureDetector(
      onLongPress: () => setState(() => _showTools = !_showTools),
      onPanStart: (_) {
        _dragging = true;
        it.ballVx = 0;
        it.ballVy = 0;
      },
      onPanUpdate: (details) {
        final next = Offset(
          (it.pos.dx + details.delta.dx).clamp(
            8.0,
            widget.canvasSize.width - 8.0 - d,
          ),
          (it.pos.dy + details.delta.dy).clamp(
            8.0,
            widget.canvasSize.height - 8.0 - d,
          ),
        );
        setState(() => it.pos = next);
        widget.onChanged();
      },
      onPanEnd: (details) {
        _dragging = false;
        final v = details.velocity.pixelsPerSecond;
        it.ballVx = v.dx.clamp(-2000, 2000);
        it.ballVy = v.dy.clamp(-2000, 2000);
        widget.onChanged();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: _dragging ? 12 : 8,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ClipOval(child: _ballContent(it)),
            ),
          ),
          if (_showTools && widget.deletable && widget.onDelete != null)
            Positioned(
              right: 4,
              top: 4,
              child: Material(
                color: Colors.black.withOpacity(0.35),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ballContent(ExploreItem it) {
    if ((it.ballImagePath ?? '').isNotEmpty) {
      final f = File(it.ballImagePath!);
      if (f.existsSync()) {
        return Image.file(f, fit: BoxFit.cover);
      }
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: Text((it.ballEmoji ?? '🎈'), style: const TextStyle(fontSize: 64)),
    );
  }
}

class _BallConfig {
  _BallConfig({this.emoji, this.imagePath, required this.diameter});
  final String? emoji;
  final String? imagePath;
  final double diameter;
}
