// lib/screens/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // for Ticker
import 'package:package_info_plus/package_info_plus.dart';

import '../../services/auth_controller.dart';
import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import '../explore/grid_paper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth, required this.settings});
  final AuthController auth;
  final AppSettings settings;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _versionText = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _versionText = 'v${info.version}+${info.buildNumber}');
    } catch (_) {
      setState(() => _versionText = 'v—');
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

                    // 登入卡片（只留 Google 登入）
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
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.login),
                                    label: Text(l.authSignInWithGoogle),
                                    onPressed: auth.isLoading
                                        ? null
                                        : () async {
                                            final ok = await auth
                                                .loginWithGoogle();
                                            if (!mounted) return;
                                            if (!ok) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l.errorLoginFailed,
                                                  ),
                                                ),
                                              );
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
              // 主 LOGO（初始更靠下一點）
              _BouncingBall(
                playArea: playArea,
                size: 96,
                margin: 12,
                initialOffset: Offset(playArea.width * 0.5 - 48, 180),
                initialVelocity: const Offset(180, 140),
                child: _CircleImage(
                  'assets/images/pop_card_without_background.png',
                ),
              ),
              // 其它五顆：不同 icon / 尺寸 / 初速
              _BouncingBall(
                playArea: playArea,
                size: 64,
                margin: 12,
                initialOffset: const Offset(40, 120),
                initialVelocity: const Offset(220, 160),
                child: _CircleIcon(Icons.credit_card, size: 28),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 56,
                margin: 12,
                initialOffset: Offset(playArea.width - 120, 140),
                initialVelocity: const Offset(-160, 180),
                child: _CircleIcon(Icons.star_rounded, size: 26),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 52,
                margin: 12,
                initialOffset: const Offset(80, 260),
                initialVelocity: const Offset(150, -130),
                child: _CircleIcon(Icons.favorite_rounded, size: 24),
              ),
              _BouncingBall(
                playArea: playArea,
                size: 60,
                margin: 12,
                initialOffset: Offset(playArea.width - 90, 260),
                initialVelocity: const Offset(-180, -120),
                child: _CircleIcon(Icons.style, size: 26),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 通用：可拖曳、碰邊反彈的小球
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

/// ----- 小球內容：Icon 版 -----
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

/// ----- 小球內容：圖片版（主 LOGO） -----
class _CircleImage extends StatelessWidget {
  const _CircleImage(this.assetPath);
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, fit: BoxFit.contain);
  }
}

// // lib/screens/auth/login_page.dart
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import '../../services/auth_controller.dart';
// import '../../app_settings.dart';
// import '../../l10n/l10n.dart'; // for context.l10n
// import '../explore/grid_paper.dart'; // 背景格線

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key, required this.auth, required this.settings});
//   final AuthController auth;
//   final AppSettings settings;

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tab;

//   // Sign In
//   final _accCtl = TextEditingController();
//   final _pwCtl = TextEditingController();

//   // Sign Up
//   final _acc2Ctl = TextEditingController();
//   final _pw2Ctl = TextEditingController();
//   final _nameCtl = TextEditingController();
//   String _gender = 'male';
//   DateTime? _birthday;

//   String _versionText = '';

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//     _loadVersion();
//   }

//   Future<void> _loadVersion() async {
//     try {
//       final info = await PackageInfo.fromPlatform();
//       setState(() => _versionText = 'v${info.version}+${info.buildNumber}');
//     } catch (_) {
//       setState(() => _versionText = 'v—');
//     }
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     _accCtl.dispose();
//     _pwCtl.dispose();
//     _acc2Ctl.dispose();
//     _pw2Ctl.dispose();
//     _nameCtl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickBirthday() async {
//     final now = DateTime.now();
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime(now.year - 20),
//       firstDate: DateTime(now.year - 100, 1, 1),
//       lastDate: DateTime(now.year, now.month, now.day),
//     );
//     if (d != null) setState(() => _birthday = d);
//   }

//   Future<void> _showLanguagePicker() async {
//     final l = context.l10n;
//     Locale? selected = widget.settings.locale; // null = 跟隨系統

//     await showDialog<void>(
//       context: context,
//       builder: (_) {
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               title: Text(l.language),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   RadioListTile<Locale?>(
//                     value: null,
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text(l.languageSystem),
//                   ),
//                   RadioListTile<Locale?>(
//                     value: const Locale('en'),
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text('English'),
//                   ),
//                   RadioListTile<Locale?>(
//                     value: const Locale('zh'),
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text('中文（繁體）'),
//                   ),
//                   RadioListTile<Locale?>(
//                     value: const Locale('ja'),
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text('日本語'),
//                   ),
//                   RadioListTile<Locale?>(
//                     value: const Locale('ko'),
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text('한국어'), // ← 新增
//                   ),
//                   RadioListTile<Locale?>(
//                     value: const Locale('de'),
//                     groupValue: selected,
//                     onChanged: (v) => setStateDialog(() => selected = v),
//                     title: Text('Deutsch'), // ← 新增
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text(l.cancel),
//                 ),
//                 FilledButton(
//                   onPressed: () {
//                     widget.settings.setLocale(selected);
//                     Navigator.pop(context);
//                   },
//                   child: Text(l.save),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = widget.auth;
//     final cs = Theme.of(context).colorScheme;
//     final l = context.l10n;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // 背景：簡潔格線
//           Positioned.fill(
//             child: CustomPaint(
//               painter: GridPaperPainter(
//                 color: cs.outlineVariant.withOpacity(0.18),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Column(
//               children: [
//                 // 頂部：左側語言按鈕；右側「以訪客登入」
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   child: Row(
//                     children: [
//                       // 語言按鈕（地球 icon）
//                       Material(
//                         color: cs.primary.withOpacity(0.12),
//                         shape: const CircleBorder(),
//                         child: InkWell(
//                           customBorder: const CircleBorder(),
//                           onTap: _showLanguagePicker,
//                           child: Padding(
//                             padding: const EdgeInsets.all(10),
//                             child: Icon(Icons.language, color: cs.primary),
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: auth.isLoading
//                             ? null
//                             : () async {
//                                 await auth.continueAsGuest();
//                               },
//                         child: Text(l.authContinueAsGuest),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Spacer(),

//                 // 中央卡：一般 Card（無毛玻璃），寬度較窄
//                 Center(
//                   child: ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 360),
//                     child: Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CircleAvatar(
//                               radius: 40,
//                               backgroundColor: cs.primaryContainer,
//                               child: Icon(
//                                 Icons.style,
//                                 size: 44,
//                                 color: cs.onPrimaryContainer,
//                               ),
//                             ),
//                             const SizedBox(height: 14),
//                             Text(
//                               l.welcomeTitle,
//                               textAlign: TextAlign.center,
//                               style: Theme.of(context).textTheme.titleLarge
//                                   ?.copyWith(fontWeight: FontWeight.w700),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               l.welcomeSubtitle,
//                               textAlign: TextAlign.center,
//                               style: Theme.of(context).textTheme.bodyMedium
//                                   ?.copyWith(color: cs.onSurfaceVariant),
//                             ),
//                             const SizedBox(height: 16),

//                             // Segmented Tab（兩側等寬）
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: cs.surfaceVariant.withOpacity(.6),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: SizedBox(
//                                 height: 44,
//                                 child: TabBar(
//                                   controller: _tab,
//                                   indicatorSize: TabBarIndicatorSize.tab,
//                                   labelPadding: EdgeInsets.zero,
//                                   dividerColor: Colors.transparent,
//                                   splashFactory: NoSplash.splashFactory,
//                                   indicator: BoxDecoration(
//                                     color: cs.primary.withOpacity(.15),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   labelColor: cs.onSurface,
//                                   unselectedLabelColor: cs.onSurfaceVariant,
//                                   tabs: [
//                                     Tab(text: l.authSignIn),
//                                     Tab(text: l.authRegister),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 14),

//                             // 依 Tab 顯示對應內容（可捲動，避免 overflow）
//                             AnimatedBuilder(
//                               animation: _tab,
//                               builder: (context, _) {
//                                 final bottomInset = MediaQuery.of(
//                                   context,
//                                 ).viewInsets.bottom;
//                                 final isLogin = _tab.index == 0;
//                                 return SingleChildScrollView(
//                                   padding: EdgeInsets.fromLTRB(
//                                     4,
//                                     4,
//                                     4,
//                                     12 + bottomInset,
//                                   ),
//                                   physics: const BouncingScrollPhysics(),
//                                   child: isLogin
//                                       ? _buildLoginForm(context, auth)
//                                       : _buildRegisterForm(context, auth),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const Spacer(),

//                 // 版本號
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Text(
//                     _versionText,
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ===== 兩個表單區塊 =====

//   Widget _buildLoginForm(BuildContext context, AuthController auth) {
//     final l = context.l10n;
//     return Column(
//       children: [
//         TextField(
//           controller: _accCtl,
//           keyboardType: TextInputType.emailAddress,
//           decoration: InputDecoration(labelText: l.authAccount),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _pwCtl,
//           obscureText: true,
//           decoration: InputDecoration(labelText: l.authPassword),
//         ),
//         const SizedBox(height: 18),
//         SizedBox(
//           width: double.infinity,
//           height: 48,
//           child: ElevatedButton(
//             onPressed: auth.isLoading
//                 ? null
//                 : () async {
//                     final ok = await auth.loginWithPassword(
//                       _accCtl.text.trim(),
//                       _pwCtl.text,
//                     );
//                     if (!mounted) return;
//                     if (!ok) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(l.errorLoginFailed)),
//                       );
//                     }
//                   },
//             child: auth.isLoading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Text(l.authSignIn),
//           ),
//         ),
//         SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           height: 48,
//           child: OutlinedButton.icon(
//             icon: const Icon(Icons.login),
//             label: Text(context.l10n.authSignInWithGoogle), // 自行加到 l10n
//             onPressed: auth.isLoading
//                 ? null
//                 : () async {
//                     final ok = await auth.loginWithGoogle();
//                     if (!mounted) return;
//                     if (!ok) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(context.l10n.errorLoginFailed)),
//                       );
//                     }
//                   },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRegisterForm(BuildContext context, AuthController auth) {
//     final l = context.l10n;
//     return Column(
//       children: [
//         TextField(
//           controller: _nameCtl,
//           decoration: InputDecoration(labelText: l.authName),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _acc2Ctl,
//           keyboardType: TextInputType.emailAddress,
//           decoration: InputDecoration(labelText: l.authAccount),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _pw2Ctl,
//           obscureText: true,
//           decoration: InputDecoration(labelText: l.authPassword),
//         ),
//         const SizedBox(height: 12),
//         DropdownButtonFormField<String>(
//           value: _gender,
//           items: [
//             DropdownMenuItem(value: 'male', child: Text(l.genderMale)),
//             DropdownMenuItem(value: 'female', child: Text(l.genderFemale)),
//             DropdownMenuItem(value: 'other', child: Text(l.genderOther)),
//           ],
//           onChanged: (v) => setState(() => _gender = v ?? 'other'),
//           decoration: InputDecoration(labelText: l.authGender),
//         ),
//         const SizedBox(height: 12),
//         ListTile(
//           contentPadding: EdgeInsets.zero,
//           title: Text(l.birthday),
//           subtitle: Text(
//             _birthday == null
//                 ? l.birthdayNotChosen
//                 : '${_birthday!.year.toString().padLeft(4, '0')}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
//           ),
//           trailing: OutlinedButton.icon(
//             onPressed: _pickBirthday,
//             icon: const Icon(Icons.cake),
//             label: Text(l.birthdayPick),
//           ),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           height: 48,
//           child: ElevatedButton(
//             onPressed: auth.isLoading
//                 ? null
//                 : () async {
//                     if (_birthday == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(l.errorPickBirthday)),
//                       );
//                       return;
//                     }
//                     final y = _birthday!.year.toString().padLeft(4, '0');
//                     final m = _birthday!.month.toString().padLeft(2, '0');
//                     final d = _birthday!.day.toString().padLeft(2, '0');
//                     final ok = await auth.registerAndLogin(
//                       acc: _acc2Ctl.text.trim(),
//                       pw: _pw2Ctl.text,
//                       name: _nameCtl.text.trim(),
//                       gender: _gender,
//                       birthday: '$y-$m-$d',
//                     );
//                     if (!mounted) return;
//                     if (!ok) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text(l.errorRegisterFailed)),
//                       );
//                     }
//                   },
//             child: auth.isLoading
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Text(l.authCreateAndSignIn),
//           ),
//         ),
//       ],
//     );
//   }
// }
