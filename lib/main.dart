// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';

import 'app_settings.dart';
import 'screens/root_nav.dart';
import 'screens/auth/login_page.dart';

// services（含 SocialApi / TagFollowController / FriendFollowController 等）
import 'package:flutter_learning_app/services/services.dart';

// 本地小卡儲存（若你有用到）
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemUiOverlayStyle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ★ 新增：每日提示入口（TipGate）
import 'widgets/tip_gate.dart';

// ★ 新增：PWA chrome 動態同步
import 'utils/pwa_chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初始化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 本地圖片儲存初始化（Web 先開 Hive box；行動/桌面無動作）
  await miniCardStorageInit();

  // 載入本機設定
  final settings = await AppSettings.load();

  // AuthController
  final auth = AuthController();
  await auth.init();

  // MiniCard 本機儲存
  final miniCardStore = MiniCardStore();
  await miniCardStore.hydrateFromPrefs(artists: settings.cardItems);

  // 啟動後自動填入 idol:xxx（只處理尚未有 idol: 的卡）
  try {
    final filled = await miniCardStore.autofillIdolTags(
      artists: settings.cardItems,
      prefer: const <String>[],
    );
    // ignore: avoid_print
    print('[Dex] Auto-filled idol for $filled cards');
  } catch (e) {
    // ignore: avoid_print
    print('[Dex] Auto-fill failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: miniCardStore),
        ChangeNotifierProvider.value(value: auth),
      ],
      child: AppRoot(settings: settings, auth: auth),
    ),
  );
}

/// 讓 PageView/Scrollable 支援滑鼠與觸控板拖曳（Web/桌面）
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
    // PointerDeviceKind.trackpad, // 如需可開
  };
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.settings, required this.auth});
  final AppSettings settings;
  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (_, __) {
        return AnimatedBuilder(
          animation: auth,
          builder: (__, ___) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: settings.locale,
              onGenerateTitle: (ctx) => ctx.l10n.appTitle,

              // ★ 全域主題：AppBar/NavigationBar 跟底色一致，隨深淺主題切換
              theme: _buildTheme(Brightness.light),
              darkTheme: _buildTheme(Brightness.dark),
              themeMode: settings.themeMode,

              scrollBehavior: const AppScrollBehavior(),

              // ★ 關鍵：每次 build 依當前主題同步 PWA 狀態列/背景
              builder: (ctx, child) {
                final theme = Theme.of(ctx);
                updatePwaChrome(
                  surface: theme.colorScheme.surface,
                  dark: theme.brightness == Brightness.dark,
                );
                return child!;
              },

              // 登入後才建立 Tag/Friend 兩個 Provider
              home: auth.isAuthenticated
                  ? _AuthenticatedHome(settings: settings)
                  : LoginPage(auth: auth, settings: settings),
            );
          },
        );
      },
    );
  }
}

/// 建立主題：讓 AppBar/NavigationBar 使用 surface，同時關閉 M3 疊色
ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    // 你的品牌色，僅用來產出 ColorScheme（可自行調整）
    colorSchemeSeed: const Color(0xFF4F9CFB),
  );

  final cs = base.colorScheme;

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface, // 與底色一致
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent, // 移除 M3 疊色
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface, // 與底色一致
      surfaceTintColor: Colors.transparent, // 移除 M3 疊色
      indicatorColor: cs.secondaryContainer.withOpacity(0.24),
    ),
    cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
    ),
  );
}

/// ===== 本機裝置身分 / 暱稱儲存 =====
const _kClientIdKey = 'client_id'; // 本機裝置固定 ID
String _aliasKey(String accountId, String clientId) =>
    'alias.$accountId.$clientId'; // 每個帳號在此裝置的本機暱稱

/// 產生/讀取本機裝置 ID（一次建立，永久沿用）
Future<String> _ensureClientId() async {
  final sp = await SharedPreferences.getInstance();
  var id = sp.getString(_kClientIdKey);
  id ??= 'dev_${const Uuid().v4()}';
  await sp.setString(_kClientIdKey, id);
  return id;
}

/// 讀取/寫入本機暱稱（對同一個帳號，每台裝置可不同）
Future<String?> loadLocalAlias({
  required String accountId,
  required String clientId,
}) async {
  final sp = await SharedPreferences.getInstance();
  return sp.getString(_aliasKey(accountId, clientId));
}

Future<void> saveLocalAlias({
  required String accountId,
  required String clientId,
  required String alias,
}) async {
  final sp = await SharedPreferences.getInstance();
  await sp.setString(_aliasKey(accountId, clientId), alias);
}

class _AuthenticatedHome extends StatelessWidget {
  const _AuthenticatedHome({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // meId 以 email(lowercase) 優先，其次 uid（對齊後端）
    final baseMeId = (user?.email?.toLowerCase() ?? user?.uid ?? 'u_me');

    // 基準顯示名稱（沒本機暱稱時用）
    final baseName = (settings.nickname?.trim().isNotEmpty == true)
        ? settings.nickname!.trim()
        : (user?.displayName ?? 'Me');

    // 取得 idToken 的 provider（給 SocialApi 使用 Bearer）
    Future<String?> Function() idTokenProvider = () async =>
        FirebaseAuth.instance.currentUser?.getIdToken();

    // dev only：把一顆 ID Token 複製到剪貼簿方便測試
    assert(() {
      Future.microtask(() async {
        final t = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (t != null) {
          debugPrint('\n===== ID TOKEN (copy for curl) =====\n$t\n');
          await Clipboard.setData(ClipboardData(text: t));
          debugPrint('→ 已複製到剪貼簿');
        } else {
          debugPrint('（尚未登入，拿不到 ID Token）');
        }
      });
      return true;
    }());

    // 先把 clientId / 本機暱稱抓好，再建立 Providers
    return FutureBuilder<(String clientId, String meId, String meNameLocal)>(
      future: () async {
        final clientId = await _ensureClientId();

        // 確保 meId 不會是 'u_me'：若沒有 email/uid，至少用 clientId
        final meId = baseMeId == 'u_me' ? clientId : baseMeId;

        // 讀取「這台裝置、這個帳號」的本機暱稱；沒有就用基準名稱
        final alias = await loadLocalAlias(accountId: meId, clientId: clientId);
        final meNameLocal = (alias?.trim().isNotEmpty ?? false)
            ? alias!.trim()
            : baseName;

        return (clientId, meId, meNameLocal);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final (clientId, meId, meNameLocal) = snap.data!;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider<TagFollowController>(
              create: (_) {
                final ctl = TagFollowController(
                  api: SocialApi(
                    meId: meId,
                    meName: meNameLocal,
                    idTokenProvider: idTokenProvider,
                    // 新增：把裝置 & 本機暱稱一起傳給 API
                    clientId: clientId,
                    clientAliasProvider: () async => await loadLocalAlias(
                      accountId: meId,
                      clientId: clientId,
                    ),
                  ),
                );
                ctl.bootstrap();
                return ctl;
              },
            ),
            ChangeNotifierProvider<FriendFollowController>(
              create: (_) {
                final ctl = FriendFollowController(
                  api: SocialApi(
                    meId: meId,
                    meName: meNameLocal,
                    idTokenProvider: idTokenProvider,
                    clientId: clientId,
                    clientAliasProvider: () async => await loadLocalAlias(
                      accountId: meId,
                      clientId: clientId,
                    ),
                  ),
                );
                ctl.bootstrap();
                return ctl;
              },
            ),
          ],

          // 在根頁外面包 TipGate（每日提示）
          child: TipGate(
            idTokenProvider: idTokenProvider,
            clientId: clientId,
            meId: meId,
            meNameLocal: meNameLocal,
            child: RootNav(settings: settings),
          ),
        );
      },
    );
  }
}
