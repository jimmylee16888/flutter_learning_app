import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // ★ 加這個
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

import 'package:flutter_learning_app/utils/mini_card_io.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: miniCardStore),
        ChangeNotifierProvider.value(value: auth),

        // 全域標籤控制器
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
            ctl.bootstrap();
            return ctl;
          },
        ),

        // 全域好友控制器
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
            ctl.bootstrap();
            return ctl;
          },
        ),
      ],
      child: AppRoot(settings: settings, auth: auth),
    ),
  );
}

/// ★ 讓 PageView/Scrollable 支援滑鼠與觸控板拖曳（Web/桌面）
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // 滑鼠拖曳
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown, // 某些瀏覽器的觸控板事件會跑到這裡
    // 若你的 Flutter SDK 支援，打開下一行會讓 macOS 觸控板更自然：
    // PointerDeviceKind.trackpad,
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

              // ★ 關鍵：全域套用支援滑鼠/觸控板拖曳
              scrollBehavior: const AppScrollBehavior(),

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
