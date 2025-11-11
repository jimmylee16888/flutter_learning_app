import 'dart:async'; // Dart 的非同步工具（Future、Stream、runZonedGuarded 等）
import 'dart:ui'; // 匯入底層 UI 與平台層 API
import 'package:flutter/material.dart'; // 匯入 Flutter 的 Material 元件與核心 API（runApp、WidgetsFlutterBinding、debugPrint 等）
import 'package:flutter_native_splash/flutter_native_splash.dart'; //來自 flutter_native_splash 套件的 API，用來保留/移除原生啟動畫面（splash），避免白屏閃一下。

import 'package:flutter_learning_app/widgets/boot_loader.dart';

//Dart 程式入口點
void main() {
  // 建立一個受保護的 zone，捕捉未處理的異常
  runZonedGuarded(
    // zone 內的程式碼
    () async {
      // 1) 先初始化 binding（之後所有初始化都在同一個 zone）
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      // （可選）攔截錯誤：一定要在同一個 zone 裡
      FlutterError.onError = (details) {
        debugPrint('[flutter] ${details.exception}\n${details.stack}');
      };
      PlatformDispatcher.instance.onError = (e, st) {
        debugPrint('[platform] $e\n$st');
        return true;
      };

      // 2) 保留啟動畫面
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // 3) 啟動 App（建議在 BootLoader 裡的 finally 呼叫 FlutterNativeSplash.remove()）
      runApp(const BootLoader());
    },
    (e, st) {
      debugPrint('[top-level] $e\n$st');
    },
  );
}
