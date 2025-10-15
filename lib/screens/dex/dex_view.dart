// lib/screens/card/dex_view.dart
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/mini_card_data.dart';
import 'package:flutter_learning_app/screens/card/detail/mini_cards/mini_cards_page.dart';
import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
import 'package:flutter_learning_app/utils/dex/dex_idol_helper.dart';

// 跨平台圖片抽象
import 'package:flutter_learning_app/utils/mini_card_io/mini_card_io.dart';
// Web 專用的無 CORS 圖片 widget（注意：這個版本沒有 onError 等參數）
import 'package:flutter_learning_app/utils/no_cors_image/no_cors_image.dart';

class DexView extends StatefulWidget {
  const DexView({super.key});
  @override
  State<DexView> createState() => _DexViewState();
}

class _DexViewState extends State<DexView> {
  String _query = '';
  int _cols = 3;
  static const _kMinCols = 1;
  static const _kMaxCols = 8;

  double _scaleAccum = 1.0;
  static const _kScaleStep = 1.15;

  void _zoomIn() =>
      setState(() => _cols = (_cols - 1).clamp(_kMinCols, _kMaxCols));
  void _zoomOut() =>
      setState(() => _cols = (_cols + 1).clamp(_kMinCols, _kMaxCols));
  void _zoomReset() => setState(() => _cols = 3);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final store = context.watch<MiniCardStore>();
    final List<MiniCardData> cards = store.cards;

    if (cards.isEmpty) {
      return _ScaffoldWrap(
        title: l.dex_title,
        child: Center(child: Text(l.dex_empty)),
      );
    }

    final grouped = groupMiniCardsByIdol(
      cards,
      uncategorized: l.dex_uncategorized,
    );

    List<MapEntry<String, List<MiniCardData>>> entries = grouped.entries
        .toList();
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      entries = entries.where((e) {
        final inGroupName = e.key.toLowerCase().contains(q);
        final inCards = e.value.any(
          (c) =>
              (c.name ?? '').toLowerCase().contains(q) ||
              (c.serial ?? '').toLowerCase().contains(q),
        );
        return inGroupName || inCards;
      }).toList();
    }
    entries.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    final listView = ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final idol = entries[i].key;
        final list = [...entries[i].value]
          ..sort(
            (a, b) => (a.name ?? a.id).toLowerCase().compareTo(
              (b.name ?? b.id).toLowerCase(),
            ),
          );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
              child: Text(
                '$idol · ${l.dex_cardsCount(list.length)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: list.length,
              itemBuilder: (_, j) {
                final card = list[j];
                return _MiniCardTile(
                  card: card,
                  onOpen: () async {
                    final updated = await Navigator.of(context)
                        .push<List<MiniCardData>>(
                          MaterialPageRoute(
                            builder: (_) => MiniCardsPage(
                              title: idol,
                              cards: list,
                              initialIndex: j,
                            ),
                          ),
                        );
                    if (updated != null) {
                      await context.read<MiniCardStore>().replaceCardsForIdol(
                        idol: idol,
                        next: updated,
                      );
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );

    final zoomControls = Positioned(
      right: 12,
      bottom: 18,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconSquareButton(
                icon: Icons.zoom_in,
                tooltip: l.zoomIn,
                onTap: _zoomIn,
              ),
              const SizedBox(height: 8),
              _IconSquareButton(
                icon: Icons.zoom_out,
                tooltip: l.zoomOut,
                onTap: _zoomOut,
              ),
              const SizedBox(height: 8),
              _IconSquareButton(
                icon: Icons.aspect_ratio,
                tooltip: l.resetZoom,
                onTap: _zoomReset,
              ),
            ],
          ),
        ),
      ),
    );

    final shortcuts = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.equal, LogicalKeyboardKey.shift):
          const _ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.add): const _ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.numpadAdd): const _ZoomInIntent(),
      LogicalKeySet(LogicalKeyboardKey.minus): const _ZoomOutIntent(),
      LogicalKeySet(LogicalKeyboardKey.numpadSubtract): const _ZoomOutIntent(),
      LogicalKeySet(LogicalKeyboardKey.digit0): const _ZoomResetIntent(),
      LogicalKeySet(LogicalKeyboardKey.numpad0): const _ZoomResetIntent(),
    };
    final actions = <Type, Action<Intent>>{
      _ZoomInIntent: CallbackAction<_ZoomInIntent>(onInvoke: (_) => _zoomIn()),
      _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
        onInvoke: (_) => _zoomOut(),
      ),
      _ZoomResetIntent: CallbackAction<_ZoomResetIntent>(
        onInvoke: (_) => _zoomReset(),
      ),
    };

    final content = Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _zoomReset,
          onScaleStart: (_) => _scaleAccum = 1.0,
          onScaleUpdate: (details) {
            _scaleAccum *= details.scale;
            if (_scaleAccum > _kScaleStep) {
              _scaleAccum = 1.0;
              _zoomIn();
            } else if (_scaleAccum < 1 / _kScaleStep) {
              _scaleAccum = 1.0;
              _zoomOut();
            }
          },
          child: listView,
        ),
        zoomControls,
      ],
    );

    return _ScaffoldWrap(
      title: l.dex_title,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l.dex_searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: Shortcuts(
              shortcuts: shortcuts,
              child: Actions(
                actions: actions,
                child: Focus(autofocus: true, child: content),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Intent / UI 小元件 ======

class _ZoomInIntent extends Intent {
  const _ZoomInIntent();
}

class _ZoomOutIntent extends Intent {
  const _ZoomOutIntent();
}

class _ZoomResetIntent extends Intent {
  const _ZoomResetIntent();
}

class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

// ====== 單張小卡（只顯示圖；不顯示任何文字） ======

class _MiniCardTile extends StatelessWidget {
  const _MiniCardTile({required this.card, required this.onOpen});
  final MiniCardData card;
  final VoidCallback onOpen;

  bool _isHttpUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final lp = (card.localPath ?? '').trim();
    final url = (card.imageUrl ?? '').trim();

    // 診斷標籤（debug 用）
    String badge = 'UNK';

    Widget buildFromProvider(ImageProvider p, String b) {
      badge = b;
      return Image(
        image: p,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[Dex] Image error ($b)  id=${card.id} lp="$lp" url="$url"');
          }
          return const Icon(Icons.image_outlined, size: 48);
        },
      );
    }

    Widget img;

    if (kIsWeb) {
      // 先看 localPath
      final lpIsUrl = lp.startsWith('url:') ? lp.substring(4) : lp;
      if (_isHttpUrl(lpIsUrl)) {
        // 直接使用 NoCorsImage（你的版本沒有 onError/fallback 參數）
        badge = 'URL';
        img = NoCorsImage(lpIsUrl, fit: BoxFit.cover);
      } else if (_isHttpUrl(url)) {
        badge = 'URL';
        img = NoCorsImage(url, fit: BoxFit.cover);
      } else {
        // data:/assets/ 等由抽象層處理（data: 會變 MemoryImage）
        img = buildFromProvider(
          imageProviderOf(card),
          lp.startsWith('data:')
              ? 'DATA'
              : (lp.startsWith('assets/') ? 'ASSET' : 'MEM/PLH'),
        );
      }
    } else {
      // 非 Web：抽象 provider 自動處理 File / Network
      img = buildFromProvider(imageProviderOf(card), 'IO');
    }

    // Debug 診斷貼紙
    if (kDebugMode) {
      img = Stack(
        children: [
          Positioned.fill(child: img),
          Positioned(
            right: 6,
            bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
      ),
    );
  }
}

class _ScaffoldWrap extends StatelessWidget {
  const _ScaffoldWrap({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? child : Scaffold(body: child);
  }
}

// import 'dart:io' show File;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_learning_app/screens/card/detail/mini_cards/mini_cards_page.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_learning_app/l10n/l10n.dart';
// import 'package:flutter_learning_app/models/mini_card_data.dart';
// import 'package:flutter_learning_app/services/mini_cards/mini_card_store.dart';
// import 'package:flutter_learning_app/utils/no_cors_image/no_cors_image.dart';
// import 'package:flutter_learning_app/utils/dex/dex_idol_helper.dart';

// class DexView extends StatefulWidget {
//   const DexView({super.key});
//   @override
//   State<DexView> createState() => _DexViewState();
// }

// class _DexViewState extends State<DexView> {
//   String _query = '';

//   // 用「欄數」代表縮放（1~8 欄）
//   int _cols = 3;
//   static const _kMinCols = 1;
//   static const _kMaxCols = 8;

//   // 雙指縮放的累積器：避免每幀都變動欄數
//   double _scaleAccum = 1.0;
//   static const _kScaleStep = 1.15; // >1.15 視為放大一步；<1/1.15 視為縮小一步

//   void _zoomIn() =>
//       setState(() => _cols = (_cols - 1).clamp(_kMinCols, _kMaxCols));
//   void _zoomOut() =>
//       setState(() => _cols = (_cols + 1).clamp(_kMinCols, _kMaxCols));
//   void _zoomReset() => setState(() => _cols = 3);

//   @override
//   Widget build(BuildContext context) {
//     final l = context.l10n;
//     final store = context.watch<MiniCardStore>();
//     final List<MiniCardData> cards = store.cards;

//     if (cards.isEmpty) {
//       return _ScaffoldWrap(
//         title: l.dex_title,
//         child: Center(child: Text(l.dex_empty)),
//       );
//     }

//     // 依 idol 分組（同頁顯示）
//     final grouped = groupMiniCardsByIdol(
//       cards,
//       uncategorized: l.dex_uncategorized,
//     );

//     // 搜尋（偶像名 / 卡名 / 序號）
//     List<MapEntry<String, List<MiniCardData>>> entries = grouped.entries
//         .toList();
//     if (_query.trim().isNotEmpty) {
//       final q = _query.trim().toLowerCase();
//       entries = entries.where((e) {
//         final inGroupName = e.key.toLowerCase().contains(q);
//         final inCards = e.value.any(
//           (c) =>
//               (c.name ?? '').toLowerCase().contains(q) ||
//               (c.serial ?? '').toLowerCase().contains(q),
//         );
//         return inGroupName || inCards;
//       }).toList();
//     }
//     entries.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

//     final listView = ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       itemCount: entries.length,
//       itemBuilder: (_, i) {
//         final idol = entries[i].key;
//         final list = [...entries[i].value]
//           ..sort(
//             (a, b) => (a.name ?? a.id).toLowerCase().compareTo(
//               (b.name ?? b.id).toLowerCase(),
//             ),
//           );

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 區段標題
//             Padding(
//               padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
//               child: Text(
//                 '$idol · ${l.dex_cardsCount(list.length)}',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//             ),
//             const Divider(height: 8),

//             // 這組的 Grid（跟著 _cols 變化）
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: _cols,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 3 / 4,
//               ),
//               itemCount: list.length,
//               itemBuilder: (_, j) {
//                 final card = list[j];
//                 return _MiniCardTile(
//                   card: card,
//                   // ✅ 點擊直接進入詳細頁（MiniCardsPage）
//                   onOpen: () async {
//                     final updated = await Navigator.of(context)
//                         .push<List<MiniCardData>>(
//                           MaterialPageRoute(
//                             builder: (_) => MiniCardsPage(
//                               title: idol, // 顯示這組的標題
//                               cards: list, // 整組卡片可左右切換、翻面
//                               initialIndex: j, // 進場就定位到點擊的那張
//                             ),
//                           ),
//                         );
//                     if (updated != null) {
//                       // ⭐ 用 Store 的官方 API 整組覆蓋（含持久化、補 idol）
//                       await context.read<MiniCardStore>().replaceCardsForIdol(
//                         idol: idol,
//                         next: updated,
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );

//     // 全域縮放控制
//     final zoomControls = Positioned(
//       right: 12,
//       bottom: 18,
//       child: Material(
//         color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
//         elevation: 3,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(6),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _IconSquareButton(
//                 icon: Icons.zoom_in,
//                 tooltip: l.zoomIn,
//                 onTap: _zoomIn,
//               ),
//               const SizedBox(height: 8),
//               _IconSquareButton(
//                 icon: Icons.zoom_out,
//                 tooltip: l.zoomOut,
//                 onTap: _zoomOut,
//               ),
//               const SizedBox(height: 8),
//               _IconSquareButton(
//                 icon: Icons.aspect_ratio,
//                 tooltip: l.resetZoom,
//                 onTap: _zoomReset,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     // 鍵盤快捷鍵（Web/桌面）
//     final shortcuts = <LogicalKeySet, Intent>{
//       LogicalKeySet(LogicalKeyboardKey.equal, LogicalKeyboardKey.shift):
//           const _ZoomInIntent(),
//       LogicalKeySet(LogicalKeyboardKey.add): const _ZoomInIntent(),
//       LogicalKeySet(LogicalKeyboardKey.numpadAdd): const _ZoomInIntent(),
//       LogicalKeySet(LogicalKeyboardKey.minus): const _ZoomOutIntent(),
//       LogicalKeySet(LogicalKeyboardKey.numpadSubtract): const _ZoomOutIntent(),
//       LogicalKeySet(LogicalKeyboardKey.digit0): const _ZoomResetIntent(),
//       LogicalKeySet(LogicalKeyboardKey.numpad0): const _ZoomResetIntent(),
//     };
//     final actions = <Type, Action<Intent>>{
//       _ZoomInIntent: CallbackAction<_ZoomInIntent>(onInvoke: (_) => _zoomIn()),
//       _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
//         onInvoke: (_) => _zoomOut(),
//       ),
//       _ZoomResetIntent: CallbackAction<_ZoomResetIntent>(
//         onInvoke: (_) => _zoomReset(),
//       ),
//     };

//     final content = Stack(
//       children: [
//         // 外層手勢：雙指縮放；雙擊重設
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onDoubleTap: _zoomReset,
//           onScaleStart: (_) => _scaleAccum = 1.0,
//           onScaleUpdate: (details) {
//             _scaleAccum *= details.scale;
//             if (_scaleAccum > _kScaleStep) {
//               _scaleAccum = 1.0;
//               _zoomIn(); // 放大 → 欄數減少
//             } else if (_scaleAccum < 1 / _kScaleStep) {
//               _scaleAccum = 1.0;
//               _zoomOut(); // 縮小 → 欄數增加
//             }
//           },
//           child: listView,
//         ),
//         zoomControls,
//       ],
//     );

//     return _ScaffoldWrap(
//       title: l.dex_title,
//       child: Column(
//         children: [
//           // 搜尋列
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: l.dex_searchHint,
//                 prefixIcon: const Icon(Icons.search),
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//                 isDense: true,
//               ),
//               onChanged: (v) => setState(() => _query = v),
//             ),
//           ),

//           // 內容＋快捷鍵
//           Expanded(
//             child: Shortcuts(
//               shortcuts: shortcuts,
//               child: Actions(
//                 actions: actions,
//                 child: Focus(autofocus: true, child: content),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ====== Intent / UI 小元件 ======

// class _ZoomInIntent extends Intent {
//   const _ZoomInIntent();
// }

// class _ZoomOutIntent extends Intent {
//   const _ZoomOutIntent();
// }

// class _ZoomResetIntent extends Intent {
//   const _ZoomResetIntent();
// }

// class _IconSquareButton extends StatelessWidget {
//   const _IconSquareButton({
//     required this.icon,
//     required this.onTap,
//     this.tooltip,
//   });

//   final IconData icon;
//   final VoidCallback onTap;
//   final String? tooltip;

//   @override
//   Widget build(BuildContext context) {
//     return Tooltip(
//       message: tooltip ?? '',
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           width: 40,
//           height: 40,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
//           child: Icon(icon, size: 22),
//         ),
//       ),
//     );
//   }
// }

// // ====== 單張小卡（只顯示圖；不顯示任何文字） ======

// class _MiniCardTile extends StatelessWidget {
//   const _MiniCardTile({required this.card, required this.onOpen});
//   final MiniCardData card;
//   final VoidCallback onOpen;

//   @override
//   Widget build(BuildContext context) {
//     final lp = (card.localPath ?? '').trim();
//     final url = (card.imageUrl ?? '').trim();

//     // 只顯示圖片（無文字、無標籤）
//     Widget img;
//     if (lp.isNotEmpty) {
//       if (lp.startsWith('assets/')) {
//         img = Image.asset(
//           lp,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) =>
//               const Icon(Icons.image_outlined, size: 48),
//         );
//       } else {
//         img = Image.file(
//           File(lp),
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) {
//             if (url.isNotEmpty) {
//               return kIsWeb
//                   ? NoCorsImage(url, fit: BoxFit.cover)
//                   : Image.network(url, fit: BoxFit.cover);
//             }
//             return const Icon(Icons.image_outlined, size: 48);
//           },
//         );
//       }
//     } else if (url.isNotEmpty) {
//       img = kIsWeb
//           ? NoCorsImage(url, fit: BoxFit.cover)
//           : Image.network(url, fit: BoxFit.cover);
//     } else {
//       img = const Icon(Icons.image_outlined, size: 48);
//     }

//     return Material(
//       color: Theme.of(context).colorScheme.surface,
//       elevation: 1,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onOpen, // ✅ 點擊開啟詳細頁（翻面/編輯都在那頁）
//         child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img),
//       ),
//     );
//   }
// }

// class _ScaffoldWrap extends StatelessWidget {
//   const _ScaffoldWrap({required this.title, required this.child});
//   final String title;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return kIsWeb ? child : Scaffold(body: child);
//   }
// }
