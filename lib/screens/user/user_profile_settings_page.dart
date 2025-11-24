// lib/screens/settings/user_profile_settings_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert'; // 👈 新增：產生 QR JSON
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/screens/user/scan_friend_qr_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart';
import '../social/friend_cards_page.dart';
import '../social/followed_tags_page.dart';

// 產生email QR Code
import 'package:qr_flutter/qr_flutter.dart';

// 取得版本號
import 'package:package_info_plus/package_info_plus.dart';

/// 條碼固定內容：
/// "Design by LEE, PIN-FAN in Taipei" 的 UTF-8 → 16 進位字串
const String _kBarcodeHex = '4a696d6d79';

/// 護照頁底部文字
const String _kDesignSignature = 'Design by LEE, PIN-FAN in Taipei';

/// ===============================
/// 1) 護照風展示頁（進來只看到這個）
/// ===============================
class UserProfileSettingsPage extends StatefulWidget {
  const UserProfileSettingsPage({
    super.key,
    required this.settings,
    this.forceComplete = false, // 現在只留著相容用，不做強制
  });

  final AppSettings settings;
  final bool forceComplete;

  @override
  State<UserProfileSettingsPage> createState() =>
      _UserProfileSettingsPageState();
}

class _UserProfileSettingsPageState extends State<UserProfileSettingsPage> {
  DateTime? _birthday;

  String _nickname = '';
  String _emailText = '';
  String? _avatarUrl;

  String _ig = '';
  String _fb = '';
  String _line = '';
  bool _showIG = false;
  bool _showFB = false;
  bool _showLINE = false;

  bool _loading = true;
  String _versionText = 'Version'; // 初始值，避免一開始 null

  late SocialApi _api;

  // 與編輯頁使用相同的 SharedPreferences key（值要一樣）
  static const _kIG = 'user.social.instagram';
  static const _kFB = 'user.social.facebook';
  static const _kLINE = 'user.social.line';
  static const _kIG_SHOW = 'user.social.instagram.show';
  static const _kFB_SHOW = 'user.social.facebook.show';
  static const _kLINE_SHOW = 'user.social.line.show';
  static const _kAVATAR_URL = 'user.avatar.url';

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    _emailText = user?.email ?? context.l10n.accountNoInfo;

    _nickname = widget.settings.nickname?.trim().isNotEmpty == true
        ? widget.settings.nickname!.trim()
        : (user?.displayName ?? 'Me');

    _birthday = widget.settings.birthday;

    // 👇 新增：初始化 SocialApi，給 FriendCardsPage 用
    final meId = (user?.email?.toLowerCase() ?? user?.uid ?? 'u_me');
    final meName = _nickname.isNotEmpty
        ? _nickname
        : (user?.displayName ?? 'Me');
    _api = SocialApi(
      meId: meId,
      meName: meName,
      idTokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );

    _loadVersion(); // 👈 新增：讀取 app 版本
    _loadLocalProfile(); // 原本的
  }

  Future<void> _loadLocalProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final avatarLocal = prefs.getString(_kAVATAR_URL);
      final igLocal = prefs.getString(_kIG) ?? '';
      final fbLocal = prefs.getString(_kFB) ?? '';
      final lineLocal = prefs.getString(_kLINE) ?? '';
      final showIGLocal = prefs.getBool(_kIG_SHOW) ?? false;
      final showFBLocal = prefs.getBool(_kFB_SHOW) ?? false;
      final showLINELocal = prefs.getBool(_kLINE_SHOW) ?? false;

      if (!mounted) return;
      setState(() {
        _avatarUrl = avatarLocal;
        _ig = igLocal;
        _fb = fbLocal;
        _line = lineLocal;
        _showIG = showIGLocal;
        _showFB = showFBLocal;
        _showLINE = showLINELocal;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openEditPage() async {
    // 先從目前的 context 把 controller 取出來
    final tagCtrl = context.read<TagFollowController>();
    final friendCtrl = context.read<FriendFollowController>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<TagFollowController>.value(value: tagCtrl),
            ChangeNotifierProvider<FriendFollowController>.value(
              value: friendCtrl,
            ),
          ],
          child: UserProfileEditPage(
            settings: widget.settings,
            forceComplete: widget.forceComplete,
          ),
        ),
      ),
    );

    // 編輯完回來重新讀一次本機快取
    await _loadLocalProfile();
  }

  String _formatBirthday(BuildContext context) {
    if (_birthday == null) return context.l10n.birthdayPick;
    final y = _birthday!.year.toString().padLeft(4, '0');
    final m = _birthday!.month.toString().padLeft(2, '0');
    final d = _birthday!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';

    final followedTags = context.watch<TagFollowController>().followed;
    final followingIds = context.watch<FriendFollowController>().friends;

    final profileCard = _loading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: _openEditPage,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final cardWidth = width > 600 ? 480.0 : width - 32.0;

                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    width: cardWidth,
                    constraints: const BoxConstraints(minHeight: 260),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(24),
                      color: cs.surface.withOpacity(0.96),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 上半：頭像 + 名稱 + email + 生日
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: cs.surfaceVariant,
                                  foregroundImage:
                                      (_avatarUrl != null &&
                                          _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(_avatarUrl!)
                                      : null,
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nickname.isEmpty ? 'Me' : _nickname,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.mail_outlined,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              _emailText,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.cake_outlined,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatBirthday(context),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 中段：社群連結（只展示有勾選顯示 & 有內容的）
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                if (_showIG && _ig.trim().isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.camera_alt_outlined,
                                    label: _ig.trim().startsWith('@')
                                        ? _ig.trim()
                                        : '@${_ig.trim()}',
                                  ),
                                if (_showFB && _fb.trim().isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.facebook,
                                    label: _fb.trim(),
                                  ),
                                if (_showLINE && _line.trim().isNotEmpty)
                                  _SocialChip(
                                    icon: Icons.chat_bubble_outline,
                                    label: _line.trim(),
                                  ),
                                if (!(_showIG && _ig.trim().isNotEmpty) &&
                                    !(_showFB && _fb.trim().isNotEmpty) &&
                                    !(_showLINE && _line.trim().isNotEmpty))
                                  Text(
                                    l.socialLinksTitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),

                            // 下半：追蹤標籤 + 好友數
                            Row(
                              children: [
                                // 左邊：追蹤標籤
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.followedTagsCount(
                                          followedTags.length,
                                        ),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l.manageFollowedTags,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 右邊：社群好友 → 改成可點擊，進 FriendCardsPage
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      final friendCtrl = context
                                          .read<FriendFollowController>();

                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChangeNotifierProvider<
                                                FriendFollowController
                                              >.value(
                                                value: friendCtrl,
                                                child: FriendCardsPage(
                                                  api: _api,
                                                ),
                                              ),
                                        ),
                                      );

                                      // 回來後如果有變動，順便 refresh 一下
                                      if (context.mounted) {
                                        await context
                                            .read<FriendFollowController>()
                                            .refresh();
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${l.socialFriends} (${followingIds.length})',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l.manageCards,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ===== QR Code 名片卡片 =====
                            _ProfileBarcodeCard(),
                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.touch_app_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l.userProfileLongPressHint,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 中下方掃描 QR 浮動按鈕
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l.scanFriendQrButtonLabel),
        onPressed: () async {
          final friendCtrl = context.read<FriendFollowController>();

          final friendId = await Navigator.of(context).push<String>(
            MaterialPageRoute(
              builder: (_) =>
                  ChangeNotifierProvider<FriendFollowController>.value(
                    value: friendCtrl,
                    child: const ScanFriendQrPage(),
                  ),
            ),
          );

          if (friendId != null && context.mounted) {
            // ✅ 如果還沒加入，就幫你加入
            if (!friendCtrl.contains(friendId)) {
              await friendCtrl.toggle(friendId); // -> 變成「已追蹤」
              await friendCtrl.refresh(); // 可選：重新抓最新列表
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l.friendAddedStatus}: $friendId')),
            );
          }
        },
      ),

      // 沒有 AppBar，看起來像一整個海洋背景
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                // 海浪背景（參考 version_showcase_page）
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SeaProfilePainter(
                      sea: _SeaProfile(
                        waterLine: 0.62,
                        a1: 12,
                        lambda1: 220,
                        a2: 8,
                        lambda2: 140,
                        a3: 5,
                        lambda3: 80,
                      ),
                      t: 0.0,
                      dark: isDark,
                    ),
                  ),
                ),
                // 中間護照卡
                profileCard,

                // 底部版本號 + Design 字樣
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80, // 預留一點高度給 FAB
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _versionText,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _kDesignSignature,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 由外部（RootNav）在「進入本頁」時呼叫：重新從本機快取刷新展示資料
  Future<void> refreshOnEnter() async {
    await _loadLocalProfile();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      // pubspec.yaml: version: 1.2.5+20
      // info.version -> "1.2.5"
      // info.buildNumber -> "20"
      final v = info.version;
      final build = info.buildNumber;
      setState(() {
        _versionText = 'Version $v+$build';
        // 如果你只想顯示 Version 1.2.5，可以改成：
        // _versionText = 'Version $v';
      });
    } catch (_) {
      // 失敗就維持預設字串，不讓畫面炸掉
      setState(() {
        _versionText = 'Version';
      });
    }
  }
}

/// 條碼卡：縮小上下留白＋固定顯示 _kBarcodeHex
class _ProfileBarcodeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final user = FirebaseAuth.instance.currentUser;
    // QR 內容：優先 email，沒有就 uid，再不行就 'guest'
    final account = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : (user?.uid ?? 'guest');

    // 👇 新版：好友 QR JSON 格式
    final qrPayload = jsonEncode({'type': 'friend_qr_v1', 'id': account});

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 灰色卡片左右只留一點空間，幾乎吃滿整個護照卡
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: QrImageView(
              data: qrPayload, // 👈 使用 JSON payload
              version: QrVersions.auto,
              size: 140,
              backgroundColor: Colors.transparent,
              gapless: true,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: cs.onSurface,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          account,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            letterSpacing: 0.5,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

/// 簡單條碼畫法：依照 hex 字元畫出高低不同的線
/// 類超商條碼畫法：
/// - 上下幾乎滿版（可自己調整）
/// - 左右有 quiet zone
/// - 黑白相間、粗細不一，看起來像真的條碼
class _BarcodePainter extends CustomPainter {
  _BarcodePainter({required this.code});

  final String code;

  @override
  void paint(Canvas canvas, Size size) {
    if (code.trim().isEmpty) return;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 1) 把字串轉成「模組長度」序列（類似：空白1, 條2, 空白1, 條3...）
    //    這邊不是正式標準，只是用 code 產生穩定但看起來隨機的圖樣。
    final modules = <int>[];

    // 給前後留一點 quiet zone
    const quietZoneModules = 12;

    // 簡單 guard bar（開頭三條 ＋ 結尾三條），像 EAN-13 那種
    void addGuardPattern() {
      // pattern: bar, space, bar（都窄）
      modules.addAll([1, 1, 1]);
    }

    // 開頭 quiet zone
    for (int i = 0; i < quietZoneModules; i++) {
      modules.add(1); // 後面會自己在黑白切換時解讀
    }

    // 起始 guard bar
    addGuardPattern();

    // 中間主要條碼：根據每個字元產生幾個 bar/space 宽度
    final chars = code.codeUnits;
    for (final cu in chars) {
      // 取一個 0~6 的值，轉成 1~4 的寬度，避免太誇張
      final v = (cu % 7) + 1; // 1~7
      final barWidth = 1 + (v % 3); // 1~3
      final spaceWidth = 1 + ((v ~/ 2) % 2); // 1~2

      // 一組：space, bar, space, bar... 讓形狀比較豐富
      modules.addAll([
        spaceWidth,
        barWidth,
        1,
        (barWidth == 3 ? 2 : barWidth + 1),
      ]);
    }

    // 中央 guard bar（模擬 EAN 中間那條）
    addGuardPattern();

    // 結尾也加一點隨機 pattern
    for (int i = 0; i < 4; i++) {
      modules.addAll([1, 2]); // 簡單: 窄空白＋中等條
    }

    // 結尾 guard bar
    addGuardPattern();

    // 結尾 quiet zone
    for (int i = 0; i < quietZoneModules; i++) {
      modules.add(1);
    }

    // 2) 把「模組數量」轉成實際寬度
    final totalModules = modules.fold<int>(0, (sum, v) => sum + v);
    if (totalModules == 0) return;

    final moduleWidth = size.width / totalModules;

    // 條碼高度（留一點上下邊界，看起來不像整塊貼滿）
    final top = size.height * 0.05;
    final bottom = size.height * 0.95;

    double x = 0;
    bool drawBar = false; // 從空白開始：quiet zone 是空白

    for (final w in modules) {
      final dx = w * moduleWidth;

      if (drawBar) {
        final rect = Rect.fromLTRB(x, top, x + dx, bottom);
        canvas.drawRect(rect, paint);
      }

      // 黑白交錯
      drawBar = !drawBar;
      x += dx;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.code != code;
}

/// 單純展示用的小社群 Chip
class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

/* ─────────────── 海浪背景（簡化版，參考 version_showcase_page） ─────────────── */

class _SeaProfile {
  _SeaProfile({
    required this.waterLine,
    required this.a1,
    required this.lambda1,
    required this.a2,
    required this.lambda2,
    required this.a3,
    required this.lambda3,
  });

  final double waterLine;
  final double a1, lambda1;
  final double a2, lambda2;
  final double a3, lambda3;

  double surfaceY(double x, double t, double h) {
    final base = h * waterLine;
    final y =
        base +
        a1 * math.sin((x / lambda1) * 2 * math.pi + t * 2 * math.pi) +
        a2 * math.sin((x / lambda2) * 2 * math.pi + t * 3 * math.pi + 1.2) +
        a3 * math.sin((x / lambda3) * 2 * math.pi + t * 4 * math.pi + 2.4);
    return y;
  }
}

class _SeaProfilePainter extends CustomPainter {
  _SeaProfilePainter({required this.sea, required this.t, required this.dark});

  final _SeaProfile sea;
  final double t;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // 天空漸層
    final sky = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? [const Color(0xFF0B1020), const Color(0xFF101A34)]
          : [const Color(0xFFEAF8FF), const Color(0xFFE0F6FF)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Offset.zero & size, Paint()..shader = sky);

    // 海面區塊
    final seaTop = dark ? const Color(0xFF14305C) : const Color(0xFF8AD8FF);
    final seaBot = dark ? const Color(0xFF0D1E3B) : const Color(0xFF4EB3FF);
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
      final y0 = sea.surfaceY(0, t + phase, h) + yOffset;
      path.moveTo(0, h);
      path.lineTo(0, y0);
      for (double x = 0; x <= w; x++) {
        final y =
            sea.surfaceY(x, t + phase, h) +
            yOffset +
            amp * math.sin((x / lambda) * 2 * math.pi + t * 1.4 + phase);
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }

    // 幾層浪
    drawWave(
      amp: 4,
      lambda: 180,
      phase: 0.0,
      yOffset: -2,
      color: Colors.white.withOpacity(dark ? 0.08 : 0.12),
    );
    drawWave(
      amp: 9,
      lambda: 260,
      phase: 0.35,
      yOffset: 6,
      color: (dark ? Colors.white : Colors.black).withOpacity(
        dark ? 0.05 : 0.05,
      ),
    );
    drawWave(
      amp: 14,
      lambda: 340,
      phase: 0.7,
      yOffset: 12,
      color: Colors.black.withOpacity(dark ? 0.15 : 0.08),
    );

    // 小氣泡
    final rnd = math.Random(7);
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(dark ? 0.08 : 0.10);
    for (int i = 0; i < 30; i++) {
      final bx = rnd.nextDouble() * w;
      final by = sea.surfaceY(bx, t, h) + 10 + rnd.nextDouble() * (h * 0.35);
      final r = 1 + (i % 3);
      canvas.drawCircle(Offset(bx, by), r.toDouble(), bubblePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeaProfilePainter old) =>
      old.t != t || old.dark != dark || old.sea != sea;
}

/// 四角的小魚 / 蝦 / 章魚 Emoji
class _SeaCornerEmoji extends StatelessWidget {
  const _SeaCornerEmoji({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.92,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.45),
        ),
        padding: const EdgeInsets.all(6),
        child: Text(emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }
}

/// 提供給編輯頁用的背景：重用同一套海浪 + 小魚
class _SeaBackground extends StatelessWidget {
  const _SeaBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SeaProfilePainter(
                  sea: _SeaProfile(
                    waterLine: 0.62,
                    a1: 12,
                    lambda1: 220,
                    a2: 8,
                    lambda2: 140,
                    a3: 5,
                    lambda3: 80,
                  ),
                  t: 0.0,
                  dark: isDark,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ===============================
/// 2) 完整編輯頁（長按護照卡 → 進來）
///   直接沿用你原本的編輯邏輯
/// ===============================
class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({
    super.key,
    required this.settings,
    this.forceComplete = false,
  });

  final AppSettings settings;
  final bool forceComplete;

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthday; // 目前生日

  late final TextEditingController _nickCtrl;
  String _emailText = '';
  String? _avatarUrl;

  final _tagInput = TextEditingController();
  late SocialApi _api;

  // 顯示名稱快取（id -> name）
  final Map<String, String> _nameById = {};

  final _igCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _lineCtrl = TextEditingController();
  bool _showIG = false;
  bool _showFB = false;
  bool _showLINE = false;

  bool _saving = false;
  bool _loading = true;

  static const _kIG = 'user.social.instagram';
  static const _kFB = 'user.social.facebook';
  static const _kLINE = 'user.social.line';
  static const _kIG_SHOW = 'user.social.instagram.show';
  static const _kFB_SHOW = 'user.social.facebook.show';
  static const _kLINE_SHOW = 'user.social.line.show';
  static const _kAVATAR_URL = 'user.avatar.url';

  @override
  void initState() {
    super.initState();
    _nickCtrl = TextEditingController(text: widget.settings.nickname ?? '');
    _birthday = widget.settings.birthday;

    final user = FirebaseAuth.instance.currentUser;
    _emailText = user?.email ?? context.l10n.accountNoInfo;

    final meId = (user?.email?.toLowerCase() ?? user?.uid ?? 'u_me');
    final meName = (_nickCtrl.text.trim().isEmpty)
        ? (user?.displayName ?? 'Me')
        : _nickCtrl.text.trim();
    _api = SocialApi(
      meId: meId,
      meName: meName,
      idTokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );
    _bootstrap();
  }

  /// 啟動時以伺服器為準同步頭像與設定，並回寫本機快取
  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 先預設為本機快取（避免白屏）
      String? avatarLocal = prefs.getString(_kAVATAR_URL);
      String igLocal = prefs.getString(_kIG) ?? '';
      String fbLocal = prefs.getString(_kFB) ?? '';
      String lineLocal = prefs.getString(_kLINE) ?? '';
      bool showIGLocal = prefs.getBool(_kIG_SHOW) ?? false;
      bool showFBLocal = prefs.getBool(_kFB_SHOW) ?? false;
      bool showLINELocal = prefs.getBool(_kLINE_SHOW) ?? false;

      // 嘗試從雲端讀 /me，雲端為單一真相
      String? serverAvatar;
      String? serverNickname;
      String? serverIG;
      String? serverFB;
      String? serverLINE;
      bool? serverShowIG;
      bool? serverShowFB;
      bool? serverShowLINE;
      String? serverBirthday;

      try {
        final me = await _api
            .fetchMyProfile(); // { avatarUrl, nickname, instagram, ... }

        serverAvatar = (me['avatarUrl'] as String?)?.trim();
        serverNickname = (me['nickname'] as String?)?.trim();

        serverIG = (me['instagram'] as String?)?.trim();
        serverFB = (me['facebook'] as String?)?.trim();
        serverLINE = (me['lineId'] as String?)?.trim();
        serverBirthday = (me['birthday'] as String?)?.trim();

        // 後端若傳 null 就維持 null，讓下面用 ?? 回退到本機
        if (me['showInstagram'] is bool) {
          serverShowIG = me['showInstagram'] as bool;
        }
        if (me['showFacebook'] is bool) {
          serverShowFB = me['showFacebook'] as bool;
        }
        if (me['showLine'] is bool) {
          serverShowLINE = me['showLine'] as bool;
        }

        // 把雲端有值的項目同步寫回本機快取（加速下次開啟）
        if (serverAvatar != null && serverAvatar!.isNotEmpty) {
          await prefs.setString(_kAVATAR_URL, serverAvatar!);
          avatarLocal = serverAvatar;
        }
        if (serverIG != null) {
          await prefs.setString(_kIG, serverIG!);
          igLocal = serverIG!;
        }
        if (serverFB != null) {
          await prefs.setString(_kFB, serverFB!);
          fbLocal = serverFB!;
        }
        if (serverLINE != null) {
          await prefs.setString(_kLINE, serverLINE!);
          lineLocal = serverLINE!;
        }
        if (serverShowIG != null) {
          await prefs.setBool(_kIG_SHOW, serverShowIG!);
          showIGLocal = serverShowIG!;
        }
        if (serverShowFB != null) {
          await prefs.setBool(_kFB_SHOW, serverShowFB!);
          showFBLocal = serverShowFB!;
        }
        if (serverShowLINE != null) {
          await prefs.setBool(_kLINE_SHOW, serverShowLINE!);
          showLINELocal = serverShowLINE!;
        }

        // 暱稱：如果雲端有值就直接覆蓋輸入框與設定
        if (serverNickname != null && serverNickname!.isNotEmpty) {
          _nickCtrl.text = serverNickname!;
          widget.settings.setNickname(serverNickname!);
        } else if (_nickCtrl.text.trim().isEmpty &&
            widget.settings.nickname != null) {
          _nickCtrl.text = widget.settings.nickname!;
        }

        // 生日
        if (serverBirthday != null && serverBirthday!.isNotEmpty) {
          try {
            final parts = serverBirthday!.split('-').map(int.parse).toList();
            if (parts.length >= 3) {
              _birthday = DateTime(parts[0], parts[1], parts[2]);
              widget.settings.setBirthday(_birthday);
            }
          } catch (_) {
            // ignore
          }
        } else if (_birthday == null && widget.settings.birthday != null) {
          _birthday = widget.settings.birthday;
        }
      } catch (_) {
        // 雲端讀取失敗 → 沿用本機快取
      }

      if (!mounted) return;
      setState(() {
        _avatarUrl = avatarLocal;
        _igCtrl.text = igLocal;
        _fbCtrl.text = fbLocal;
        _lineCtrl.text = lineLocal;
        _showIG = showIGLocal;
        _showFB = showFBLocal;
        _showLINE = showLINELocal;
        _loading = false;
      });

      // 初次預抓好友名稱
      _prefetchFriendNames(context.read<FriendFollowController>().friends);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prefetchFriendNames(Iterable<String> ids) {
    for (final id in ids) {
      if (!_nameById.containsKey(id)) _loadFriendName(id);
    }
  }

  Future<void> _loadFriendName(String id) async {
    try {
      final p = await _api.fetchUserProfile(id);
      final name = ((p['nickname'] ?? p['name'] ?? '') as String).trim();
      if (name.isEmpty) return;
      if (!mounted) return;
      setState(() => _nameById[id] = name);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    _tagInput.dispose();
    _igCtrl.dispose();
    _fbCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nickCtrl.text.trim().isNotEmpty;

  /// 換頭像（Web 相容：用 bytes 上傳），並立即永久化（/me.avatarUrl）
  Future<void> _changeAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (picked == null) return;

      final Uint8List bytes = await picked.readAsBytes();

      // 1) 上傳到伺服器
      final uploadedUrl = await _api.uploadAvatarBytes(
        bytes,
        filename: picked.name,
      );

      // 2) 立刻更新 /me
      await _api.updateProfile(avatarUrl: uploadedUrl);

      // 3) 同步本機快取
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAVATAR_URL, uploadedUrl);

      if (!mounted) return;
      setState(() => _avatarUrl = uploadedUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.userProfileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.downloadFailed}: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_canSave) return;

    final l = context.l10n;
    setState(() => _saving = true);

    try {
      widget.settings.setNickname(_nickCtrl.text.trim());
      widget.settings.setBirthday(_birthday);

      final String? birthdayIso = _birthday == null
          ? null
          : '${_birthday!.year.toString().padLeft(4, '0')}-'
                '${_birthday!.month.toString().padLeft(2, '0')}-'
                '${_birthday!.day.toString().padLeft(2, '0')}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kIG, _igCtrl.text.trim());
      await prefs.setString(_kFB, _fbCtrl.text.trim());
      await prefs.setString(_kLINE, _lineCtrl.text.trim());
      await prefs.setBool(_kIG_SHOW, _showIG);
      await prefs.setBool(_kFB_SHOW, _showFB);
      await prefs.setBool(_kLINE_SHOW, _showLINE);

      // 從 Provider 取目前好友清單
      final following = context.read<FriendFollowController>().friends.toList();

      await _api.updateProfile(
        nickname: _nickCtrl.text.trim(),
        avatarUrl: _avatarUrl,
        instagram: _igCtrl.text.trim(),
        facebook: _fbCtrl.text.trim(),
        lineId: _lineCtrl.text.trim(),
        showInstagram: _showIG,
        showFacebook: _showFB,
        showLine: _showLINE,
        followingUserIds: following,
        birthdayIso: birthdayIso,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.userProfileSaved)));
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.previewFailed}: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addTag() async {
    final t = _tagInput.text.trim();
    if (t.isEmpty) return;
    await context.read<TagFollowController>().add(t);
    if (!mounted) return;
    _tagInput.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.addedFollowedTagToast)));
  }

  Future<void> _removeTag(String t) async {
    await context.read<TagFollowController>().remove(t);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.removedFollowedTagToast)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final followedTags = context.watch<TagFollowController>().followed;
    final followingIds = context.watch<FriendFollowController>().friends;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // ===== 基本資料卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: cs.surfaceVariant,
                                  foregroundImage:
                                      (_avatarUrl != null &&
                                          _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(_avatarUrl!)
                                      : null,
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 36,
                                  ),
                                ),
                                IconButton.filled(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.edit, size: 16),
                                  tooltip: l.changeAvatar,
                                  onPressed: _changeAvatar,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nickCtrl,
                                decoration: InputDecoration(
                                  labelText: l.nicknameLabel,
                                  hintText: 'e.g. Jenny',
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? l.nicknameRequired
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(Icons.mail_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _emailText,
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        // 生日選擇
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cake_outlined),
                            label: Text(
                              _birthday == null
                                  ? l.birthdayPick
                                  : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                            ),
                            onPressed: () async {
                              final now = DateTime.now();
                              final init =
                                  _birthday ?? DateTime(now.year - 18, 1, 1);
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: init,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(now.year + 1),
                                helpText: l.birthdayPick,
                              );
                              if (!mounted) return;
                              if (picked != null) {
                                setState(() => _birthday = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 社群連結卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.socialLinksTitle,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _igCtrl,
                        decoration: InputDecoration(
                          labelText: l.instagramLabel,
                          hintText: '@your_ig',
                          prefixIcon: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                      SwitchListTile(
                        value: _showIG,
                        onChanged: (v) => setState(() => _showIG = v),
                        title: Text(l.showInstagramOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fbCtrl,
                        decoration: InputDecoration(
                          labelText: l.facebookLabel,
                          hintText: 'fb.me/yourname',
                          prefixIcon: const Icon(Icons.facebook),
                        ),
                      ),
                      SwitchListTile(
                        value: _showFB,
                        onChanged: (v) => setState(() => _showFB = v),
                        title: Text(l.showFacebookOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _lineCtrl,
                        decoration: InputDecoration(
                          labelText: l.lineLabel,
                          hintText: 'your_line_id',
                          prefixIcon: const Icon(Icons.chat_bubble_outline),
                        ),
                      ),
                      SwitchListTile(
                        value: _showLINE,
                        onChanged: (v) => setState(() => _showLINE = v),
                        title: Text(l.showLineOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 追蹤標籤卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tag_outlined),
                          const SizedBox(width: 8),
                          Text(
                            l.followedTagsCount(followedTags.length),
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangeNotifierProvider<
                                        TagFollowController
                                      >.value(
                                        value: context
                                            .read<TagFollowController>(),
                                        child: FollowedTagsPage(api: _api),
                                      ),
                                ),
                              );
                              await context
                                  .read<TagFollowController>()
                                  .refresh();
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l.manageFollowedTags),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagInput,
                              decoration: InputDecoration(
                                labelText: l.addFollowedTag,
                                hintText: l.addFollowedTagHint,
                                prefixIcon: const Icon(Icons.add),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: _addTag,
                            child: Text(l.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: [
                          for (final t in followedTags)
                            InputChip(
                              label: Text('#$t'),
                              onDeleted: () => _removeTag(t),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 已加入好友卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline),
                          const SizedBox(width: 8),
                          Text(
                            '${l.socialFriends} (${followingIds.length})',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangeNotifierProvider<
                                        FriendFollowController
                                      >.value(
                                        value: context
                                            .read<FriendFollowController>(),
                                        child: FriendCardsPage(api: _api),
                                      ),
                                ),
                              );
                              await context
                                  .read<FriendFollowController>()
                                  .refresh();
                              _prefetchFriendNames(
                                context.read<FriendFollowController>().friends,
                              );
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l.manageCards),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (followingIds.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l.noFriendsYet,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        )
                      else
                        Column(
                          children: followingIds.map((id) {
                            if (!_nameById.containsKey(id)) {
                              _loadFriendName(id);
                            }
                            final display = (_nameById[id]?.isNotEmpty ?? false)
                                ? _nameById[id]!
                                : id;
                            return Dismissible(
                              key: ValueKey('friend_$id'),
                              background: Container(
                                color: cs.errorContainer,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_remove, color: cs.error),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.remove,
                                      style: TextStyle(color: cs.error),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: cs.errorContainer,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l.remove,
                                      style: TextStyle(color: cs.error),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.person_remove, color: cs.error),
                                  ],
                                ),
                              ),
                              onDismissed: (_) async {
                                await context
                                    .read<FriendFollowController>()
                                    .remove(id);
                              },
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(display),
                                subtitle: Text(
                                  l.accountNoInfo,
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                trailing: IconButton(
                                  tooltip: l.remove,
                                  icon: const Icon(Icons.close),
                                  onPressed: () async {
                                    await context
                                        .read<FriendFollowController>()
                                        .remove(id);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(l.userProfileTitle),
        actions: [
          if (_saving)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _canSave ? _saveProfile : null,
              child: Text(l.save),
            ),
        ],
      ),
      body: Stack(children: [const _SeaBackground(), content]),
    );

    if (!widget.forceComplete) return scaffold;
    return WillPopScope(onWillPop: () async => _canSave, child: scaffold);
  }
}
