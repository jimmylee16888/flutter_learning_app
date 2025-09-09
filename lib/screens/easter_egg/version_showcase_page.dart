// lib/screens/easter_egg/version_showcase_page.dart
import 'dart:io' show File;
import 'dart:math' show pi, cos, sin, min, max, Random;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Ticker
import '../../models/card_item.dart';

const String kFallbackLogo = 'assets/images/pop_card_without_background.png';
const String kBgAsset = 'assets/images/popcard.png'; // ← 你的背景圖（相對路徑）
const double kBgOpacity = 0.14; // ← 背景透明度（調整這個數字即可 0~1）

class VersionShowcasePage extends StatefulWidget {
  const VersionShowcasePage({
    super.key,
    required this.versionText,
    required this.cards,
  });

  final String versionText; // 例：1.2.3+4
  final List<CardItem> cards; // 來源卡片（有 imageUrl / localPath）

  @override
  State<VersionShowcasePage> createState() => _VersionShowcasePageState();
}

class _VersionShowcasePageState extends State<VersionShowcasePage>
    with SingleTickerProviderStateMixin {
  final Random _rnd = Random();
  late final Ticker _ticker;

  // 場地
  Size _arena = Size.zero;

  // 球
  final List<_Ball> _balls = [];

  // 拖曳狀態
  int? _dragIndex;
  Offset? _lastDragPos;

  // 時間
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 快取所有圖片（避免首次顯示延遲）
    for (final c in widget.cards) {
      precacheImage(_providerForCard(c), context);
    }
    precacheImage(const AssetImage(kFallbackLogo), context);
    precacheImage(const AssetImage(kBgAsset), context); // ← 背景圖也快取
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ───────────────────────── helpers ─────────────────────────
  ImageProvider _providerForCard(CardItem c) {
    if (!kIsWeb) {
      final lp = c.localPath ?? '';
      if (lp.isNotEmpty) {
        final f = File(lp);
        if (f.existsSync()) return FileImage(f);
      }
      final iu = c.imageUrl ?? '';
      if (iu.isNotEmpty) {
        final uri = Uri.tryParse(iu);
        if (uri != null && uri.scheme == 'file') {
          final f = File(uri.toFilePath());
          if (f.existsSync()) return FileImage(f);
        }
      }
    }
    final url = c.imageUrl ?? '';
    if (url.isNotEmpty) return NetworkImage(url);
    return const AssetImage(kFallbackLogo);
  }

  double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  // 初始放置成光環，但給每顆隨機速度
  void _spawnIfNeeded() {
    if (_arena == Size.zero || _balls.isNotEmpty) return;

    final w = _arena.width, h = _arena.height;
    final base = min(w, h);

    // 大一點：介於 84~160（之前 72~140）
    final big = _clamp(base * 0.20, 84, 160);
    final mid = big * 0.92;
    final sml = big * 0.84;

    // 半徑
    final r1 = base * 0.32;
    final r2 = base * 0.46;
    final r3 = base * 0.60;

    final total = widget.cards.length;
    final c1 = total <= 8 ? total : min(10, total);
    final c2 = total > c1 ? min(14, total - c1) : 0;
    final c3 = total - c1 - c2;

    int idx = 0;
    void addRing(int count, double radius, double size) {
      for (int i = 0; i < count; i++) {
        final angle = (2 * pi) * (i / count) - pi / 2;
        final cx = w / 2 + radius * cos(angle);
        final cy = h / 2 + radius * sin(angle);
        final img = _providerForCard(widget.cards[idx]);
        final title = widget.cards[idx].title;
        idx++;

        // 隨機速度（雙向），避免偏左
        final vx = (_rnd.nextDouble() * 160 + 60) * (_rnd.nextBool() ? 1 : -1);
        final vy = (_rnd.nextDouble() * 160 + 60) * (_rnd.nextBool() ? 1 : -1);

        _balls.add(
          _Ball(
            pos: Offset(cx, cy),
            vel: Offset(vx, vy),
            size: size,
            image: img,
            title: title,
          ),
        );
      }
    }

    addRing(c1, r1, big);
    addRing(c2, r2, mid);
    addRing(c3, r3, sml);
  }

  void _tick(Duration now) {
    if (_arena == Size.zero) return;

    final dt = (_lastTick == Duration.zero)
        ? 0.016
        : (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    final w = _arena.width, h = _arena.height;

    const double damping = 0.999; // 極輕微阻尼，避免速度無限大
    const double bounceLoss = 0.985; // 牆面反彈稍微減速

    for (int i = 0; i < _balls.length; i++) {
      // 拖曳中的球不做物理更新
      if (_dragIndex == i) continue;

      final b = _balls[i];
      var x = b.pos.dx + b.vel.dx * dt;
      var y = b.pos.dy + b.vel.dy * dt;

      final r = b.size / 2;

      // 牆壁反彈
      if (x - r < 0) {
        x = r;
        b.vel = Offset(b.vel.dx.abs(), b.vel.dy) * bounceLoss;
      } else if (x + r > w) {
        x = w - r;
        b.vel = Offset(-b.vel.dx.abs(), b.vel.dy) * bounceLoss;
      }
      if (y - r < 0) {
        y = r;
        b.vel = Offset(b.vel.dx, b.vel.dy.abs()) * bounceLoss;
      } else if (y + r > h) {
        y = h - r;
        b.vel = Offset(b.vel.dx, -b.vel.dy.abs()) * bounceLoss;
      }

      b.pos = Offset(x, y);
      b.vel = b.vel * damping;
    }

    setState(() {});
  }

  // 找到手指按到的球（從最上層開始找）
  int? _hitTestBall(Offset p) {
    for (int i = _balls.length - 1; i >= 0; i--) {
      final b = _balls[i];
      final r = b.size / 2;
      if ((p - b.pos).distanceSquared <= r * r) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About · Version')),
      backgroundColor: color.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (size != _arena) {
            _arena = size;
            _spawnIfNeeded(); // 第一次拿到場地大小時生成球
          }

          final base = min(_arena.width, _arena.height);
          final versionFontSize = _clamp(base * 0.18, 36, 132);

          final children = <Widget>[];

          // 0) 背景圖（鋪滿 + 透明度）
          children.add(
            Positioned.fill(
              child: Opacity(
                opacity: kBgOpacity,
                child: Image.asset(
                  kBgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          );

          // 1) 所有球（可被拖曳）
          for (int i = 0; i < _balls.length; i++) {
            final b = _balls[i];
            children.add(
              Positioned(
                left: b.pos.dx - b.size / 2,
                top: b.pos.dy - b.size / 2,
                width: b.size,
                height: b.size,
                child: _AvatarTile(image: b.image, tooltip: b.title),
              ),
            );
          }

          // 2) 中央大版本號（置頂，確保易讀）
          children.add(
            Positioned(
              left: 0,
              right: 0,
              top: _arena.height / 2 - versionFontSize * 0.8,
              child: Column(
                children: [
                  Text(
                    widget.versionText.isEmpty ? '—' : widget.versionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: versionFontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: color.onSurface,
                      shadows: [
                        Shadow(
                          color: color.shadow.withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          // 3) 單一 GestureDetector 包住場地，自己 hitTest & 拖曳
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              final local = d.localPosition;
              final idx = _hitTestBall(local);
              if (idx != null) {
                setState(() {
                  _dragIndex = idx;
                  _lastDragPos = local;
                  // 拖起來時先停住
                  _balls[idx].vel = Offset.zero;
                });
              }
            },
            onPanUpdate: (d) {
              if (_dragIndex == null) return;
              final nowPos = d.localPosition;
              final idx = _dragIndex!;
              final b = _balls[idx];

              // 位置跟著手指、不可出界
              final r = b.size / 2;
              final clamped = Offset(
                _clamp(nowPos.dx, r, _arena.width - r),
                _clamp(nowPos.dy, r, _arena.height - r),
              );
              // 用 delta 近似速度（每幀很頻密就夠了）
              final delta = _lastDragPos == null
                  ? Offset.zero
                  : (clamped - _lastDragPos!);
              b.pos = clamped;
              b.vel = delta * 60.0; // 把每次手勢位移換算成每秒速度
              _lastDragPos = clamped;
              setState(() {});
            },
            onPanEnd: (_) {
              _dragIndex = null;
              _lastDragPos = null;
            },
            onPanCancel: () {
              _dragIndex = null;
              _lastDragPos = null;
            },
            child: Stack(children: children),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Widgets & Models ─────────────────────────
class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.image, this.tooltip});
  final ImageProvider image;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.outlineVariant.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image(
        image: image,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
      ),
    );

    return tooltip == null ? avatar : Tooltip(message: tooltip!, child: avatar);
  }
}

class _Ball {
  _Ball({
    required this.pos,
    required this.vel,
    required this.size,
    required this.image,
    required this.title,
  });

  Offset pos;
  Offset vel;
  double size;
  ImageProvider image;
  String title;
}
