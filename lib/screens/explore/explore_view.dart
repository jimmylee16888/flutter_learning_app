// explore_view.dart           // 主頁(改成呼叫下面模組＋自動儲存)
// explore_item.dart           // 資料模型 + JSON 序列化
// explore_store.dart          // 持久化（讀寫 explore_items.json）
// draggable_card.dart         // 可拖曳卡片（長按顯示刪除）
// countdown_flip_card.dart    // 倒數卡(正/背翻面)
// grid_paper.dart             // 背景格線 Painter
// hearts.dart                 // 愛心資料結構 + Painter

import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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

  String? _adLocalPath;
  AdRenderInfo? _adInfo;

  // hearts
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Size _canvasSize = Size.zero;
  final List<Heart> _hearts = [];

  // 儲存去抖動
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _saveScheduled = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();

    // 初始化廣告 Provider（本地或遠端）
    AdProvider.I.initialize().then((_) {
      if (!mounted) return;
      setState(() => _adInfo = AdProvider.I.renderInfo);
    });

    // 載入保存的卡片（維持你的原流程）
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loaded = await ExploreStore.I.load();
      setState(() {
        _items
          ..clear()
          ..addAll(loaded);
        if (!_items.any((e) => e.kind == ExploreKind.ad)) {
          _items.add(
            ExploreItem(
              kind: ExploreKind.ad,
              size: 180,
              pos: const Offset(24, 120),
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
            // 長按空白處 → 噴愛心
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

                // 卡片們
                ..._items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;

                  final Size cardSize = it.kind == ExploreKind.ad
                      ? Size(it.size * 1.8, it.size * 0.9)
                      : Size.square(it.size);

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
                        _persistSoon(); // 拖曳期間去抖動儲存
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

                // 右下：新增卡片
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.add),
                    label: const Text('新增卡片'),
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
                if (info != null)
                  Image(image: info.banner, fit: BoxFit.cover)
                else
                  const SizedBox.shrink(),
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

    final size = 160.0;
    final item = ExploreItem(
      kind: kind,
      size: size,
      pos: const Offset(24, 100),
      deletable: true,
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
        if (it.kind == ExploreKind.ad) continue;
        final sz = it.size;
        final cardX = (x1 + (colW - sz) * 0.5)
            .clamp(8.0, width - 8.0 - sz)
            .toDouble();
        it.pos = Offset(cardX, y);
        if (x1 == padding) {
          x1 = x2;
        } else {
          x1 = padding;
          y += sz + gap;
        }
      }

      final ad = _items.firstWhere((e) => e.kind == ExploreKind.ad);
      final adSize = Size(ad.size * 1.8, ad.size * 0.9);
      final adX = (_canvasSize.width - adSize.width) / 2;
      final adY = (_canvasSize.height - adSize.height - padding);
      ad.pos = _clamp(Offset(adX, adY), adSize, _canvasSize);
    });
  }

  /// ===== hearts =====
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
    if (dt == 0.0 || _hearts.isEmpty) return;

    const gravity = 180.0;
    const damping = 0.75;
    const fade = 0.5;

    for (final h in _hearts) {
      h.vel = h.vel + const Offset(0, gravity) * dt;
      var newPos = h.pos + h.vel * dt;

      final w = _canvasSize.width;
      final hgt = _canvasSize.height;
      final r = h.size;
      if (newPos.dx - r < 0) {
        newPos = Offset(r, newPos.dy);
        h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
      } else if (newPos.dx + r > w) {
        newPos = Offset(w - r, newPos.dy);
        h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
      }
      if (newPos.dy - r < 0) {
        newPos = Offset(newPos.dx, r);
        h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
      } else if (newPos.dy + r > hgt) {
        newPos = Offset(newPos.dx, hgt - r);
        h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
      }

      h.pos = newPos;
      h.life -= fade * dt;
    }

    _hearts.removeWhere((h) => h.life <= 0);
    if (mounted) setState(() {});
  }

  /// ===== 持久化：去抖動 =====
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

// // lib/screens/explore/explore_view.dart
// import 'dart:io';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart'; // Ticker
// import 'package:image_picker/image_picker.dart';

// // 廣告
// import 'dart:convert'; // ← 新增（寫入 HTML 用）
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart'; // ← 新增

// enum ExploreKind { photo, quote, countdown, ad }

// class ExploreItem {
//   ExploreItem({
//     required this.kind,
//     required this.pos,
//     required this.size,
//     this.title,
//     this.quote,
//     this.imagePath,
//     this.imageUrl,
//     this.countdownDate,
//     this.deletable = true,
//     this.isBack = false, // ← 新增：是否顯示背面
//   });

//   final ExploreKind kind;
//   Offset pos;
//   final double size; // 正方形邊長；廣告會用長方形
//   String? title;
//   String? quote;
//   String? imagePath;
//   String? imageUrl;
//   DateTime? countdownDate;
//   bool deletable;
//   bool isBack; // ← 正/背面狀態
// }

// class ExploreView extends StatefulWidget {
//   const ExploreView({super.key});

//   @override
//   State<ExploreView> createState() => _ExploreViewState();
// }

// class _ExploreViewState extends State<ExploreView>
//     with SingleTickerProviderStateMixin {
//   final List<ExploreItem> _items = [];
//   final _canvasKey = GlobalKey();

//   String? _adLocalPath; // ← 新增：本地廣告檔路徑

//   // hearts
//   late final Ticker _ticker;
//   Duration _lastTick = Duration.zero;
//   Size _canvasSize = Size.zero;
//   final List<_Heart> _hearts = [];

//   @override
//   void initState() {
//     super.initState();

//     // 先放入廣告（不可刪）
//     _items.add(
//       ExploreItem(
//         kind: ExploreKind.ad,
//         size: 180,
//         pos: const Offset(24, 120),
//         deletable: false,
//       ),
//     );

//     _prepareLocalAdFile(); // ← 新增：建立/準備本地檔
//     _ticker = createTicker(_onTick)..start();
//   }

//   Future<void> _prepareLocalAdFile() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/ad_page.html');

//     if (!await file.exists()) {
//       const html = '''
// <!doctype html>
// <html lang="zh-Hant">
// <head>
//   <meta charset="utf-8" />
//   <meta name="viewport" content="width=device-width,initial-scale=1" />
//   <title>工程師需要你的拯救｜PCARD</title>

//   <!-- 美觀字體（可選，有網路時會載入；離線則用系統字體） -->
//   <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;600;800&family=Zhi+Mang+Xing&display=swap" rel="stylesheet">

//   <meta name="description" content="工程師需要你的拯救，為你的商品無情工商。小額贊助、聯絡合作，一鍵完成。">
//   <meta property="og:title" content="工程師需要你的拯救｜PCARD">
//   <meta property="og:description" content="小額贊助我們，完成更好作品。為你的商品無情工商。">
//   <meta property="og:type" content="website">

//   <style>
//     :root{
//       --bg1: #ffe8b5;
//       --bg2: #f8c7ff;
//       --ink: #222;
//       --muted: #666;
//       --primary: #7c4dff;
//       --primary-ink: #fff;
//       --chip: rgba(0,0,0,.08);
//       --card-bg: rgba(255,255,255,.55);
//       --glass: blur(10px);
//       --radius: 18px;
//       --shadow: 0 10px 30px rgba(0,0,0,.10);
//     }
//     html,body{
//       height:100%;
//       margin:0;
//       font-family: "Noto Sans TC",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"PingFang TC","Heiti TC",sans-serif;
//       color:var(--ink);
//       background: linear-gradient(135deg,var(--bg1),var(--bg2));
//     }
//     .container{
//       min-height:100%;
//       display:flex;
//       align-items:center;
//       justify-content:center;
//       padding: 24px;
//     }
//     .hero{
//       width: min(100%, 980px);
//       display:grid;
//       grid-template-columns: 360px 1fr;
//       gap: 24px;
//       background: var(--card-bg);
//       backdrop-filter: var(--glass);
//       border-radius: var(--radius);
//       box-shadow: var(--shadow);
//       padding: 26px;
//       position: relative;
//       overflow: hidden;
//     }
//     /* 左欄：Logo 或插圖 */
//     .brand{
//       display:flex;
//       align-items:center;
//       justify-content:center;
//       background: rgba(255,255,255,.5);
//       border-radius: calc(var(--radius) - 6px);
//       position: relative;
//     }
//     .brand img{
//       width: 70%;
//       height: auto;
//       object-fit: contain;
//       filter: drop-shadow(0 8px 18px rgba(0,0,0,.12));
//       user-select: none;
//     }
//     /* 右欄：文案 */
//     .copy{
//       display:flex;
//       flex-direction:column;
//       gap: 14px;
//       padding: 4px 6px;
//     }
//     .kicker{
//       display:inline-flex;
//       align-items:center;
//       gap: 8px;
//       padding: 6px 10px;
//       border-radius: 999px;
//       background: var(--chip);
//       width: fit-content;
//       font-weight: 600;
//       color: #333;
//     }
//     h1{
//       margin: 4px 0 0 0;
//       font-weight: 800;
//       font-size: clamp(24px, 4.6vw, 48px);
//       line-height: 1.12;
//       letter-spacing: .5px;
//     }
//     .sub{
//       margin: 0;
//       color: var(--muted);
//       font-size: 14px;
//     }
//     .slogan{
//       margin: 6px 0 0 0;
//       font-family: "Zhi Mang Xing","Noto Sans TC",cursive;
//       font-size: clamp(20px, 3.4vw, 36px);
//       color: #b55a13;
//       text-shadow: 0 3px 10px rgba(0,0,0,.05);
//     }
//     .cta{
//       display:flex;
//       gap: 12px;
//       margin-top: 10px;
//       flex-wrap: wrap;
//     }
//     .btn{
//       appearance:none;
//       border:0;
//       padding: 12px 18px;
//       border-radius: 999px;
//       font-weight: 700;
//       cursor:pointer;
//       box-shadow: var(--shadow);
//       transition: transform .08s ease, box-shadow .2s ease, opacity .2s ease;
//       text-decoration:none;
//       display:inline-flex;
//       align-items:center;
//       gap:10px;
//     }
//     .btn.primary{
//       background: var(--primary);
//       color: var(--primary-ink);
//     }
//     .btn.ghost{
//       background: rgba(255,255,255,.75);
//       color:#333;
//     }
//     .btn:hover{ transform: translateY(-1px); }
//     .btn:active{ transform: translateY(0); box-shadow: 0 5px 18px rgba(0,0,0,.10); }

//     /* 浮動愛心（純裝飾） */
//     .heart{
//       position:absolute;
//       width: 14px; height: 14px;
//       left: var(--x); top: var(--y);
//       transform: translate(-50%,-50%) scale(0);
//       animation: pop 2.6s ease-out forwards;
//       pointer-events: none;
//       filter: drop-shadow(0 4px 10px rgba(0,0,0,.2));
//     }
//     .heart:before, .heart:after{
//       content:"";
//       position:absolute;
//       width: 14px; height: 14px;
//       background: var(--c, #ff5c93);
//       border-radius: 50%;
//       left: 7px; top: 0;
//     }
//     .heart:after{
//       left: 0; top: 7px;
//     }
//     .heart > i{
//       position:absolute; inset:0;
//       width:14px; height:14px;
//       transform: rotate(45deg);
//       background: var(--c, #ff5c93);
//       border-radius: 3px;
//     }
//     @keyframes pop{
//       0%   { transform: translate(-50%,-50%) scale(.2); opacity: 0 }
//       6%   { opacity: 1 }
//       100% { transform: translate(-50%,-240%) rotate(-12deg) scale(1.1); opacity: 0 }
//     }

//     /* 響應式 */
//     @media (max-width: 820px){
//       .hero{ grid-template-columns: 1fr; padding: 18px }
//       .brand{ min-height: 200px }
//       .brand img{ width: 46% }
//     }

//     footer{
//       position: absolute;
//       bottom: 8px; left: 0; right: 0;
//       text-align:center;
//       color: rgba(0,0,0,.45);
//       font-size: 12px;
//       pointer-events: none;
//     }
//   </style>
// </head>
// <body>

//   <div class="container" id="scene">
//     <section class="hero" id="hero">
//       <!-- 左：Logo（把 ad_logo.png 放同資料夾；沒有也沒關係） -->
//       <div class="brand" title="PCARD">
//         <img src="ad_logo.png" alt="PCARD Logo" onerror="this.style.display='none'">
//       </div>

//       <!-- 右：文案 -->
//       <div class="copy">
//         <span class="kicker">PCARD｜Fan Project</span>
//         <h1>工程師需要你的拯救</h1>
//         <p class="sub">小額贊助我們，完成更好作品・你的支持是前進的動力</p>
//         <p class="slogan">為你的商品無情工商</p>

//         <div class="cta">
//           <a class="btn primary" href="https://buymeacoffee.com/" target="_blank" rel="noopener">
//             ☕ 立即贊助
//           </a>
//           <a class="btn ghost" href="mailto:hello@pcard.app">
//             ✉️ 聯絡合作
//           </a>
//         </div>
//       </div>

//       <!-- 隨機浮動愛心（點擊大區塊可再生成） -->
//     </section>
//   </div>

//   <footer>© 2025 PCARD — Made with ♥</footer>

//   <script>
//     // 點擊畫面產生幾顆飄動的愛心（輕量級，無依賴）
//     const hero = document.getElementById('hero');
//     function spawnHearts(x,y){
//       const n = 6 + Math.floor(Math.random()*6);
//       for(let i=0;i<n;i++){
//         const h = document.createElement('div');
//         h.className = 'heart';
//         const hue = 330 + Math.random()*40; // 粉色系
//         h.style.setProperty('--x', x + (Math.random()*60-30) + 'px');
//         h.style.setProperty('--y', y + (Math.random()*40-20) + 'px');
//         const block = document.createElement('i');
//         h.appendChild(block);
//         hero.appendChild(h);
//         setTimeout(()=>h.remove(), 2600);
//       }
//     }
//     hero.addEventListener('pointerdown', (e)=>{
//       const rect = hero.getBoundingClientRect();
//       spawnHearts(e.clientX - rect.left, e.clientY - rect.top);
//     });
//   </script>
// </body>
// </html>

// ''';
//       await file.writeAsString(html, encoding: utf8);
//     }

//     if (!mounted) return;
//     setState(() => _adLocalPath = file.path);
//   }

//   @override
//   void dispose() {
//     _ticker.dispose();
//     super.dispose();
//   }

//   List<Color> get _softPalette {
//     final c = Theme.of(context).colorScheme;
//     return [
//       c.primaryContainer,
//       c.secondaryContainer,
//       c.tertiaryContainer,
//       c.surfaceVariant,
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return SafeArea(
//       child: LayoutBuilder(
//         builder: (ctx, constraints) {
//           _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

//           return GestureDetector(
//             // 長按任意空白處 → 噴愛心
//             onLongPressStart: (details) {
//               final box =
//                   _canvasKey.currentContext?.findRenderObject() as RenderBox?;
//               final local =
//                   box?.globalToLocal(details.globalPosition) ??
//                   details.localPosition;
//               _spawnHearts(local);
//             },
//             child: Stack(
//               key: _canvasKey,
//               children: [
//                 // 柔和格線背景
//                 Positioned.fill(
//                   child: CustomPaint(
//                     painter: _GridPaperPainter(
//                       color: cs.outlineVariant.withOpacity(0.18),
//                     ),
//                   ),
//                 ),

//                 // 卡片
//                 ..._items.asMap().entries.map((entry) {
//                   final i = entry.key;
//                   final it = entry.value;

//                   final Size cardSize = it.kind == ExploreKind.ad
//                       ? Size(it.size * 1.8, it.size * 0.9)
//                       : Size.square(it.size);

//                   it.pos = _clamp(it.pos, cardSize, _canvasSize);

//                   return Positioned(
//                     left: it.pos.dx,
//                     top: it.pos.dy,
//                     width: cardSize.width,
//                     height: cardSize.height,
//                     child: _DraggableCard(
//                       deletable: it.deletable,
//                       onDelete: it.deletable
//                           ? () => setState(() => _items.removeAt(i))
//                           : null,
//                       onDragUpdate: (delta) {
//                         setState(() {
//                           it.pos = _clamp(
//                             it.pos + delta,
//                             cardSize,
//                             _canvasSize,
//                           );
//                         });
//                       },
//                       child: _buildCard(it, cs),
//                     ),
//                   );
//                 }),

//                 // hearts 動畫層
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: CustomPaint(painter: _HeartsPainter(_hearts)),
//                   ),
//                 ),

//                 // 右上角：元件歸位
//                 Positioned(
//                   right: 12,
//                   top: 12,
//                   child: FloatingActionButton.small(
//                     heroTag: 'reset',
//                     tooltip: '元件歸位',
//                     onPressed: _resetLayout,
//                     child: const Icon(Icons.grid_view),
//                   ),
//                 ),

//                 // 右下角：新增卡片（不提供新增廣告）
//                 Positioned(
//                   right: 16,
//                   bottom: 16,
//                   child: FloatingActionButton.extended(
//                     icon: const Icon(Icons.add),
//                     label: const Text('新增卡片'),
//                     onPressed: _showAddSheet,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// ===== UI building =====

//   Widget _buildCard(ExploreItem it, ColorScheme cs) {
//     final bg = _softPalette[it.hashCode % _softPalette.length];
//     const radius = 20.0;

//     switch (it.kind) {
//       case ExploreKind.photo:
//         final image = _imageProviderOf(it);
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(radius),
//           child: DecoratedBox(
//             decoration: BoxDecoration(color: bg),
//             child: image == null
//                 ? _EmptyCenter(icon: Icons.photo, hint: '未選擇照片')
//                 : Image(image: image, fit: BoxFit.cover),
//           ),
//         );

//       case ExploreKind.quote:
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(radius),
//           child: Container(
//             color: bg,
//             alignment: Alignment.center,
//             padding: const EdgeInsets.all(14),
//             child: Text(
//               (it.quote ?? 'Tap 以編輯引言'),
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontStyle: FontStyle.italic,
//                 color: cs.onPrimaryContainer,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         );

//       case ExploreKind.countdown:
//         return _CountdownFlipCard(
//           item: it,
//           bg: bg,
//           radius: radius,
//           onToggle: () => setState(() => it.isBack = !it.isBack),
//         );

//       case ExploreKind.ad:
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(radius),
//           child: InkWell(
//             onTap: () async {
//               if (_adLocalPath == null) {
//                 ScaffoldMessenger.of(
//                   context,
//                 ).showSnackBar(const SnackBar(content: Text('廣告內容尚未準備完成')));
//                 return;
//               }
//               await OpenFilex.open(_adLocalPath!);
//             },
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 // 背景漸層（保底，圖片載不到時不會是空白）
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [cs.primaryContainer, cs.secondaryContainer],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
//                 // ★ 廣告圖片：全幅填滿
//                 Image.asset('assets/images/ad_banner.png', fit: BoxFit.cover),
//                 // 右上角 AD 標籤（保留）
//                 Positioned(
//                   right: 10,
//                   top: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.25),
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                     child: const Text(
//                       'AD',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//     }
//   }

//   /// ===== helpers =====

//   Offset _clamp(Offset off, Size size, Size canvas) {
//     final dx = off.dx
//         .clamp(8.0, math.max(8.0, canvas.width - 8.0 - size.width))
//         .toDouble();
//     final dy = off.dy
//         .clamp(8.0, math.max(8.0, canvas.height - 8.0 - size.height))
//         .toDouble();
//     return Offset(dx, dy);
//   }

//   ImageProvider? _imageProviderOf(ExploreItem it) {
//     if ((it.imagePath ?? '').isNotEmpty) {
//       final f = File(it.imagePath!);
//       if (f.existsSync()) return FileImage(f);
//     }
//     if ((it.imageUrl ?? '').isNotEmpty) {
//       return NetworkImage(it.imageUrl!);
//     }
//     return null;
//   }

//   Future<void> _showAddSheet() async {
//     final cs = Theme.of(context).colorScheme;
//     final kind = await showModalBottomSheet<ExploreKind>(
//       context: context,
//       showDragHandle: true,
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           child: Wrap(
//             runSpacing: 8,
//             children: [
//               _AddTile(
//                 icon: Icons.photo,
//                 label: '照片卡',
//                 onTap: () => Navigator.pop(context, ExploreKind.photo),
//               ),
//               _AddTile(
//                 icon: Icons.format_quote,
//                 label: '引言卡',
//                 onTap: () => Navigator.pop(context, ExploreKind.quote),
//               ),
//               _AddTile(
//                 icon: Icons.event,
//                 label: '生日倒數',
//                 onTap: () => Navigator.pop(context, ExploreKind.countdown),
//               ),
//               Divider(color: cs.outlineVariant),
//               ListTile(
//                 title: Text('廣告已內建', style: TextStyle(color: cs.outline)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (kind == null) return;

//     final size = 160.0;
//     final item = ExploreItem(
//       kind: kind,
//       size: size,
//       pos: const Offset(24, 100),
//       deletable: true,
//     );

//     switch (kind) {
//       case ExploreKind.photo:
//         final picker = ImagePicker();
//         final x = await picker.pickImage(source: ImageSource.gallery);
//         if (x == null) return;
//         item.imagePath = x.path;
//         break;
//       case ExploreKind.quote:
//         final text = await _promptText('輸入一句話');
//         if (text == null) return;
//         item.quote = text;
//         break;
//       case ExploreKind.countdown:
//         final t = await _promptText('偶像/事件名稱（例如：Sakura 生日）');
//         if (t == null) return;
//         final d = await showDatePicker(
//           context: context,
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//           initialDate: DateTime.now(),
//         );
//         if (d == null) return;
//         item.title = t;
//         item.countdownDate = d;
//         break;
//       case ExploreKind.ad:
//         // 不會走到
//         break;
//     }

//     setState(() => _items.add(item));
//   }

//   Future<String?> _promptText(String title) async {
//     final c = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: TextField(controller: c, autofocus: true),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(context, c.text.trim()),
//             child: const Text('確定'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _resetLayout() {
//     // 把卡片依序排成 2 欄網格（廣告保留在最後一列中央）
//     const padding = 12.0;
//     const gap = 12.0;

//     final width = _canvasSize.width;
//     final colW = (width - padding * 2 - gap) / 2;

//     double x1 = padding;
//     double x2 = padding + colW + gap;
//     double y = padding + 56; // 預留上方空隙

//     setState(() {
//       for (final it in _items) {
//         if (it.kind == ExploreKind.ad) continue;
//         final sz = it.size;
//         // 讓方卡不超出列寬
//         final cardX = (x1 + (colW - sz) * 0.5)
//             .clamp(8.0, width - 8.0 - sz)
//             .toDouble();
//         it.pos = Offset(cardX, y);
//         // 下一個位置：左右交錯
//         if (x1 == padding) {
//           x1 = x2;
//         } else {
//           x1 = padding;
//           y += sz + gap;
//         }
//       }

//       // 廣告放在底部中間
//       final ad = _items.firstWhere((e) => e.kind == ExploreKind.ad);
//       final adSize = Size(ad.size * 1.8, ad.size * 0.9);
//       final adX = (_canvasSize.width - adSize.width) / 2;
//       final adY = (_canvasSize.height - adSize.height - padding);
//       ad.pos = _clamp(Offset(adX, adY), adSize, _canvasSize);
//     });
//   }

//   /// ===== hearts =====

//   void _spawnHearts(Offset center) {
//     final rnd = math.Random();
//     // 一次 8~12 顆
//     final n = 8 + rnd.nextInt(5);
//     for (int i = 0; i < n; i++) {
//       final angle = rnd.nextDouble() * math.pi * 2;
//       final speed = 70 + rnd.nextDouble() * 140;
//       final vx = math.cos(angle) * speed;
//       final vy = math.sin(angle) * speed;

//       _hearts.add(
//         _Heart(
//           pos: center,
//           vel: Offset(vx, vy),
//           size: 14 + rnd.nextDouble() * 10,
//           life: 1.0,
//           color: Colors.pinkAccent.withOpacity(0.9 - rnd.nextDouble() * 0.2),
//         ),
//       );
//     }
//   }

//   void _onTick(Duration elapsed) {
//     final dt = (_lastTick == Duration.zero)
//         ? 0.0
//         : (elapsed - _lastTick).inMilliseconds / 1000.0;
//     _lastTick = elapsed;

//     if (dt == 0.0 || _hearts.isEmpty) return;

//     const gravity = 180.0;
//     const damping = 0.75;
//     const fade = 0.5; // 每秒生命衰減

//     for (final h in _hearts) {
//       // 速度/位置
//       h.vel = h.vel + const Offset(0, gravity) * dt;
//       var newPos = h.pos + h.vel * dt;

//       // 碰牆反彈
//       final w = _canvasSize.width;
//       final hgt = _canvasSize.height;
//       final r = h.size;
//       if (newPos.dx - r < 0) {
//         newPos = Offset(r, newPos.dy);
//         h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
//       } else if (newPos.dx + r > w) {
//         newPos = Offset(w - r, newPos.dy);
//         h.vel = Offset(-h.vel.dx * damping, h.vel.dy);
//       }
//       if (newPos.dy - r < 0) {
//         newPos = Offset(newPos.dx, r);
//         h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
//       } else if (newPos.dy + r > hgt) {
//         newPos = Offset(newPos.dx, hgt - r);
//         h.vel = Offset(h.vel.dx, -h.vel.dy * damping);
//       }

//       h.pos = newPos;
//       h.life -= fade * dt;
//     }

//     _hearts.removeWhere((h) => h.life <= 0);
//     if (mounted) setState(() {});
//   }
// }

// /// ======= 新增：可翻面的倒數卡 =======
// class _CountdownFlipCard extends StatelessWidget {
//   const _CountdownFlipCard({
//     required this.item,
//     required this.bg,
//     required this.radius,
//     required this.onToggle,
//   });

//   final ExploreItem item;
//   final Color bg;
//   final double radius;
//   final VoidCallback onToggle;

//   String _weekdayZh(int wd) {
//     const w = ['一', '二', '三', '四', '五', '六', '日'];
//     return w[(wd + 6) % 7]; // DateTime.weekday: Mon=1..Sun=7
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final d = item.countdownDate;
//     final now = DateTime.now();

//     final days = d == null
//         ? null
//         : (DateTime(
//             d.year,
//             d.month,
//             d.day,
//           ).difference(DateTime(now.year, now.month, now.day)).inDays);

//     final left = days == null ? null : days;
//     final isPast = (left ?? 0) < 0;
//     final absDays = left == null ? '—' : left!.abs().toString();

//     // 7 天內高亮
//     final urgent = (left != null && left! <= 7 && left! >= 0);
//     final accent = urgent ? cs.error : cs.primary;

//     // 背面日期文字
//     final dateText = d == null
//         ? '未設定日期'
//         : '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}（週${_weekdayZh(d.weekday)}）';

//     return GestureDetector(
//       onTap: onToggle,
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(end: item.isBack ? 1 : 0),
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeInOut,
//         builder: (context, t, _) {
//           // 0→1: 正面到背面
//           final angle = t * math.pi;
//           final isBack = angle > math.pi / 2;
//           final visible = isBack
//               ? _buildBack(context, dateText, cs)
//               : _buildFront(context, absDays, isPast, accent, cs);

//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(angle),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(radius),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: bg,
//                   gradient: isBack
//                       ? null
//                       : LinearGradient(
//                           colors: [bg, bg.withOpacity(0.85)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                 ),
//                 child: visible,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFront(
//     BuildContext context,
//     String absDays,
//     bool isPast,
//     Color accent,
//     ColorScheme cs,
//   ) {
//     // 正面：剩幾天 + 🎂 icon + 標題
//     return Stack(
//       children: [
//         // 大蛋糕水印
//         Positioned(
//           right: -6,
//           bottom: -6,
//           child: Icon(
//             Icons.cake_rounded,
//             size: 84,
//             color: cs.onPrimaryContainer.withOpacity(0.08),
//           ),
//         ),
//         // 內容
//         Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // 左上角小徽章
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Container(
//                   margin: const EdgeInsets.only(left: 10, top: 10),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: accent.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.cake_outlined, size: 16, color: accent),
//                       const SizedBox(width: 4),
//                       Text(
//                         '倒數',
//                         style: TextStyle(
//                           color: accent,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 isPast ? '已過 $absDays 天' : '剩 $absDays 天',
//                 style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                   fontWeight: FontWeight.w800,
//                   height: 0.95,
//                   color: cs.onPrimaryContainer,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 6),
//               if ((item.title ?? '').isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(
//                     item.title!,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: cs.onPrimaryContainer.withOpacity(0.9),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBack(BuildContext context, String dateText, ColorScheme cs) {
//     // 背面：日期
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.event, color: cs.onSurface.withOpacity(0.8)),
//           const SizedBox(height: 6),
//           Text(
//             dateText,
//             style: Theme.of(
//               context,
//             ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//             textAlign: TextAlign.center,
//           ),
//           if ((item.title ?? '').isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Text(
//               item.title!,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// /// 單顆愛心
// class _Heart {
//   _Heart({
//     required this.pos,
//     required this.vel,
//     required this.size,
//     required this.life,
//     required this.color,
//   });

//   Offset pos;
//   Offset vel;
//   double size;
//   double life; // 0..1
//   Color color;
// }

// class _HeartsPainter extends CustomPainter {
//   _HeartsPainter(this.hearts);

//   final List<_Heart> hearts;

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (final h in hearts) {
//       final paint = Paint()
//         ..color = h.color.withOpacity(h.life.clamp(0, 1))
//         ..style = PaintingStyle.fill;

//       final path = _heartPath(h.size);
//       canvas.save();
//       canvas.translate(h.pos.dx, h.pos.dy);
//       canvas.drawPath(path, paint);
//       canvas.restore();
//     }
//   }

//   Path _heartPath(double s) {
//     // 基準中心 (0,0)
//     final Path p = Path();
//     final double r = s / 2;
//     p.moveTo(0, r * 0.9);
//     p.cubicTo(-r * 2, -r * 0.6, -r * 0.6, -r * 2, 0, -r * 0.8);
//     p.cubicTo(r * 0.6, -r * 2, r * 2, -r * 0.6, 0, r * 0.9);
//     return p;
//   }

//   @override
//   bool shouldRepaint(covariant _HeartsPainter oldDelegate) =>
//       oldDelegate.hearts != hearts;
// }

// /// ========= 可拖動卡片（長按顯示刪除） =========

// class _DraggableCard extends StatefulWidget {
//   const _DraggableCard({
//     required this.child,
//     required this.onDragUpdate,
//     required this.deletable,
//     this.onDelete,
//   });

//   final Widget child;
//   final ValueChanged<Offset> onDragUpdate;
//   final bool deletable;
//   final VoidCallback? onDelete;

//   @override
//   State<_DraggableCard> createState() => _DraggableCardState();
// }

// class _DraggableCardState extends State<_DraggableCard> {
//   bool _showDelete = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: widget.deletable
//           ? () => setState(() => _showDelete = !_showDelete)
//           : null,
//       onPanUpdate: (d) => widget.onDragUpdate(d.delta),
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           DecoratedBox(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 12,
//                   offset: const Offset(0, 8),
//                   color: Colors.black.withOpacity(0.12),
//                 ),
//               ],
//             ),
//             child: widget.child,
//           ),
//           if (_showDelete && widget.deletable)
//             Positioned(
//               right: 6,
//               top: 6,
//               child: Material(
//                 color: Colors.black.withOpacity(0.4),
//                 borderRadius: BorderRadius.circular(999),
//                 child: InkWell(
//                   onTap: widget.onDelete,
//                   customBorder: const CircleBorder(),
//                   child: const Padding(
//                     padding: EdgeInsets.all(6),
//                     child: Icon(Icons.close, color: Colors.white, size: 18),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _AddTile extends StatelessWidget {
//   const _AddTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return ListTile(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       leading: CircleAvatar(
//         radius: 18,
//         backgroundColor: cs.primaryContainer,
//         child: Icon(icon, color: cs.onPrimaryContainer),
//       ),
//       title: Text(label),
//       onTap: onTap,
//     );
//   }
// }

// class _EmptyCenter extends StatelessWidget {
//   const _EmptyCenter({required this.icon, required this.hint});
//   final IconData icon;
//   final String hint;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 28, color: cs.outline),
//           const SizedBox(height: 8),
//           Text(hint, style: TextStyle(color: cs.outline)),
//         ],
//       ),
//     );
//   }
// }

// class _GridPaperPainter extends CustomPainter {
//   _GridPaperPainter({required this.color});
//   final Color color;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 0.6;

//     const gap = 20.0;
//     for (double x = 0; x <= size.width; x += gap) {
//       canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
//     }
//     for (double y = 0; y <= size.height; y += gap) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _GridPaperPainter oldDelegate) =>
//       oldDelegate.color != color;
// }
