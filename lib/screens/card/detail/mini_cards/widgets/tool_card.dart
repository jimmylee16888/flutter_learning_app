// lib/screens/detail/mini_cards/widgets/tool_card.dart
import 'package:flutter/material.dart';
import '../../../../../l10n/l10n.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({super.key, required this.onScan, required this.onEdit});
  final VoidCallback onScan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

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
                  context: context,
                  onTap: onScan,
                  icon: Icons.qr_code_scanner,
                  title: l.scanMiniCardQrTitle, // e.g. "Scan mini card QR"
                  subtitle: l.scanFromGallery, // e.g. "Scan from gallery"
                  bg: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _block(
                  context: context,
                  onTap: onEdit,
                  icon: Icons.edit_note_outlined,
                  title: l.editMiniCards, // e.g. "Edit mini cards"
                  subtitle: l.manageCards, // e.g. "Manage cards"
                  bg: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bg,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: bg),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: cs.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
