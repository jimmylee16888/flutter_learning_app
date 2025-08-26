import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'screens/root_nav.dart';
import 'app_settings.dart'; // ← 新增這行

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load(); // 讀取已儲存的主題/語言
  runApp(_App(settings: settings));
}

class _App extends StatelessWidget {
  const _App({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (ctx) => ctx.l10n.appTitle,
      home: RootNav(
        cards: const [],
        settings: settings, // ← 必填參數
      ),
    );
  }
}
