// lib/main.dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart'; // ← 改這個
import 'l10n/l10n.dart';
import 'app_settings.dart';
import 'screens/root_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(AppRoot(settings: settings));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // i18n
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: settings.locale,
          onGenerateTitle: (ctx) => ctx.l10n.appTitle,
          // theme
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
          ),
          themeMode: settings.themeMode,
          home: RootNav(settings: settings),
        );
      },
    );
  }
}
