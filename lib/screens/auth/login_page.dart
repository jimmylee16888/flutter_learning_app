// lib/screens/auth/login_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // for Ticker
import 'package:flutter_learning_app/services/auth/auth_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../app_settings.dart'; // ← 依你的實際路徑調整
import '../../l10n/l10n.dart';
import '../explore/grid_paper.dart';
import '../auth/ensure_profile.dart'; // ← 新增：登入後補齊暱稱/生日

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth, required this.settings});
  final AuthController auth;
  final AppSettings settings;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _versionText = '';

  // connectivity_plus 6.x：Stream<List<ConnectivityResult>>
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _initConnectivityWatcher();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _versionText = 'v${info.version}+${info.buildNumber}');
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionText = 'v—');
    }
  }

  Future<void> _initConnectivityWatcher() async {
    final first = await Connectivity()
        .checkConnectivity(); // List<ConnectivityResult>
    _applyConnectivity(first);

    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      _applyConnectivity(results);
    });
  }

  void _applyConnectivity(List<ConnectivityResult> results) {
    final offline = results.contains(ConnectivityResult.none);
    if (mounted && offline != _isOffline) {
      setState(() => _isOffline = offline);
    }
  }

  Future<void> _showLanguagePicker() async {
    final l = context.l10n;
    Locale? selected = widget.settings.locale;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(l.language),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<Locale?>(
                    value: null,
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: Text(l.languageSystem),
                  ),
                  const SizedBox(height: 4),
                  RadioListTile<Locale?>(
                    value: const Locale('en'),
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: const Text('English'),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('zh'),
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: const Text('中文（繁體）'),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('ja'),
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: const Text('日本語'),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('ko'),
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: const Text('한국어'),
                  ),
                  RadioListTile<Locale?>(
                    value: const Locale('de'),
                    groupValue: selected,
                    onChanged: (v) => setStateDialog(() => selected = v),
                    title: const Text('Deutsch'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () {
                  widget.settings.setLocale(selected); // null = 跟系統
                  Navigator.pop(dialogCtx);
                },
                child: Text(l.save),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.auth;
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final playArea = constraints.biggest;

        return Scaffold(
          body: Stack(
            children: [
              // 背景格線
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPaperPainter(
                    color: cs.outlineVariant.withOpacity(0.18),
                  ),
                ),
              ),

              // 內容
              SafeArea(
                child: Column(
                  children: [
                    // 語言按鈕
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Material(
                            color: cs.primary.withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _showLanguagePicker,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.language, color: cs.primary),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // 登入卡片
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  l.welcomeTitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l.welcomeSubtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),

                                // Google 登入（離線或載入中則停用）
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.login),
                                    label: Text(l.authSignInWithGoogle),
                                    onPressed: (_isOffline || auth.isLoading)
                                        ? null
                                        : () async {
                                            // ✅ 解構 (ok, reason)
                                            final (ok, reason) = await auth
                                                .loginWithGoogle();
                                            if (!mounted) return;

                                            if (!ok) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '登入失敗：${reason ?? l.errorLoginFailed}',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              await ensureProfile(
                                                context,
                                                widget.settings,
                                              );
                                              if (!mounted) return;
                                              _goHome();
                                            }
                                          },
                                  ),
                                ),

                                if (auth.isLoading) ...[
                                  const SizedBox(height: 12),
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ],

                                // ===== 離線：使用上次登入帳號繼續 =====
                                if (_isOffline && auth.canOfflineSignIn) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.wifi_off, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        '目前離線，可先用上次帳號離線進入，恢復網路後再登入同步。',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: FilledButton.icon(
                                      icon: const Icon(Icons.person),
                                      label: Text(
                                        '離線繼續（${auth.lastEmail ?? "上次帳號"}）',
                                      ),
                                      onPressed: auth.isLoading
                                          ? null
                                          : () async {
                                              final ok = await auth
                                                  .continueOfflineWithLastUser();
                                              if (!mounted) return; // ← 先確認還在
                                              if (ok) {
                                                await ensureProfile(
                                                  context,
                                                  widget.settings,
                                                );
                                                if (!mounted)
                                                  return; // ← ★ 再檢查一次
                                                _goHome();
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      '沒有可用的上次登入帳號',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                    ),
                                  ),
                                ],

                                // 若離線且沒有快取帳號，給個提示
                                if (_isOffline && !auth.canOfflineSignIn) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.info_outline, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        '目前離線，且沒有上次登入紀錄。請連網後以 Google 登入。',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 版本
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _versionText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== 可拖曳 + 反彈的小球們 =====
              _BouncingBall(
                playArea: playArea,
                size: 96,
                margin: 12,
                initialOffset: Offset(playArea.width * 0.5 - 48, 180),
                initialVelocity: const Offset(180, 140),
                child: const _CircleImage(
                  'assets/images/pop_card_without_background.png',
                ),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 64,
                margin: 12,
                initialOffset: const Offset(40, 120),
                initialVelocity: const Offset(220, 160),
                child: const _CircleIcon(Icons.credit_card, size: 28),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 56,
                margin: 12,
                initialOffset: Offset(playArea.width - 120, 140),
                initialVelocity: const Offset(-160, 180),
                child: const _CircleIcon(Icons.star_rounded, size: 26),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 52,
                margin: 12,
                initialOffset: const Offset(80, 260),
                initialVelocity: const Offset(150, -130),
                child: const _CircleIcon(Icons.favorite_rounded, size: 24),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 60,
                margin: 12,
                initialOffset: Offset(playArea.width - 90, 260),
                initialVelocity: const Offset(-180, -120),
                child: const _CircleIcon(Icons.style, size: 26),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goHome() {
    if (!mounted) return;
    // 依你的路由調整
    // Navigator.of(context).pushReplacementNamed('/home');
  }
}

// ===== 小球們（原樣保留） =====

class _BouncingBall extends StatefulWidget {
  const _BouncingBall({
    required this.playArea,
    required this.size,
    required this.child,
    this.margin = 12,
    this.initialOffset,
    this.initialVelocity = const Offset(0, 0),
  });

  final Size playArea;
  final double size;
  final double margin;
  final Offset? initialOffset;
  final Offset initialVelocity;
  final Widget child;

  @override
  State<_BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<_BouncingBall>
    with SingleTickerProviderStateMixin {
  late Offset _pos; // 左上角位置
  late Offset _vel; // px/s
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  static const double _restitution = 0.88; // 反彈係數
  static const double _friction = 0.995; // 阻力
  static const double _minSpeed = 10; // 停止閾值
  static const double _maxLaunchSpeed = 2000;

  Rect get _bounds => Rect.fromLTWH(
    widget.margin,
    widget.margin,
    widget.playArea.width - widget.size - widget.margin * 2,
    widget.playArea.height - widget.size - widget.margin * 2,
  );

  @override
  void initState() {
    super.initState();
    _pos =
        widget.initialOffset ??
        Offset(widget.playArea.width * 0.5 - widget.size / 2, 140);
    _vel = widget.initialVelocity;

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      if (dt <= 0) return;
      if (_vel.distance > _minSpeed) _step(dt);
    })..start();
  }

  void _step(double dt) {
    var next = _pos + _vel * dt;
    double vx = _vel.dx, vy = _vel.dy;

    if (next.dx <= _bounds.left) {
      next = Offset(_bounds.left, next.dy);
      vx = -vx * _restitution;
    } else if (next.dx >= _bounds.right) {
      next = Offset(_bounds.right, next.dy);
      vx = -vx * _restitution;
    }
    if (next.dy <= _bounds.top) {
      next = Offset(next.dx, _bounds.top);
      vy = -vy * _restitution;
    } else if (next.dy >= _bounds.bottom) {
      next = Offset(next.dx, _bounds.bottom);
      vy = -vy * _restitution;
    }

    vx *= _friction;
    vy *= _friction;

    setState(() {
      _pos = next;
      _vel = Offset(vx, vy);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (_) => _vel = Offset.zero,
        onPanUpdate: (d) {
          var next = _pos + d.delta;
          next = Offset(
            next.dx.clamp(_bounds.left, _bounds.right),
            next.dy.clamp(_bounds.top, _bounds.bottom),
          );
          setState(() => _pos = next);
        },
        onPanEnd: (d) {
          final v = d.velocity.pixelsPerSecond;
          final scale = (_maxLaunchSpeed / (v.distance == 0 ? 1 : v.distance))
              .clamp(0.0, 1.0);
          _vel = v * scale;
        },
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 8,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ClipOval(child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon(this.icon, {this.size = 24});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _CircleImage extends StatelessWidget {
  const _CircleImage(this.assetPath);
  final String assetPath;
  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, fit: BoxFit.contain);
  }
}
