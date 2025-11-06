// lib/screens/detail/mini_cards/widgets/fullscreen_qr_viewer.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FullscreenQrViewer extends StatelessWidget {
  const FullscreenQrViewer({super.key, required this.bytes, required this.heroTag});

  final Uint8List bytes;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    // 黑底、沉浸式觀賞
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.close), tooltip: '關閉', onPressed: () => Navigator.of(context).maybePop()),
        ],
      ),
      body: SafeArea(
        child: Center(
          // 可雙指縮放/拖曳
          child: InteractiveViewer(
            minScale: 0.75,
            maxScale: 6.0,
            child: Hero(
              tag: heroTag,
              // 白底 + 內距，確保掃描器有足夠安靜區（quiet zone）
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(20),
                child: Image.memory(bytes, fit: BoxFit.contain, filterQuality: FilterQuality.none),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
