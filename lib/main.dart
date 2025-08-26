// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/root_nav.dart';
import 'widgets/photo_quote_card.dart';
import 'app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load(); // ← 讀取已保存的設定
  runApp(AppRoot(settings: settings));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings, // ← 設定改變時重建 MaterialApp
      builder: (_, __) {
        return MaterialApp(
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
          ),
          themeMode: settings.themeMode,
          locale: settings.locale, // 若用到本地化，這裡就會切語言
          home: RootNav(
            settings: settings, // ← 往下傳
            cards: [
              PhotoQuoteCard(
                image: const NetworkImage(
                  'https://static.wikia.nocookie.net/love-talk/images/3/37/Le-sserafim-kim-chae-won-source-music-girl-group-2022.jpg/revision/latest/scale-to-width-down/2000?cb=20230307142319',
                ),
                title: 'Chaewon',
                birthday: DateTime(2000, 8, 1),
                quote: 'Chaewon love Jimmy',
              ),
              PhotoQuoteCard(
                image: const NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQm9OSyGLg1IwQCcG661Uh2ivWlZJuTBgGuTw&s',
                ),
                title: 'Gaeul',
                birthday: DateTime(2002, 9, 24),
                quote: 'Gaeul love Jimmy',
              ),
              PhotoQuoteCard(
                image: const NetworkImage(
                  'https://megapx-assets.dcard.tw/images/19c87f04-d4f3-49d4-830d-57b5d1833803/640.jpeg',
                ),
                title: 'Liz',
                birthday: DateTime(2004, 11, 21),
                quote: 'Liz love Jimmy',
              ),
            ],
          ),
        );
      },
    );
  }
}
