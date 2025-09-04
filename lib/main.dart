// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // ⬅ 新增
import 'firebase_options.dart'; // ⬅ 新增

import 'services/mini_card_store.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'app_settings.dart';
import 'screens/root_nav.dart';
import 'services/auth_controller.dart';
import 'screens/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⬇ 先連 Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = await AppSettings.load();

  // ⬇ 用 Firebase 版的 AuthController（下面第 2 步會提供完整檔案）
  final auth = AuthController();
  await auth.init();

  final miniCardStore = MiniCardStore();
  await miniCardStore.hydrateFromPrefs(artists: settings.cardItems);

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
