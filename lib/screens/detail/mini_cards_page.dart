// // lib/screens/detail/mini_cards_page.dart
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart' as ms;
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
//     as ml;

// import 'package:qr_flutter/qr_flutter.dart';

// import '../../models/mini_card_data.dart';
// import 'edit_mini_cards_page.dart';

// import 'dart:io' show gzip; // 用於壓縮
// import 'package:flutter_learning_app/utils/mini_card_io.dart';

// class MiniCardsPage extends StatefulWidget {
//   const MiniCardsPage({
//     super.key,
//     required this.title,
//     required this.cards,
//     this.initialIndex = 0,
//   });

//   final String title;
//   final List<MiniCardData> cards;
//   final int initialIndex;

//   @override
//   State<MiniCardsPage> createState() => _MiniCardsPageState();
// }

// class _MiniCardsPageState extends State<MiniCardsPage> {
//   late List<MiniCardData> _cards = List.of(widget.cards);

//   int get _pageCount => _cards.length + 2;

//   int _computeInitialPage() {
//     if (_cards.isEmpty) return 0;
//     final want = widget.initialIndex + 1;
//     return want.clamp(1, _pageCount - 2);
//   }

//   late final PageController _pc = PageController(
//     initialPage: _computeInitialPage(),
//     viewportFraction: 0.78,
//   );

//   double _page = 1.0;

//   int _currentPageRound() {
//     if (_pc.hasClients && _pc.page != null) return _pc.page!.round();
//     return _pc.initialPage;
//   }

//   bool get _isAtLeftTool => _currentPageRound() == 0;
//   bool get _isAtRightTool => _currentPageRound() == _pageCount - 1;

//   @override
//   void initState() {
//     super.initState();
//     _page = _pc.initialPage.toDouble();

//     double last = _page;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       _pc.addListener(() {
//         if (!_pc.hasClients) return;
//         final p = _pc.page ?? last;
//         if ((p - last).abs() > 0.01) {
//           last = p;
//           if (mounted) setState(() => _page = p);
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _pc.dispose();
//     super.dispose();
//   }

//   Future<bool> _popWithResult() async {
//     Navigator.pop(context, _cards); // 帶著最新小卡清單返回
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final title = widget.title;

//     return WillPopScope(
//       onWillPop: _popWithResult, // Android 實體返回鍵
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('$title 的小卡'),
//           leading: BackButton(onPressed: () => Navigator.pop(context, _cards)),
//           // ← 不再顯示「完成」按鈕
//         ),
//         body: Column(
//           children: [
//             const SizedBox(height: 0),
//             Expanded(
//               child: PageView.builder(
//                 controller: _pc,
//                 itemCount: _pageCount,
//                 allowImplicitScrolling: true,
//                 itemBuilder: (context, i) {
//                   final scale = (1 - ((_page - i).abs() * 0.12)).clamp(
//                     0.86,
//                     1.0,
//                   );

//                   if (i == 0 || i == _pageCount - 1) {
//                     return Center(
//                       child: AnimatedScale(
//                         scale: scale,
//                         duration: const Duration(milliseconds: 200),
//                         child: _ToolCard(
//                           onScan: _scanAndImport,
//                           onEdit: () async {
//                             final updated = await Navigator.of(context)
//                                 .push<List<MiniCardData>>(
//                                   MaterialPageRoute(
//                                     builder: (_) =>
//                                         EditMiniCardsPage(initial: _cards),
//                                   ),
//                                 );
//                             if (updated != null && mounted) {
//                               setState(() => _cards = updated);
//                             }
//                           },
//                         ),
//                       ),
//                     );
//                   }

//                   final card = _cards[i - 1];
//                   return Center(
//                     child: AnimatedScale(
//                       scale: scale,
//                       duration: const Duration(milliseconds: 200),
//                       child: SizedBox(
//                         width: 320,
//                         height: 480,
//                         child: _FlipBigCard(
//                           front: _MiniCardFront(card: card),
//                           back: _MiniCardBack(
//                             text: card.note,
//                             date: card.createdAt,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 50),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             if (_isAtLeftTool) {
//               await _scanAndImport();
//               return;
//             }
//             if (_isAtRightTool) {
//               await _chooseAndShare(context);
//               return;
//             }
//             final idx = _currentPageRound() - 1;
//             if (idx >= 0 && idx < _cards.length) {
//               await _shareOptionsForCard(context, _cards[idx]);
//             }
//           },
//           icon: Icon(
//             _isAtLeftTool
//                 ? Icons.qr_code_scanner
//                 : _isAtRightTool
//                 ? Icons.qr_code_2
//                 : Icons.ios_share,
//           ),
//           label: Text(
//             _isAtLeftTool
//                 ? '掃描'
//                 : _isAtRightTool
//                 ? '分享'
//                 : '分享此卡',
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       ),
//     );
//   }

//   // ========= 掃描 =========
//   Future<void> _scanAndImport() async {
//     final controller = ms.MobileScannerController(
//       formats: const [ms.BarcodeFormat.qrCode],
//       detectionSpeed: ms.DetectionSpeed.normal,
//       detectionTimeoutMs: 500,
//       returnImage: false,
//     );

//     bool handled = false;

//     // 本地：相簿選圖並用 ML Kit 偵測 QR
//     Future<void> _scanFromGallery(BuildContext scanCtx) async {
//       try {
//         final picker = ImagePicker();
//         final XFile? img = await picker.pickImage(source: ImageSource.gallery);
//         if (img == null) return;

//         final scanner = ml.BarcodeScanner(formats: [ml.BarcodeFormat.qrCode]);
//         final input = ml.InputImage.fromFilePath(img.path);
//         final result = await scanner.processImage(input);
//         await scanner.close();

//         if (result.isEmpty || result.first.rawValue == null) {
//           if (scanCtx.mounted) {
//             ScaffoldMessenger.of(
//               scanCtx,
//             ).showSnackBar(const SnackBar(content: Text('圖片中未偵測到 QR')));
//           }
//           return;
//         }

//         final raw = result.first.rawValue!;
//         final map = _decodePackedJson(raw);
//         if (map == null ||
//             map['type'] != 'mini_card_v1' ||
//             map['card'] == null) {
//           if (scanCtx.mounted) {
//             ScaffoldMessenger.of(
//               scanCtx,
//             ).showSnackBar(const SnackBar(content: Text('QR 格式不符')));
//           }
//           return;
//         }

//         // ← 和相機掃描相同的匯入流程
//         final newCard = MiniCardData.fromJson(
//           Map<String, dynamic>.from(map['card']),
//         ).copyWith(createdAt: DateTime.now());

//         MiniCardData ready = newCard;
//         if ((ready.imageUrl ?? '').isNotEmpty) {
//           try {
//             final p = await downloadImageToLocal(
//               ready.imageUrl!,
//               preferName: ready.id,
//             );
//             ready = ready.copyWith(localPath: p);
//           } catch (_) {}
//         }

//         final exists = _cards.any((c) => c.id == ready.id);
//         final toInsert = exists
//             ? ready.copyWith(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//               )
//             : ready;

//         if (mounted) setState(() => _cards.add(toInsert));

//         if (scanCtx.mounted) {
//           ScaffoldMessenger.of(
//             scanCtx,
//           ).showSnackBar(const SnackBar(content: Text('已匯入小卡')));
//         }
//       } catch (e) {
//         if (scanCtx.mounted) {
//           ScaffoldMessenger.of(
//             scanCtx,
//           ).showSnackBar(SnackBar(content: Text('相簿掃描失敗：$e')));
//         }
//       }
//     }

//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (scanCtx) => WillPopScope(
//           onWillPop: () async {
//             try {
//               await controller.stop();
//             } catch (_) {}
//             controller.dispose();
//             return true;
//           },
//           child: Scaffold(
//             appBar: AppBar(
//               title: const Text('掃描小卡 QR'),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () async {
//                     try {
//                       await controller.stop();
//                     } catch (_) {}
//                     controller.dispose();
//                     if (scanCtx.mounted) Navigator.pop(scanCtx);
//                   },
//                 ),
//               ],
//             ),
//             body: Stack(
//               children: [
//                 ms.MobileScanner(
//                   controller: controller,
//                   onDetect: (ms.BarcodeCapture capture) async {
//                     if (handled) return;
//                     final code = capture.barcodes.isNotEmpty
//                         ? capture.barcodes.first.rawValue
//                         : null;
//                     if (code == null) return;

//                     try {
//                       final map = _decodePackedJson(code);
//                       if (map == null ||
//                           map['type'] != 'mini_card_v1' ||
//                           map['card'] == null) {
//                         if (scanCtx.mounted) {
//                           ScaffoldMessenger.of(scanCtx).showSnackBar(
//                             const SnackBar(content: Text('QR 格式不符')),
//                           );
//                         }
//                         return;
//                       }

//                       handled = true;
//                       try {
//                         await controller.stop();
//                       } catch (_) {}

//                       final newCard = MiniCardData.fromJson(
//                         Map<String, dynamic>.from(map['card']),
//                       ).copyWith(createdAt: DateTime.now());

//                       MiniCardData ready = newCard;
//                       if ((ready.imageUrl ?? '').isNotEmpty) {
//                         try {
//                           final p = await downloadImageToLocal(
//                             ready.imageUrl!,
//                             preferName: ready.id,
//                           );
//                           ready = ready.copyWith(localPath: p);
//                         } catch (_) {}
//                       }

//                       final exists = _cards.any((c) => c.id == ready.id);
//                       final toInsert = exists
//                           ? ready.copyWith(
//                               id: DateTime.now().millisecondsSinceEpoch
//                                   .toString(),
//                             )
//                           : ready;

//                       if (mounted) setState(() => _cards.add(toInsert));

//                       if (scanCtx.mounted) {
//                         ScaffoldMessenger.of(
//                           scanCtx,
//                         ).showSnackBar(const SnackBar(content: Text('已匯入小卡')));
//                         await Future.delayed(const Duration(milliseconds: 180));
//                         controller.dispose();
//                         Navigator.pop(scanCtx);
//                       }
//                     } catch (_) {
//                       // 忽略解析錯誤，繼續掃
//                     } finally {
//                       Future.delayed(const Duration(milliseconds: 1000), () {
//                         handled = false;
//                       });
//                     }
//                   },
//                 ),

//                 // 中間取景框
//                 Align(
//                   alignment: Alignment.center,
//                   child: Container(
//                     width: 240,
//                     height: 240,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Theme.of(scanCtx).colorScheme.primary,
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                 ),

//                 // 右下角：相簿掃描 + 手電筒
//                 Positioned(
//                   right: 12,
//                   bottom: 12,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       FloatingActionButton.extended(
//                         heroTag: 'pick_gallery_qr',
//                         onPressed: () => _scanFromGallery(scanCtx),
//                         icon: const Icon(Icons.photo_library_outlined),
//                         label: const Text('相簿掃描'),
//                       ),
//                       const SizedBox(height: 20),
//                       // FloatingActionButton(
//                       //   heroTag: 'toggle_torch',
//                       //   onPressed: () async {
//                       //     try {
//                       //       await controller.toggleTorch();
//                       //       if (scanCtx.mounted) {
//                       //         torchOn = !torchOn;
//                       //         // 想顯示狀態可 setState 包外層，但這裡只切換 icon 即可
//                       //       }
//                       //     } catch (_) {
//                       //       if (scanCtx.mounted) {
//                       //         ScaffoldMessenger.of(scanCtx).showSnackBar(
//                       //           const SnackBar(content: Text('此裝置不支援手電筒')),
//                       //         );
//                       //       }
//                       //     }
//                       //   },
//                       //   tooltip: torchOn ? '關閉手電筒' : '開啟手電筒',
//                       //   child: Icon(torchOn ? Icons.flash_on : Icons.flash_off),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ========= 分享（選一張 → 顯示 QR） =========
//   Future<void> _chooseAndShare(BuildContext context) async {
//     if (_cards.isEmpty) return;
//     final chosen = await showModalBottomSheet<MiniCardData>(
//       context: context,
//       showDragHandle: true,
//       builder: (_) => SafeArea(
//         child: SizedBox(
//           height: 360,
//           child: ListView.separated(
//             padding: const EdgeInsets.all(12),
//             itemCount: _cards.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 8),
//             itemBuilder: (context, i) {
//               final c = _cards[i];
//               final dpr = MediaQuery.of(context).devicePixelRatio;
//               return ListTile(
//                 leading: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image(
//                     image: imageProviderOf(c),
//                     width: 56,
//                     height: 56,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 title: Text(
//                   c.note.isEmpty ? '(無敘述)' : c.note,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 onTap: () => Navigator.pop(context, c),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//     if (chosen != null) {
//       await _shareOptionsForCard(context, chosen);
//     }
//   }

//   Future<void> _shareOptionsForCard(BuildContext ctx, MiniCardData c) async {
//     showModalBottomSheet(
//       context: ctx,
//       showDragHandle: true,
//       builder: (_) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if ((c.imageUrl ?? '').isNotEmpty)
//               ListTile(
//                 leading: const Icon(Icons.qr_code_2),
//                 title: const Text('分享「圖片網址」QR code'),
//                 onTap: () {
//                   Navigator.pop(ctx);
//                   _showQrForCard(ctx, widget.title, c);
//                 },
//               ),
//             ListTile(
//               leading: const Icon(Icons.ios_share),
//               title: const Text('直接分享整張照片'),
//               onTap: () async {
//                 Navigator.pop(ctx);
//                 try {
//                   await sharePhoto(c); // 會自動確保 localPath
//                 } catch (e) {
//                   if (mounted) {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(SnackBar(content: Text('分享失敗：$e')));
//                   }
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _showQrForCard(
//     BuildContext context,
//     String owner,
//     MiniCardData card,
//   ) async {
//     try {
//       if ((card.imageUrl ?? '').isEmpty) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('這張小卡沒有網址，改用「分享整張照片」喔')));
//         }
//         return;
//       }
//       final payload = {
//         'type': 'mini_card_v1',
//         'owner': owner,
//         'card': {'id': card.id, 'imageUrl': card.imageUrl, 'note': card.note},
//       };

//       final data = _encodePackedJson(payload);

//       if (data.length > 1800) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('QR 資料過長（${data.length}）無法生成')),
//           );
//         }
//         return;
//       }

//       final Uint8List? pngBytes = await _buildQrPngBytes(data, 240);
//       if (pngBytes == null) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text('生成 QR 影像失敗')));
//         }
//         return;
//       }

//       if (!context.mounted) return;

//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (dialogContext) => Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           insetPadding: const EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 24,
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     '小卡 QR code',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: UnconstrainedBox(
//                       child: Image.memory(
//                         pngBytes,
//                         width: 240,
//                         height: 240,
//                         filterQuality: FilterQuality.none,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '掃描後會將此小卡加入對方裝置',
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () => Navigator.of(dialogContext).pop(),
//                       child: const Text('關閉'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     } catch (e, st) {
//       debugPrint("❌ QR 生成例外: $e\n$st");
//       if (context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('生成 QR code 失敗：$e')));
//       }
//     }
//   }

//   Future<Uint8List?> _buildQrPngBytes(String data, double size) async {
//     try {
//       final painter = QrPainter(
//         data: data,
//         version: QrVersions.auto,
//         errorCorrectionLevel: QrErrorCorrectLevel.M,
//         gapless: false,
//         eyeStyle: const QrEyeStyle(
//           eyeShape: QrEyeShape.square,
//           color: Colors.black,
//         ),
//         dataModuleStyle: const QrDataModuleStyle(
//           dataModuleShape: QrDataModuleShape.square,
//           color: Colors.black,
//         ),
//       );
//       final ByteData? bd = await painter.toImageData(
//         size,
//         format: ui.ImageByteFormat.png,
//       );
//       return bd?.buffer.asUint8List();
//     } catch (e, st) {
//       debugPrint('❌ _buildQrPngBytes 失敗: $e\n$st');
//       return null;
//     }
//   }

//   String _encodePackedJson(Map<String, dynamic> obj) {
//     final raw = utf8.encode(jsonEncode(obj));
//     final gz = gzip.encode(raw);
//     return 'gz:' + base64UrlEncode(gz);
//   }

//   Map<String, dynamic>? _decodePackedJson(String s) {
//     try {
//       if (s.startsWith('gz:')) {
//         final gz = base64Url.decode(s.substring(3));
//         final raw = gzip.decode(gz);
//         return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
//       }
//       return jsonDecode(s) as Map<String, dynamic>;
//     } catch (_) {
//       return null;
//     }
//   }
// }

// /* ================= 視覺元件（與你原本相同） ================= */

// class _ToolCard extends StatelessWidget {
//   const _ToolCard({required this.onScan, required this.onEdit});
//   final VoidCallback onScan;
//   final VoidCallback onEdit;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 320,
//       height: 480,
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 8),
//               Expanded(
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(14),
//                   onTap: onScan,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.surfaceContainerHighest,
//                     ),
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.qr_code_scanner,
//                             size: 56,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '掃描 QR',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '掃描別人的小卡並加入收藏',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Expanded(
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(14),
//                   onTap: onEdit,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.surfaceContainerHighest,
//                     ),
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.edit_note_outlined,
//                             size: 56,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '編輯小卡',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             '新增、修改或刪除小卡',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FlipBigCard extends StatefulWidget {
//   const _FlipBigCard({required this.front, required this.back});
//   final Widget front;
//   final Widget back;

//   @override
//   State<_FlipBigCard> createState() => _FlipBigCardState();
// }

// class _FlipBigCardState extends State<_FlipBigCard> {
//   bool _showFront = true;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => setState(() => _showFront = !_showFront),
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0, end: _showFront ? 0 : 1),
//         duration: const Duration(milliseconds: 350),
//         builder: (context, val, child) {
//           final angle = val * math.pi;
//           final isFront = val < 0.5;
//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001)
//               ..rotateY(angle),
//             child: isFront
//                 ? widget.front
//                 : Transform(
//                     alignment: Alignment.center,
//                     transform: Matrix4.identity()..rotateY(math.pi),
//                     child: widget.back,
//                   ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _MiniCardFront extends StatelessWidget {
//   const _MiniCardFront({required this.card});
//   final MiniCardData card;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Image(image: imageProviderOf(card), fit: BoxFit.cover),
//     );
//   }
// }

// class _MiniCardBack extends StatelessWidget {
//   const _MiniCardBack({required this.text, required this.date});
//   final String text;
//   final DateTime date;

//   @override
//   Widget build(BuildContext context) {
//     final d =
//         '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
//         '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     return Card(
//       color: Theme.of(context).colorScheme.surfaceContainerHighest,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.description_outlined,
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               text,
//               maxLines: 6,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(d, style: Theme.of(context).textTheme.labelSmall),
//           ],
//         ),
//       ),
//     );
//   }
// }
