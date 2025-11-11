// // lib/widgets/boot_loader.dart
// import 'dart:async';
// import 'package:flutter/foundation.dart' show kDebugMode;
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

//   // 如初始化過久（網路不穩等），顯示重試
//   static const _kInitTimeout = Duration(seconds: 20);

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
//     } catch (e) {
//       if (kDebugMode) {
//         // ignore: avoid_print
//         print('[BootLoader] autofillIdolTags error: $e');
//       }
//     }

//     // 為了手感，讓過場至少顯示一下
//     await Future.delayed(const Duration(milliseconds: 400));

//     return (settings: settings, auth: auth, store: store);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<
//       ({AppSettings settings, AuthController auth, MiniCardStore store})
//     >(
//       future: _withTimeout(_boot!),
//       builder: (context, snap) {
//         // 初始化中 → 顯示 Flutter 的自製暖機畫面
//         if (snap.connectionState == ConnectionState.waiting) {
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

//         // 逾時或錯誤 → 顯示重試按鈕
//         if (snap.hasError || !snap.hasData) {
//           final err = snap.error;
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(
//               body: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(Icons.wifi_off, size: 48),
//                       const SizedBox(height: 12),
//                       Text(
//                         '初始化未完成，請檢查網路後重試',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       if (kDebugMode && err != null) ...[
//                         const SizedBox(height: 8),
//                         Text('$err', textAlign: TextAlign.center),
//                       ],
//                       const SizedBox(height: 16),
//                       FilledButton.icon(
//                         onPressed: () {
//                           setState(() {
//                             _boot = _initAll();
//                           });
//                         },
//                         icon: const Icon(Icons.refresh),
//                         label: const Text('重試'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
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

//   Future<T> _withTimeout<T>(Future<T> f) {
//     return f.timeout(
//       _kInitTimeout,
//       onTimeout: () {
//         throw TimeoutException(
//           'BootLoader init timed out after $_kInitTimeout',
//         );
//       },
//     );
//   }
// }

// lib/widgets/boot_loader.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_learning_app/firebase_options.dart';
import 'package:flutter_learning_app/app_settings.dart';
import 'package:flutter_learning_app/app_root.dart';

// 你現有的服務 / 儲存
import 'package:flutter_learning_app/services/services.dart';
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

// 訂閱服務
import 'package:flutter_learning_app/services/subscription_service.dart';

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
    // 1) Firebase（Web 需要 options；失敗時不中斷、走離線）
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      if (kDebugMode) print('[BootLoader] Firebase init failed: $e');
    }

    // 2) 本地圖片儲存（Web 會用 hive）→ 加超時保護
    await miniCardStorageInit().timeout(const Duration(seconds: 5));

    // 3) App 設定（本機）
    final settings = await AppSettings.load().timeout(
      const Duration(seconds: 5),
    );

    // 4) Auth（可能打網路，失敗不中斷）
    final auth = AuthController();
    try {
      await auth.init().timeout(const Duration(seconds: 8));
    } catch (e) {
      if (kDebugMode) print('[BootLoader] Auth init failed: $e');
    }

    // 5) 訂閱狀態
    //    ⚠️ Web 不支援 in_app_purchase：改成「直接啟用模擬」或跳過 restore。
    try {
      if (kIsWeb) {
        // 方式 A：強制啟用開發者模擬（你已有 Dev Override）
        await SubscriptionService.I.setDevOverride(
          enabled: true,
          plan: SubscriptionPlan.free, // 或 basic/pro/plus 隨你測
          isActive: false,
        );
      } else {
        await SubscriptionService.I.init().timeout(const Duration(seconds: 8));
      }
    } catch (e) {
      if (kDebugMode) print('[BootLoader] Subscription init failed: $e');
    }

    // 6) MiniCard 本地資料（autofill 可能打網路，包 try/catch）
    final store = MiniCardStore();
    await store.hydrateFromPrefs(artists: settings.cardItems);
    try {
      await store
          .autofillIdolTags(artists: settings.cardItems, prefer: const [])
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      if (kDebugMode) print('[BootLoader] autofillIdolTags error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    return (settings: settings, auth: auth, store: store);
  }

  /// 極簡離線初始化：完全不打網路，讀本機可得的東西，直接進 App
  Future<({AppSettings settings, AuthController auth, MiniCardStore store})>
  _initAllOfflineFallback() async {
    // 不打任何網路，只做本機可完成的初始化
    await miniCardStorageInit();
    final settings = await AppSettings.load();

    // 初始化 AuthController（會把上次使用者從 SharedPreferences 還原進來）
    final auth = AuthController();
    await auth.init();

    // 嘗試用「上次登入使用者」離線進入（不拿 token）
    // 若沒有上次使用者，會回傳 false；不阻擋進入 App（保持未登入狀態即可）
    await auth.continueOfflineWithLastUser();

    // 訂閱：讀本機快取即可；restorePurchases 失敗也不致命
    try {
      await SubscriptionService.I.init();
    } catch (_) {
      // 忽略
    }

    final store = MiniCardStore();
    await store.hydrateFromPrefs(artists: settings.cardItems);

    return (settings: settings, auth: auth, store: store);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({AppSettings settings, AuthController auth, MiniCardStore store})
    >(
      future: _withTimeout(_boot!),
      builder: (context, snap) {
        // 初始化中 → 簡單進度圈（已移除暖機畫面）
        if (snap.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(height: 8),
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('初始化中…'),
                  ],
                ),
              ),
            ),
          );
        }

        // 逾時或錯誤 → 顯示「重試」＋「以離線模式繼續」
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
                        '初始化未完成，請檢查網路或選擇離線模式',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
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
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _boot = _initAllOfflineFallback();
                          });
                        },
                        icon: const Icon(Icons.offline_bolt_outlined),
                        label: const Text('以離線模式繼續'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // ✅ 初始化完成 → 移除原生啟動畫面，進入 App
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
