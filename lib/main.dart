import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'app_settings.dart';
import 'screens/root_nav.dart';
import 'screens/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初始化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 載入本機設定
  final settings = await AppSettings.load();

  // AuthController（Firebase 版本）
  final auth = AuthController();
  await auth.init();

  // MiniCard 本機儲存
  final miniCardStore = MiniCardStore();
  await miniCardStore.hydrateFromPrefs(artists: settings.cardItems);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: miniCardStore),
        ChangeNotifierProvider.value(value: auth),

        // ★ 全域標籤控制器：所有頁面共用（Following 分頁/個人設定/標籤管理）
        ChangeNotifierProvider<TagFollowController>(
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            final meId = user?.uid ?? 'u_me';
            final meName = (settings.nickname?.trim().isNotEmpty == true)
                ? settings.nickname!.trim()
                : (user?.displayName ?? 'Me');
            final ctl = TagFollowController(
              api: SocialApi(
                meId: meId,
                meName: meName,
                // 若要用 Firebase 驗證頭：idTokenProvider: () => user?.getIdToken(true),
              ),
            );
            ctl.bootstrap(); // 從後端載入，必要時遷移本機舊資料
            return ctl;
          },
        ),

        // ★ 全域好友控制器：所有頁面共用（名片頁/使用者設定/個人頁）
        ChangeNotifierProvider<FriendFollowController>(
          create: (_) {
            final user = FirebaseAuth.instance.currentUser;
            final meId = user?.uid ?? 'u_me';
            final meName = (settings.nickname?.trim().isNotEmpty == true)
                ? settings.nickname!.trim()
                : (user?.displayName ?? 'Me');
            final ctl = FriendFollowController(
              api: SocialApi(
                meId: meId,
                meName: meName,
                // idTokenProvider: () => user?.getIdToken(true),
              ),
            );
            ctl.bootstrap(); // 後端 ↔ 本地同步（後端空 → 回填本地）
            return ctl;
          },
        ),
      ],
      child: AppRoot(settings: settings, auth: auth),
    ),
  );
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
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: Colors.blue,
              ),
              themeMode: settings.themeMode,
              home: auth.isAuthenticated
                  ? RootNav(settings: settings)
                  : LoginPage(auth: auth, settings: settings),
            );
          },
        );
      },
    );
  }
}
