// lib/screens/easter_egg/version_showcase_page.dart
import 'dart:io' show File;
import 'dart:math' show pi, cos, sin, min, max, Random;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Ticker
import '../../../models/card_item.dart';

const String kFallbackLogo = 'assets/images/pop_card_without_background.png';
const String kLogoBallAsset = 'assets/images/popcard.png'; // 你的 logo 球

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

  // 揮擊狀態
  Offset? _swingStart;
  Offset? _swingLast;
  DateTime? _swingLastTime;

  // 指下游標（顯示工具 icon）
  Offset? _cursorPos;
  bool _cursorVisible = false;

  // 時間
  Duration _lastTick = Duration.zero;

  // 工具（Icon 版本）
  Tool _tool = Tool.hand;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick)..start();
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

  // 初始放置成光環，並插入一顆 logo 球
  void _spawnIfNeeded() {
    if (_arena == Size.zero || _balls.isNotEmpty) return;

    final w = _arena.width, h = _arena.height;
    final base = min(w, h);

    final big = _clamp(base * 0.20, 84, 160);
    final mid = big * 0.92;
    final sml = big * 0.84;

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

        final vx = (_rnd.nextDouble() * 110 + 30) * (_rnd.nextBool() ? 1 : -1);
        final vy = (_rnd.nextDouble() * 110 + 30) * (_rnd.nextBool() ? 1 : -1);

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

    // logo 球
    final logoSize = _clamp(big * 1.05, big, big * 1.25);
    final logoOffset = Offset(
      w / 2 + _rnd.nextDouble() * 20 - 10,
      h / 2 + _rnd.nextDouble() * 20 - 10,
    );
    _balls.add(
      _Ball(
        pos: logoOffset,
        vel: Offset(
          (_rnd.nextDouble() * 70 + 25) * (_rnd.nextBool() ? 1 : -1),
          (_rnd.nextDouble() * 70 + 25) * (_rnd.nextBool() ? 1 : -1),
        ),
        size: logoSize,
        image: const AssetImage(kLogoBallAsset),
        title: 'Logo',
        isLogo: true,
      ),
    );
  }

  void _tick(Duration now) {
    if (_arena == Size.zero) return;

    final dt = (_lastTick == Duration.zero)
        ? 0.016
        : (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;

    final w = _arena.width, h = _arena.height;

    const double damping = 0.998;
    const double bounceLoss = 0.985;

    for (int i = 0; i < _balls.length; i++) {
      if (_dragIndex == i) continue;

      final b = _balls[i];
      var x = b.pos.dx + b.vel.dx * dt;
      var y = b.pos.dy + b.vel.dy * dt;

      final r = b.size / 2;

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

  // 依工具施力（Icon 版）
  void _applySwingImpulse(Offset from, Offset to) {
    final dt =
        (DateTime.now().millisecondsSinceEpoch -
            (_swingLastTime?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch)) /
        1000.0;

    final dir = (to - from);
    if (dir.distance < 2) return;

    final tool = _tool;
    final reach = tool == Tool.bat
        ? 200.0
        : (tool == Tool.spoon ? 140.0 : 100.0);
    final power = tool == Tool.bat
        ? 1600.0
        : (tool == Tool.spoon ? 1000.0 : 600.0);
    final falloff = 0.5;

    for (final b in _balls) {
      final d = (b.pos - to).distance;
      if (d <= reach) {
        final dirToBall = (b.pos - from);
        final unit = dirToBall.distance == 0
            ? const Offset(0, 0)
            : dirToBall / dirToBall.distance;

        final vGesture = dir.distance / (dt > 0 ? dt : 0.016);
        final gain = power * (1 - (d / reach)).clamp(0.0, 1.0);
        final fall = (1 - falloff) + falloff * (1 - (d / reach));
        final impulse = unit * vGesture * (gain / 7000.0) * fall;

        final mass = b.isLogo ? 1.6 : 1.0;
        b.vel += impulse / mass;
      }
    }
  }

  IconData _iconForTool(Tool t) {
    switch (t) {
      case Tool.hand:
        return Icons.pan_tool_alt;
      case Tool.spoon:
        return Icons.soup_kitchen;
      case Tool.bat:
        // 若想棒球風格可換 Icons.sports_baseball
        return Icons.sports_cricket;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About · Version'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _ToolSelector(
              value: _tool,
              onChanged: (t) => setState(() => _tool = t),
            ),
          ),
        ],
      ),
      backgroundColor: scheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (size != _arena) {
            _arena = size;
            _spawnIfNeeded();
          }

          final base = min(_arena.width, _arena.height);
          final versionFontSize = _clamp(base * 0.18, 36, 132);

          final children = <Widget>[];

          // 熔岩燈背景（依主題切換）
          children.add(
            Positioned.fill(child: _LavaLampBackground(isDark: isDark)),
          );

          // 球
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

          // 版本號
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
                      color: Theme.of(context).colorScheme.onSurface,
                      shadows: [
                        Shadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withOpacity(0.18),
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

          // 指下工具 icon（跟隨手勢位置）
          if (_cursorVisible && _cursorPos != null) {
            const double iconSize = 28;
            children.add(
              Positioned(
                left: _clamp(
                  _cursorPos!.dx - iconSize / 2,
                  0,
                  _arena.width - iconSize,
                ),
                top: _clamp(
                  _cursorPos!.dy - iconSize / 2,
                  0,
                  _arena.height - iconSize,
                ),
                width: iconSize,
                height: iconSize,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface.withOpacity(0.65),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: scheme.outlineVariant.withOpacity(0.8),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _iconForTool(_tool),
                        size: 18,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          // 手勢
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) {
              final local = d.localPosition;
              _cursorPos = local;
              _cursorVisible = true;

              final idx = _hitTestBall(local);
              if (idx != null) {
                setState(() {
                  _dragIndex = idx;
                  _lastDragPos = local;
                  _swingStart = null;
                  _swingLast = null;
                  _swingLastTime = null;
                  _balls[idx].vel = Offset.zero;
                });
              } else {
                _dragIndex = null;
                _lastDragPos = null;
                _swingStart = local;
                _swingLast = local;
                _swingLastTime = DateTime.now();
                setState(() {});
              }
            },
            onPanUpdate: (d) {
              _cursorPos = d.localPosition;

              if (_dragIndex != null) {
                final nowPos = d.localPosition;
                final idx = _dragIndex!;
                final b = _balls[idx];

                final r = b.size / 2;
                final clamped = Offset(
                  _clamp(nowPos.dx, r, _arena.width - r),
                  _clamp(nowPos.dy, r, _arena.height - r),
                );
                final delta = _lastDragPos == null
                    ? Offset.zero
                    : (clamped - _lastDragPos!);
                b.pos = clamped;
                b.vel = delta * 60.0;
                _lastDragPos = clamped;
                setState(() {});
              } else if (_swingStart != null) {
                _swingLast = d.localPosition;
                _swingLastTime = DateTime.now();
                setState(() {});
              } else {
                setState(() {}); // 僅更新游標位置
              }
            },
            onPanEnd: (_) {
              if (_dragIndex == null &&
                  _swingStart != null &&
                  _swingLast != null) {
                _applySwingImpulse(_swingStart!, _swingLast!);
              }
              _dragIndex = null;
              _lastDragPos = null;
              _swingStart = null;
              _swingLast = null;
              _swingLastTime = null;

              _cursorVisible = false;
              _cursorPos = null;
              setState(() {});
            },
            onPanCancel: () {
              _dragIndex = null;
              _lastDragPos = null;
              _swingStart = null;
              _swingLast = null;
              _swingLastTime = null;

              _cursorVisible = false;
              _cursorPos = null;
              setState(() {});
            },
            child: Stack(children: children),
          );
        },
      ),
    );
  }
}

// ───────────────────────── 工具 UI（Icon 版） ─────────────────────────
enum Tool { hand, spoon, bat }

class _ToolSelector extends StatelessWidget {
  const _ToolSelector({required this.value, required this.onChanged});

  final Tool value;
  final ValueChanged<Tool> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, Tool tool})>[
      (icon: Icons.pan_tool_alt, label: 'Hand', tool: Tool.hand),
      (icon: Icons.soup_kitchen, label: 'Spoon', tool: Tool.spoon),
      (icon: Icons.sports_cricket, label: 'Bat', tool: Tool.bat),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          for (final it in items)
            _ToolChip(
              icon: it.icon,
              label: it.label,
              selected: value == it.tool,
              onTap: () => onChanged(it.tool),
            ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withOpacity(0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
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
    this.isLogo = false,
  });

  Offset pos;
  Offset vel;
  double size;
  ImageProvider image;
  String title;
  bool isLogo;
}

// ───────────────────────── 熔岩燈式背景（依主題變色） ─────────────────────────
class _LavaLampBackground extends StatefulWidget {
  const _LavaLampBackground({required this.isDark});
  final bool isDark;

  @override
  State<_LavaLampBackground> createState() => _LavaLampBackgroundState();
}

class _LavaLampBackgroundState extends State<_LavaLampBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    // 慢速循環：120s
    _ac =
        AnimationController(vsync: this, duration: const Duration(seconds: 120))
          ..addListener(() => setState(() {}))
          ..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _ac.value; // 0..1
    return CustomPaint(painter: _LavaPainter(t, widget.isDark));
  }
}

class _LavaPainter extends CustomPainter {
  _LavaPainter(this.t, this.isDark);
  final double t;
  final bool isDark;

  // 依主題調整基礎飽和與亮度
  Color _hsv(double phase, double satBase, double valBase) {
    // 深色主題：整體降低亮度、略降飽和；淺色主題：提高亮度、略升飽和
    final valAdj = isDark ? -0.18 : 0.02; // 淺色主題少加亮
    final satAdj = isDark ? -0.04 : 0.02; // 少一點飽和也會顯得沒那麼亮

    final hue = (isDark ? 210 : 190) + 60 * sin(2 * pi * (t + phase));
    final sat = (satBase + satAdj + 0.08 * sin(2 * pi * (t + phase * 0.7)))
        .clamp(0.0, 1.0);
    final val = (valBase + valAdj + 0.06 * cos(2 * pi * (t + phase * 0.5)))
        .clamp(0.0, 1.0);
    return HSVColor.fromAHSV(
      1.0,
      hue % 360,
      sat as double,
      val as double,
    ).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = min(w, h);

    // 背板底色
    final bg = _hsv(0.0, 0.22, 0.92);
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // 線性漸層打底（更柔和）
    final lg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _hsv(0.00, 0.26, 0.92), // 原本 0.96 → 0.92
        _hsv(0.20, 0.24, 0.90), // 原本 0.94 → 0.90
        _hsv(0.40, 0.22, 0.88), // 原本 0.92 → 0.88
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = lg);

    // 幾個緩慢移動的大圓（加法混合 + 模糊），做出熔岩燈感
    final blobs = <_Blob>[
      _Blob(
        center: Offset(
          w * (0.25 + 0.05 * sin(2 * pi * (t + 0.05))),
          h * (0.30 + 0.06 * cos(2 * pi * (t + 0.10))),
        ),
        radius: s * (0.55 + 0.02 * sin(2 * pi * (t + 0.15))),
        color: _hsv(0.10, 0.40, 0.95).withOpacity(isDark ? 0.34 : 0.42),
      ),
      _Blob(
        center: Offset(
          w * (0.72 + 0.06 * cos(2 * pi * (t + 0.20))),
          h * (0.40 + 0.05 * sin(2 * pi * (t + 0.25))),
        ),
        radius: s * (0.50 + 0.02 * cos(2 * pi * (t + 0.30))),
        color: _hsv(0.30, 0.46, 0.92).withOpacity(isDark ? 0.32 : 0.40),
      ),
      _Blob(
        center: Offset(
          w * (0.50 + 0.05 * sin(2 * pi * (t + 0.40))),
          h * (0.70 + 0.04 * cos(2 * pi * (t + 0.45))),
        ),
        radius: s * (0.60 + 0.015 * sin(2 * pi * (t + 0.50))),
        color: _hsv(0.55, 0.38, 0.90).withOpacity(isDark ? 0.30 : 0.38),
      ),
      _Blob(
        center: Offset(
          w * (0.15 + 0.04 * cos(2 * pi * (t + 0.60))),
          h * (0.78 + 0.03 * sin(2 * pi * (t + 0.65))),
        ),
        radius: s * (0.45 + 0.015 * cos(2 * pi * (t + 0.70))),
        color: _hsv(0.80, 0.42, 0.94).withOpacity(isDark ? 0.28 : 0.35),
      ),
    ];

    final blur = MaskFilter.blur(BlurStyle.normal, s * 0.06);
    final paint = Paint()
      ..blendMode = BlendMode.plus
      ..maskFilter = blur;

    for (final b in blobs) {
      canvas.drawCircle(b.center, b.radius, paint..color = b.color);
    }

    // 最上層淡淡霧感（深色時較弱）
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white.withOpacity(isDark ? 0.008 : 0.016),
    );
  }

  @override
  bool shouldRepaint(covariant _LavaPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.isDark != isDark;
}

class _Blob {
  final Offset center;
  final double radius;
  final Color color;
  const _Blob({
    required this.center,
    required this.radius,
    required this.color,
  });
}
