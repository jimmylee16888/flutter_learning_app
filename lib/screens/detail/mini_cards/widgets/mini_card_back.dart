// lib/screens/detail/mini_cards/widgets/mini_card_back.dart
import 'package:flutter/material.dart';

class MiniCardBack extends StatelessWidget {
  const MiniCardBack({super.key, required this.text, required this.date});
  final String text;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(d, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
