// lib/screens/detail/mini_cards/widgets/tool_card.dart
import 'package:flutter/material.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.onScan, required this.onEdit});
  final VoidCallback onScan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 480,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: _block(
                  context,
                  onScan,
                  Icons.qr_code_scanner,
                  '掃描 QR',
                  '掃描別人的小卡並加入收藏',
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _block(
                  context,
                  onEdit,
                  Icons.edit_note_outlined,
                  '編輯小卡',
                  '新增、修改或刪除小卡',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block(
    BuildContext c,
    VoidCallback onTap,
    IconData icon,
    String t1,
    String t2,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(c).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Theme.of(c).colorScheme.primary),
              const SizedBox(height: 8),
              Text(t1, style: Theme.of(c).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(t2, style: Theme.of(c).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
