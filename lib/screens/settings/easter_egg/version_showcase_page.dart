// lib/screens/easter_egg/version_showcase_page.dart
import 'dart:io' show File;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; // for Ticker / createTicker
import 'package:audioplayers/audioplayers.dart';

import '../../../models/card_item.dart';

const String kFallbackLogo = 'assets/images/pop_card_without_background.png';
const String kLogoBallAsset = 'assets/images/popcard.png';
const String kPopSfx = 'assets/audio/pop.mp3'; // 戳破音效

class VersionShowcasePage extends StatefulWidget {
  const VersionShowcasePage({
    super.key,
    required this.versionText, // 例：1.2.3+4
    required this.cards,
    this.codeName = 'Wave', // 底部顯示的版本名稱
  });

  final String versionText;
  final String codeName;
  final List<CardItem> cards;

  @override
  State<VersionShowcasePage> createState() => _VersionShowcasePageState();
}

class _VersionShowcasePageState extends State<VersionShowcasePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  Size _arena = Size.zero;
  Duration _lastTick = Duration.zero;

  final List<_FloatItem> _items = [];
  final _Sea _sea = _Sea(
    waterLine: 0.58,
    a1: 16,
    lambda1: 210,
    speed1: 0.28,
    a2: 10,
    lambda2: 120,
    speed2: 0.46,
    a3: 6,
    lambda3: 70,
    speed3: 0.63,
  );

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();

    // ✅ 第一幀後再試一次（若當下 arena OK 但 items 還是空，就補一手）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _arena != Size.zero && _items.isEmpty) {
        setState(_ensureSpawned);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final c in widget.cards) {
      precacheImage(_providerForCard(c), context);
    }
    precacheImage(const AssetImage(kFallbackLogo), context);
    precacheImage(const AssetImage(kLogoBallAsset), context);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _player.dispose();
    super.dispose();
  }

  ImageProvider _providerForCard(CardItem c) {
    if (!kIsWeb) {
      final lp = (c.localPath ?? '').trim();
      if (lp.isNotEmpty) {
        final f = File(lp);
        if (f.existsSync()) return FileImage(f);
      }
      final iu = (c.imageUrl ?? '').trim();
      if (iu.startsWith('file://')) {
        final f = File(Uri.parse(iu).toFilePath());
        if (f.existsSync()) return FileImage(f);
      }
    }
    final url = (c.imageUrl ?? '').trim();
    if (url.isNotEmpty) return NetworkImage(url);
    return const AssetImage(kFallbackLogo);
  }

  double _clamp(double v, double lo, double hi) =>
      v < lo ? lo : (v > hi ? hi : v);

  void _ensureSpawned() {
    if (_arena == Size.zero || _items.isNotEmpty) return;

    final rnd = math.Random();
    final w = _arena.width;
    final h = _arena.height;

    // 卡片／照片球
    final take = math.min(widget.cards.length, 24);
    for (int i = 0; i < take; i++) {
      final img = _providerForCard(widget.cards[i]);
      final title = widget.cards[i].title;

      final isBuoyant = rnd.nextBool();
      final size = isBuoyant
          ? (rnd.nextDouble() * 26 + 74)
          : (rnd.nextDouble() * 18 + 62);

      final x = rnd.nextDouble() * w * 0.9 + w * 0.05;
      final waterY = _sea.surfaceY(x, 0.0, h);
      final y = isBuoyant
          ? waterY - size * (0.35 + rnd.nextDouble() * 0.25)
          : (h * (0.82 + rnd.nextDouble() * 0.12));

      final vx = (rnd.nextDouble() * 10 + 4) * (rnd.nextBool() ? 1 : -1);
      final vy = (rnd.nextDouble() * 12 - 6);

      _items.add(
        _FloatItem.imageBall(
          pos: Offset(x, y),
          vel: Offset(vx, vy),
          size: size,
          isBuoyant: isBuoyant,
          image: img,
          title: title,
        ),
      );
    }

    // Logo 球
    final logoSize = _clamp(math.min(w, h) * 0.14, 72, 128);
    final lx = rnd.nextDouble() * w * 0.8 + w * 0.1;
    final ly = _sea.surfaceY(lx, 0.0, h) - logoSize * 0.45;
    _items.add(
      _FloatItem.imageBall(
        pos: Offset(lx, ly),
        vel: Offset(
          (rnd.nextDouble() * 20 + 10) * (rnd.nextBool() ? 1 : -1),
          0,
        ),
        size: logoSize,
        isBuoyant: true,
        image: const AssetImage(kLogoBallAsset),
        title: 'Logo',
      ),
    );

    // 彩蛋：鴨子／海灘球／魚／章魚
    _items.addAll([
      _FloatItem.emoji(
        emoji: '🦆',
        title: 'Duck',
        pos: Offset(w * 0.20, _sea.surfaceY(w * 0.20, 0, h) - 46),
        vel: const Offset(16, 0),
        size: 38,
        isBuoyant: true,
      ),
      _FloatItem.beachBall(
        title: 'Beach Ball',
        pos: Offset(w * 0.75, _sea.surfaceY(w * 0.75, 0, h) - 40),
        vel: const Offset(-18, 0),
        size: 42,
        isBuoyant: true,
      ),
      _FloatItem.emoji(
        emoji: '🐟',
        title: 'Fish',
        pos: Offset(w * 0.35, h * 0.78),
        vel: const Offset(22, 0),
        size: 32,
        isBuoyant: false,
      ),
      _FloatItem.emoji(
        emoji: '🐙',
        title: 'Octopus',
        pos: Offset(w * 0.60, h * 0.82),
        vel: const Offset(-18, 0),
        size: 36,
        isBuoyant: false,
      ),
    ]);
  }

  Future<void> _playPop() async {
    try {
      HapticFeedback.lightImpact();
      await _player.stop();
      await _player.play(AssetSource(kPopSfx));
    } catch (_) {
      /* 忽略音效錯誤 */
    }
  }

  void _startPop(_FloatItem item) {
    if (item.popProgress > 0) return;
    item.popProgress = 0.0001; // 啟動動畫
    _playPop();
  }

  void _tick(Duration now) {
    if (_arena == Size.zero) return;

    final dt = (_lastTick == Duration.zero)
        ? 0.016
        : (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    final w = _arena.width;
    final h = _arena.height;

    const damping = 0.992;
    const gravity = 420.0;
    const springFloat = 6.0;
    const springSink = 3.0;
    const bottomMargin = 12.0;

    final t = now.inMicroseconds / 1e6;

    for (final b in _items) {
      // 爆裂動畫
      if (b.popProgress > 0) {
        b.popProgress += dt / 0.35; // 0.35s
        if (b.popProgress >= 1.0) {
          b.isGone = true;
          continue;
        }
      }

      final vxPush = _sea.currentX(b.pos.dx, t) * (b.isBuoyant ? 0.40 : 0.18);

      double ay = 0.0;
      final ySurface = _sea.surfaceY(b.pos.dx, t, h);
      if (b.isBuoyant) {
        final target =
            ySurface - (b.size * (b.kind == _Kind.beachBall ? 0.48 : 0.42));
        ay += (target - b.pos.dy) * springFloat;
        ay += math.sin((t * 2.2) + b.hash) * 12.0;
      } else {
        final bottomY = h - bottomMargin - b.size / 2;
        final target = bottomY;
        ay += (target - b.pos.dy) * springSink;
        ay += math.sin((t * 1.3) + b.hash * 0.7) * 6.0;
        ay += gravity;
      }

      b.vel = Offset(
        (b.vel.dx + vxPush) * damping,
        (b.vel.dy + ay * dt) * damping,
      );
      var newX = b.pos.dx + b.vel.dx * dt;
      var newY = b.pos.dy + b.vel.dy * dt;

      final r = b.size / 2;
      if (newX - r < 0) {
        newX = r;
        b.vel = Offset(-b.vel.dx * 0.9, b.vel.dy);
      } else if (newX + r > w) {
        newX = w - r;
        b.vel = Offset(-b.vel.dx * 0.9, b.vel.dy);
      }
      if (newY - r < 0) {
        newY = r;
        b.vel = Offset(b.vel.dx, -b.vel.dy * 0.5);
      } else if (newY + r > h) {
        newY = h - r;
        b.vel = Offset(b.vel.dx, -b.vel.dy * 0.6);
      }

      b.pos = Offset(newX, newY);
    }

    _items.removeWhere((e) => e.isGone);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final nowT = (_lastTick == Duration.zero)
        ? 0.0
        : _lastTick.inMicroseconds / 1e6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Easter Egg'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
      ),
      backgroundColor: isDark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF6FAFF),
      body: SizedBox.expand(
        // ✅ 確保拿到有內容的 constraints（不是 0）
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ); // ✅ 不要再扣 kToolbarHeight

            if (size != _arena) {
              _arena = size;
              _items.clear();
              _ensureSpawned(); // 立刻生一批
            }

            final base = math.min(_arena.width, _arena.height);
            final versionFontSize = _clamp(base * 0.18, 36, 128);

            return Stack(
              children: [
                // 海背景
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SeaPainter(sea: _sea, t: nowT, dark: isDark),
                  ),
                ),
                // 中央版本號
                Positioned(
                  left: 0,
                  right: 0,
                  top: _arena.height / 2 - versionFontSize * 0.8,
                  child: IgnorePointer(
                    child: Text(
                      widget.versionText.isEmpty ? '—' : widget.versionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: versionFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white : const Color(0xFF12203A),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.40 : 0.18,
                            ),
                            blurRadius: isDark ? 22 : 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 漂浮物件（可戳破）
                // 漂浮物件（可戳破）—— 用 expand 攤平成外層 Stack 的孩子
                ..._items.expand((b) {
                  final under =
                      b.pos.dy > _sea.surfaceY(b.pos.dx, nowT, _arena.height);
                  final depth = under
                      ? _clamp(
                          (b.pos.dy -
                                  _sea.surfaceY(
                                    b.pos.dx,
                                    nowT,
                                    _arena.height,
                                  )) /
                              (_arena.height * 0.4),
                          0,
                          1,
                        )
                      : 0.0;

                  final popping = b.popProgress > 0 && b.popProgress < 1.0;
                  final p = popping ? b.popProgress : 0.0;
                  final scale = popping
                      ? (1.0 + 0.2 * math.sin(p * math.pi)) * (1 - p)
                      : 1.0;
                  final opacity = popping ? (1.0 - p) : 1.0;

                  Widget child;
                  switch (b.kind) {
                    case _Kind.imageBall:
                      child = _AvatarTile(
                        image: b.image!,
                        tooltip: b.title,
                        depth: depth,
                      );
                      break;
                    case _Kind.emoji:
                      child = _EmojiTile(
                        emoji: b.emoji!,
                        size: b.size,
                        depth: depth,
                      );
                      break;
                    case _Kind.beachBall:
                      child = _BeachBallTile(size: b.size, depth: depth);
                      break;
                  }

                  child = GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _startPop(b),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 60),
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );

                  return <Widget>[
                    // ① 球本體：直接定位到外層 Stack
                    Positioned(
                      left: b.pos.dx - b.size / 2,
                      top: b.pos.dy - b.size / 2,
                      width: b.size,
                      height: b.size,
                      child: child,
                    ),

                    // ② 噴濺特效：鋪滿畫面疊在上面（可選）
                    if (popping && p > 0.05)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _SplashPainter(center: b.pos, progress: p),
                          ),
                        ),
                      ),
                  ];
                }),

                // 底部版本名稱（如 Wave）
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12 + MediaQuery.of(context).padding.bottom,
                  child: Text(
                    widget.codeName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface.withOpacity(0.85),
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                // Positioned(
                //   right: 8,
                //   bottom: 8 + MediaQuery.of(context).padding.bottom,
                //   child: Text(
                //     'arena=${_arena.width.toStringAsFixed(0)}x${_arena.height.toStringAsFixed(0)}  items=${_items.length}',
                //     style: const TextStyle(fontSize: 12, color: Colors.white70),
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/* ─────────────── 模型 ─────────────── */

enum _Kind { imageBall, emoji, beachBall }

class _FloatItem {
  _FloatItem._({
    required this.kind,
    required this.pos,
    required this.vel,
    required this.size,
    required this.isBuoyant,
    required this.title,
    this.image,
    this.emoji,
  }) : hash = math.Random().nextDouble() * math.pi * 2;

  factory _FloatItem.imageBall({
    required Offset pos,
    required Offset vel,
    required double size,
    required bool isBuoyant,
    required ImageProvider image,
    required String title,
  }) => _FloatItem._(
    kind: _Kind.imageBall,
    pos: pos,
    vel: vel,
    size: size,
    isBuoyant: isBuoyant,
    title: title,
    image: image,
  );

  factory _FloatItem.emoji({
    required String emoji,
    required String title,
    required Offset pos,
    required Offset vel,
    required double size,
    required bool isBuoyant,
  }) => _FloatItem._(
    kind: _Kind.emoji,
    pos: pos,
    vel: vel,
    size: size,
    isBuoyant: isBuoyant,
    title: title,
    emoji: emoji,
  );

  factory _FloatItem.beachBall({
    required String title,
    required Offset pos,
    required Offset vel,
    required double size,
    required bool isBuoyant,
  }) => _FloatItem._(
    kind: _Kind.beachBall,
    pos: pos,
    vel: vel,
    size: size,
    isBuoyant: isBuoyant,
    title: title,
  );

  final _Kind kind;
  Offset pos;
  Offset vel;
  double size;
  bool isBuoyant;
  String title;

  ImageProvider? image; // imageBall 用
  String? emoji; // emoji 用

  final double hash;

  double popProgress = 0.0; // 0 未開始；0~1 動畫；>1 消失
  bool isGone = false;
}

/* ─────────────── 海面/波浪背景 ─────────────── */

class _Sea {
  _Sea({
    required this.waterLine,
    required this.a1,
    required this.lambda1,
    required this.speed1,
    required this.a2,
    required this.lambda2,
    required this.speed2,
    required this.a3,
    required this.lambda3,
    required this.speed3,
  });

  final double waterLine;
  final double a1, lambda1, speed1;
  final double a2, lambda2, speed2;
  final double a3, lambda3, speed3;

  double surfaceY(double x, double t, double h) {
    final base = h * waterLine;
    final y =
        base +
        a1 * math.sin((x / lambda1) * 2 * math.pi + t * speed1 * 2 * math.pi) +
        a2 *
            math.sin(
              (x / lambda2) * 2 * math.pi + t * speed2 * 2 * math.pi + 1.2,
            ) +
        a3 *
            math.sin(
              (x / lambda3) * 2 * math.pi + t * speed3 * 2 * math.pi + 2.4,
            );
    return y;
  }

  double currentX(double x, double t) {
    final d1 =
        (2 * math.pi / lambda1) *
        math.cos((x / lambda1) * 2 * math.pi + t * speed1 * 2 * math.pi);
    final d2 =
        (2 * math.pi / lambda2) *
        math.cos((x / lambda2) * 2 * math.pi + t * speed2 * 2 * math.pi + 1.2);
    final d3 =
        (2 * math.pi / lambda3) *
        math.cos((x / lambda3) * 2 * math.pi + t * speed3 * 2 * math.pi + 2.4);
    return 38.0 * (d1 * a1 + d2 * a2 + d3 * a3);
  }
}

class _SeaPainter extends CustomPainter {
  _SeaPainter({required this.sea, required this.t, required this.dark});
  final _Sea sea;
  final double t;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final sky = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? [const Color(0xFF0B1020), const Color(0xFF101A34)]
          : [const Color(0xFFEAF3FF), const Color(0xFFCFE3FF)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Offset.zero & size, Paint()..shader = sky);

    final seaTop = dark ? const Color(0xFF14305C) : const Color(0xFF4FA3FF);
    final seaBot = dark ? const Color(0xFF0D1E3B) : const Color(0xFF0F5EA8);
    final seaShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [seaTop, seaBot],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(
      Offset(0, h * sea.waterLine) & Size(w, h * (1 - sea.waterLine)),
      Paint()..shader = seaShader,
    );

    void drawWave({
      required double amp,
      required double lambda,
      required double phase,
      required Color color,
      required double yOffset,
    }) {
      final path = Path();
      final y0 = sea.surfaceY(0, t, h) + yOffset;
      path.moveTo(0, h);
      path.lineTo(0, y0);
      for (double x = 0; x <= w; x++) {
        final y =
            sea.surfaceY(x, t + phase, h) +
            yOffset +
            amp * math.sin((x / lambda) * 2 * math.pi + t * 1.2 + phase);
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    drawWave(
      amp: 4,
      lambda: 180,
      phase: 0.0,
      yOffset: -2,
      color: Colors.white.withOpacity(dark ? 0.07 : 0.10),
    );
    drawWave(
      amp: 8,
      lambda: 240,
      phase: 0.35,
      yOffset: 4,
      color: (dark ? Colors.white : Colors.black).withOpacity(
        dark ? 0.05 : 0.04,
      ),
    );
    drawWave(
      amp: 14,
      lambda: 320,
      phase: 0.7,
      yOffset: 10,
      color: Colors.black.withOpacity(dark ? 0.16 : 0.08),
    );

    final rnd = math.Random(7);
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(dark ? 0.08 : 0.10);
    for (int i = 0; i < 36; i++) {
      final bx = rnd.nextDouble() * w;
      final by = sea.surfaceY(bx, t, h) + 12 + rnd.nextDouble() * (h * 0.36);
      final r = 1 + (i % 3);
      canvas.drawCircle(
        Offset(bx, by + math.sin((t + i) * 0.6) * 3),
        r.toDouble(),
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeaPainter old) =>
      old.t != t || old.dark != dark;
}

/* ─────────────── 漂浮物件繪製 ─────────────── */

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.image, this.tooltip, this.depth = 0.0});

  final ImageProvider image;
  final String? tooltip;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.outlineVariant.withOpacity(0.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: image,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Colors.black12),
          ),
          if (depth > 0)
            Container(
              color: const Color(0xFF1273DE).withOpacity(0.18 + depth * 0.32),
            ),
        ],
      ),
    );
    return tooltip == null ? avatar : Tooltip(message: tooltip!, child: avatar);
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.emoji, required this.size, this.depth = 0.0});
  final String emoji;
  final double size;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final child = Text(emoji, style: TextStyle(fontSize: size));
    if (depth <= 0) return Center(child: child);
    return Center(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          const Color(0xFF1273DE).withOpacity(0.18 + depth * 0.32),
          BlendMode.srcATop,
        ),
        child: child,
      ),
    );
  }
}

class _BeachBallTile extends StatelessWidget {
  const _BeachBallTile({required this.size, this.depth = 0.0});
  final double size;
  final double depth;

  @override
  Widget build(BuildContext context) {
    final ball = CustomPaint(
      size: Size.square(size),
      painter: _BeachBallPainter(),
    );
    if (depth <= 0) return ball;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        const Color(0xFF1273DE).withOpacity(0.18 + depth * 0.32),
        BlendMode.srcATop,
      ),
      child: ball,
    );
  }
}

class _BeachBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center, r * .9, shadowPaint);

    final slices = <Color>[
      const Color(0xFFE53935), // red
      const Color(0xFFFFEB3B), // yellow
      const Color(0xFF1E88E5), // blue
      const Color(0xFFFFFFFF), // white
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      paint.color = slices[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r * .9),
        i * (math.pi / 2),
        math.pi / 2,
        true,
        paint,
      );
    }

    final hl = Paint()..color = Colors.white.withOpacity(.85);
    canvas.drawCircle(center, r * .18, hl);
  }

  @override
  bool shouldRepaint(covariant _BeachBallPainter oldDelegate) => false;
}

/* ─────────────── 戳破／碎片噴濺 ─────────────── */

class _SplashPainter extends CustomPainter {
  _SplashPainter({required this.center, required this.progress});
  final Offset center;
  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final rnd = math.Random(13);
    final count = 16;
    final radius = 6.0 + progress * 36.0;
    final fade = (1.0 - progress).clamp(0.0, 1.0);
    final paint = Paint()..color = Colors.white.withOpacity(0.9 * fade);

    for (int i = 0; i < count; i++) {
      final ang = (2 * math.pi * i / count) + rnd.nextDouble() * 0.2;
      final dist = radius * (0.6 + rnd.nextDouble() * 0.6);
      final r = 1.2 + (i % 3) * 0.6;
      final p = center + Offset(math.cos(ang) * dist, math.sin(ang) * dist);
      canvas.drawCircle(p, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.progress != progress;
}
