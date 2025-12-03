// lib/widgets/boot_loader.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/album/album_store.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:flutter_learning_app/firebase_options.dart';
import 'package:flutter_learning_app/app_settings.dart';
import 'package:flutter_learning_app/app_root.dart';

// 你現有的服務 / 儲存
import 'package:flutter_learning_app/services/services.dart'; // AuthController, MiniCardStore 等
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';

// ⬇️ 新增：CardItemStore（CardItem / Categories 的本機快取）
import 'package:flutter_learning_app/services/card_item/card_item_store.dart';

// 訂閱服務
import 'package:flutter_learning_app/services/subscription_service.dart';
import 'package:flutter_learning_app/services/dev_mode.dart';

import 'package:flutter_learning_app/services/library_sync_service.dart';

class BootLoader extends StatefulWidget {
  const BootLoader({super.key});

  @override
  State<BootLoader> createState() => _BootLoaderState();
}

class _BootLoaderState extends State<BootLoader> {
  Future<
    ({
      AppSettings settings,
      AuthController auth,
      MiniCardStore miniStore,
      CardItemStore cardStore,
    })
  >?
  _boot;

  // 如初始化過久（網路不穩等），顯示重試
  static const _kInitTimeout = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _boot = _initAll();
  }

  @override
  void dispose() {
    // 釋放可能的購買監聽/ValueNotifier 等
    SubscriptionService.I.dispose();
    super.dispose();
  }

  Future<
    ({
      AppSettings settings,
      AuthController auth,
      MiniCardStore miniStore,
      CardItemStore cardStore,
    })
  >
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

    // 5) 訂閱狀態：啟動時跑一次偵測
    try {
      if (kIsWeb) {
        // Web 無 IAP：只在開發者模式時啟用覆寫；否則保持 free/inactive
        final dev = await DevMode.isEnabled();
        await SubscriptionService.I.setDevOverride(
          enabled: dev,
          plan: dev ? SubscriptionPlan.basic : SubscriptionPlan.free,
          isActive: dev, // 想體驗完整付費 UI 就設 true
        );
      } else {
        // 行動端／桌面：初始化 + 啟動時跑一次恢復&偵測
        await SubscriptionService.I.init().timeout(const Duration(seconds: 8));
        await SubscriptionService.I.refreshFromStoreAndDetect().timeout(
          const Duration(seconds: 12),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('[BootLoader] Subscription init/refresh failed: $e');
      }
    }

    // 6) ⬇️ 先載入 CardItemStore（取代原本 settings.cardItems）
    final cardStore = await CardItemStore.load();

    // 7) MiniCard 本地資料（autofill 可能打網路，包 try/catch）
    final miniStore = MiniCardStore();
    await miniStore.hydrateFromPrefs(artists: cardStore.cardItems);
    try {
      await miniStore
          .autofillIdolTags(artists: cardStore.cardItems, prefer: const [])
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      if (kDebugMode) print('[BootLoader] autofillIdolTags error: $e');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    return (
      settings: settings,
      auth: auth,
      miniStore: miniStore,
      cardStore: cardStore,
    );
  }

  /// 極簡離線初始化：完全不打網路，讀本機可得的東西，直接進 App
  Future<
    ({
      AppSettings settings,
      AuthController auth,
      MiniCardStore miniStore,
      CardItemStore cardStore,
    })
  >
  _initAllOfflineFallback() async {
    // 不打任何網路，只做本機可完成的初始化
    await miniCardStorageInit();
    final settings = await AppSettings.load();

    // 初始化 AuthController（會把上次使用者從 SharedPreferences 還原進來）
    final auth = AuthController();
    await auth.init();
    await auth.continueOfflineWithLastUser();

    // 訂閱：讀本機快取即可；restorePurchases 失敗也不致命
    try {
      await SubscriptionService.I.init();
    } catch (_) {
      // 忽略
    }

    // ⬇️ 同步離線也要從 CardItemStore 拿 artists
    final cardStore = await CardItemStore.load();

    final miniStore = MiniCardStore();
    await miniStore.hydrateFromPrefs(artists: cardStore.cardItems);

    return (
      settings: settings,
      auth: auth,
      miniStore: miniStore,
      cardStore: cardStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({
        AppSettings settings,
        AuthController auth,
        MiniCardStore miniStore,
        CardItemStore cardStore,
      })
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
            // 1) 基礎 Store / Controller
            ChangeNotifierProvider.value(value: data.miniStore),
            ChangeNotifierProvider.value(value: data.cardStore),
            ChangeNotifierProvider.value(value: data.auth),
            ChangeNotifierProvider<AlbumStore>(
              create: (_) => AlbumStore()..load(),
            ),

            // 2) LibrarySyncService：依賴前面四個
            ProxyProvider4<
              CardItemStore,
              MiniCardStore,
              AlbumStore,
              AuthController,
              LibrarySyncService
            >(
              update: (_, cardStore, miniStore, albumStore, auth, __) {
                return LibrarySyncService(
                  cardStore: cardStore,
                  miniStore: miniStore,
                  albumStore: albumStore,
                  auth: auth,
                );
              },
            ),
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
