// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

// import 'package:flutter_learning_app/firebase_options.dart';
// import 'package:flutter_learning_app/app_settings.dart';
// import 'package:flutter_learning_app/app_root.dart';
// import 'package:flutter_learning_app/widgets/splash_warmup.dart' as sw;

// // 你現有的服務 / 儲存
// import 'package:flutter_learning_app/services/services.dart';
// import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

// class BootLoader extends StatefulWidget {
//   const BootLoader({super.key});

//   @override
//   State<BootLoader> createState() => _BootLoaderState();
// }

// class _BootLoaderState extends State<BootLoader> {
//   Future<({AppSettings settings, AuthController auth, MiniCardStore store})>?
//   _boot;

//   @override
//   void initState() {
//     super.initState();
//     _boot = _initAll();
//   }

//   Future<({AppSettings settings, AuthController auth, MiniCardStore store})>
//   _initAll() async {
//     // 1) Firebase
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     // 2) 本地圖片儲存（Web 開 hive；行動/桌面不動作）
//     await miniCardStorageInit();

//     // 3) App 設定
//     final settings = await AppSettings.load();

//     // 4) Auth
//     final auth = AuthController();
//     await auth.init();

//     // 5) MiniCard
//     final store = MiniCardStore();
//     await store.hydrateFromPrefs(artists: settings.cardItems);
//     try {
//       await store.autofillIdolTags(
//         artists: settings.cardItems,
//         prefer: const [],
//       );
//     } catch (_) {}

//     // 為了手感，讓過場至少顯示一下
//     await Future.delayed(const Duration(milliseconds: 400));

//     return (settings: settings, auth: auth, store: store);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<
//       ({AppSettings settings, AuthController auth, MiniCardStore store})
//     >(
//       future: _boot,
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           // 初始化中 → 顯示 Flutter 的過場畫面
//           return const MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: sw.SplashWarmup(
//               imageAsset: 'assets/images/popcard01.png',
//               tips: [
//                 '長按小卡可快速加入收藏夾 ✨',
//                 '在 Explore 追蹤你喜歡的標籤試試看！',
//                 '支援離線瀏覽，恢復網路後自動同步 ☁️',
//                 '個人檔案可設定暱稱與生日 🎂',
//                 '滑動卡面可快速切換前/後視圖 🔁',
//               ],
//             ),
//           );
//         }

//         // ✅ 初始化完成 → 移除原生啟動畫面（避免白屏切換）
//         FlutterNativeSplash.remove();

//         final data = snap.data!;
//         return MultiProvider(
//           providers: [
//             ChangeNotifierProvider.value(value: data.store),
//             ChangeNotifierProvider.value(value: data.auth),
//           ],
//           child: AppRoot(settings: data.settings, auth: data.auth),
//         );
//       },
//     );
//   }
// }

// lib/widgets/boot_loader.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_learning_app/firebase_options.dart';
import 'package:flutter_learning_app/app_settings.dart';
import 'package:flutter_learning_app/app_root.dart';
import 'package:flutter_learning_app/widgets/splash_warmup.dart' as sw;

// 你現有的服務 / 儲存
import 'package:flutter_learning_app/services/services.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

class BootLoader extends StatefulWidget {
  const BootLoader({super.key});

  @override
  State<BootLoader> createState() => _BootLoaderState();
}

class _BootLoaderState extends State<BootLoader> {
  Future<({AppSettings settings, AuthController auth, MiniCardStore store})>?
  _boot;

  // 如初始化過久（網路不穩等），顯示重試
  static const _kInitTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _boot = _initAll();
  }

  Future<({AppSettings settings, AuthController auth, MiniCardStore store})>
  _initAll() async {
    // 1) Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2) 本地圖片儲存（Web 開 hive；行動/桌面不動作）
    await miniCardStorageInit();

    // 3) App 設定
    final settings = await AppSettings.load();

    // 4) Auth
    final auth = AuthController();
    await auth.init();

    // 5) MiniCard
    final store = MiniCardStore();
    await store.hydrateFromPrefs(artists: settings.cardItems);
    try {
      await store.autofillIdolTags(
        artists: settings.cardItems,
        prefer: const [],
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[BootLoader] autofillIdolTags error: $e');
      }
    }

    // 為了手感，讓過場至少顯示一下
    await Future.delayed(const Duration(milliseconds: 400));

    return (settings: settings, auth: auth, store: store);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({AppSettings settings, AuthController auth, MiniCardStore store})
    >(
      future: _withTimeout(_boot!),
      builder: (context, snap) {
        // 初始化中 → 顯示 Flutter 的自製暖機畫面
        if (snap.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: sw.SplashWarmup(
              imageAsset: 'assets/images/popcard01.png',
              tips: [
                '長按小卡可快速加入收藏夾 ✨',
                '在 Explore 追蹤你喜歡的標籤試試看！',
                '支援離線瀏覽，恢復網路後自動同步 ☁️',
                '個人檔案可設定暱稱與生日 🎂',
                '滑動卡面可快速切換前/後視圖 🔁',
              ],
            ),
          );
        }

        // 逾時或錯誤 → 顯示重試按鈕
        if (snap.hasError || !snap.hasData) {
          final err = snap.error;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        '初始化未完成，請檢查網路後重試',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (kDebugMode && err != null) ...[
                        const SizedBox(height: 8),
                        Text('$err', textAlign: TextAlign.center),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _boot = _initAll();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('重試'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // ✅ 初始化完成 → 移除原生啟動畫面（避免白屏切換）
        FlutterNativeSplash.remove();

        final data = snap.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: data.store),
            ChangeNotifierProvider.value(value: data.auth),
          ],
          child: AppRoot(settings: data.settings, auth: data.auth),
        );
      },
    );
  }

  Future<T> _withTimeout<T>(Future<T> f) {
    return f.timeout(
      _kInitTimeout,
      onTimeout: () {
        throw TimeoutException(
          'BootLoader init timed out after $_kInitTimeout',
        );
      },
    );
  }
}
