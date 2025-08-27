import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/mini_card_data.dart';

/// QrHubPage：可切換「掃描」與「分享」兩個分頁
class QrHubPage extends StatefulWidget {
  const QrHubPage({
    super.key,
    required this.ownerTitle, // 例如 idol 名稱
    required this.cards, // 本地小卡清單
    required this.onImport, // 掃描成功後的匯入回呼
  });

  final String ownerTitle;
  final List<MiniCardData> cards;
  final Future<bool> Function(MiniCardData newCard) onImport;

  @override
  State<QrHubPage> createState() => _QrHubPageState();
}

class _QrHubPageState extends State<QrHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tc = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR 工具'),
        bottom: TabBar(
          controller: _tc,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: '掃描'),
            Tab(icon: Icon(Icons.ios_share), text: '分享'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tc,
        children: [
          _ScanTab(onImport: widget.onImport),
          _ShareTab(ownerTitle: widget.ownerTitle, cards: widget.cards),
        ],
      ),
    );
  }
}

/* -------------------- 分頁 1：掃描 -------------------- */
class _ScanTab extends StatefulWidget {
  const _ScanTab({required this.onImport});
  final Future<bool> Function(MiniCardData newCard) onImport;

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) async {
            if (_handled) return;
            final barcode = capture.barcodes.isNotEmpty
                ? capture.barcodes.first
                : null;
            final raw = barcode?.rawValue;
            if (raw == null) return;

            try {
              final payload = jsonDecode(raw) as Map<String, dynamic>;
              if (payload['type'] != 'mini_card_v1' ||
                  payload['card'] == null) {
                _snack(context, 'QR 格式不符');
                return;
              }
              final newCard = MiniCardData.fromJson(
                Map<String, dynamic>.from(payload['card']),
              );

              _handled = true;
              final ok = await widget.onImport(newCard);
              if (!mounted) return;
              _snack(context, ok ? '已匯入小卡並儲存' : '已存在或失敗');
            } catch (_) {
              // 忽略解析錯，讓使用者繼續掃
            } finally {
              Future.delayed(
                const Duration(milliseconds: 1500),
                () => _handled = false,
              );
            }
          },
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/* -------------------- 分頁 2：分享（選小卡→顯示 QR） -------------------- */
class _ShareTab extends StatelessWidget {
  const _ShareTab({required this.ownerTitle, required this.cards});
  final String ownerTitle;
  final List<MiniCardData> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return Center(
        child: Text('目前沒有小卡可分享', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) {
        final c = cards[i];
        return GestureDetector(
          onTap: () => _showQr(context, ownerTitle, c),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(c.imageUrl, fit: BoxFit.cover),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: Text(
                        c.note.isEmpty ? '(點我分享 QR)' : c.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQr(BuildContext context, String ownerTitle, MiniCardData card) {
    final payload = {
      'type': 'mini_card_v1',
      'owner': ownerTitle,
      'card': card.toJson(),
    };
    final data = jsonEncode(payload);

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('分享小卡 QR'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 240,
                gapless: false,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                '對方掃描後即可將此小卡加入裝置',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
}
