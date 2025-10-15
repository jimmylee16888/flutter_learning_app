// TODO Implement this library.
// lib/widgets/splash_warmup.dart
import 'dart:async';
import 'package:flutter/material.dart';

/// 啟動畫面（過場頁）
/// - 上方顯示圖片
/// - 下方顯示提示文字，每 3 秒自動更換並淡入
class SplashWarmup extends StatefulWidget {
  const SplashWarmup({
    super.key,
    required this.tips,
    this.imageAsset = 'assets/images/popcard01.png',
    this.showSpinner = true,
  });

  /// 提示文字清單（至少 1 筆）
  final List<String> tips;

  /// 上方圖片資產路徑
  final String imageAsset;

  /// 是否顯示小型進度圈
  final bool showSpinner;

  @override
  State<SplashWarmup> createState() => _SplashWarmupState();
}

class _SplashWarmupState extends State<SplashWarmup> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 保護：若 tips 長度為 0，避免除以 0
    if (widget.tips.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % widget.tips.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final maxW = constraints.maxWidth;
            final isWide = maxW >= 600;

            // 讓圖片高度在不同寬度下有合理上限，避免中段過度留白
            final double imageMaxHeight = isWide ? 320 : 240;
            final double imageMaxWidth = isWide ? 420 : 300;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // 上方圖片（限制最大寬高，不用 Expanded 以免撐出大片空白）
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: imageMaxHeight,
                      maxWidth: imageMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        widget.imageAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // 中間留一點彈性空間
                const Spacer(),

                // 可選：小型進度圈
                if (widget.showSpinner) ...[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 12),
                ],

                // 下方提示（每 3 秒淡入切換）
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            // 若沒有 tips，顯示預設字句
                            (widget.tips.isEmpty
                                ? '準備中…'
                                : widget.tips[_index]),
                            key: ValueKey(_index),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
