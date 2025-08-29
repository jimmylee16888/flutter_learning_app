// lib/screens/detail/mini_cards/widgets/mini_card_front.dart
import 'package:flutter/material.dart';
import '../../../../models/mini_card_data.dart';
import '../../../../utils/mini_card_io.dart';

class MiniCardFront extends StatelessWidget {
  const MiniCardFront({super.key, required this.card});
  final MiniCardData card;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Image(image: imageProviderOf(card), fit: BoxFit.cover),
    );
  }
}
