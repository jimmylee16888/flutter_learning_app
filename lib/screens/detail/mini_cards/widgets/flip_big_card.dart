// lib/screens/detail/mini_cards/widgets/flip_big_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipBigCard extends StatefulWidget {
  const FlipBigCard({super.key, required this.front, required this.back});
  final Widget front;
  final Widget back;

  @override
  State<FlipBigCard> createState() => _FlipBigCardState();
}

class _FlipBigCardState extends State<FlipBigCard> {
  bool _showFront = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFront = !_showFront),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _showFront ? 0 : 1),
        duration: const Duration(milliseconds: 350),
        builder: (_, v, __) {
          final angle = v * math.pi;
          final isFront = v < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
