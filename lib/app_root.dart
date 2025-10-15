// lib/app_root.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'app_settings.dart';
import 'screens/root_nav.dart';
import 'screens/auth/login_page.dart';

// services（含 SocialApi / TagFollowController / FriendFollowController 等）
import 'package:flutter_learning_app/services/services.dart';

// 每日提示入口（TipGate）
import 'widgets/tip_gate.dart';

// PWA chrome 動態同步
import 'utils/pwa_chrome.dart';

import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, SystemUiOverlayStyle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 讓 PageView/Scrollable 支援滑鼠與觸控板拖曳（Web/桌面）
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
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
              theme: _buildTheme(Brightness.light),
              darkTheme: _buildTheme(Brightness.dark),
              themeMode: settings.themeMode,
              scrollBehavior: const AppScrollBehavior(),
              builder: (ctx, child) {
                final theme = Theme.of(ctx);
                updatePwaChrome(
                  surface: theme.colorScheme.surface,
                  dark: theme.brightness == Brightness.dark,
                );
                return child!;
              },
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
    colorSchemeSeed: const Color(0xFF4F9CFB),
  );

  final cs = base.colorScheme;

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
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
    'alias.$accountId.$clientId';

Future<String> _ensureClientId() async {
  final sp = await SharedPreferences.getInstance();
  var id = sp.getString(_kClientIdKey);
  id ??= 'dev_${const Uuid().v4()}';
  await sp.setString(_kClientIdKey, id);
  return id;
}

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

    final baseMeId = (user?.email?.toLowerCase() ?? user?.uid ?? 'u_me');
    final baseName = (settings.nickname?.trim().isNotEmpty == true)
        ? settings.nickname!.trim()
        : (user?.displayName ?? 'Me');

    Future<String?> Function() idTokenProvider = () async =>
        FirebaseAuth.instance.currentUser?.getIdToken();

    assert(() {
      Future.microtask(() async {
        final t = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (t != null) {
          debugPrint('\n===== ID TOKEN (copy for curl) =====\n$t\n');
          await Clipboard.setData(ClipboardData(text: t));
          debugPrint('→ 已複製到剪貼簿');
        }
      });
      return true;
    }());

    return FutureBuilder<(String clientId, String meId, String meNameLocal)>(
      future: () async {
        final clientId = await _ensureClientId();
        final meId = baseMeId == 'u_me' ? clientId : baseMeId;
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
