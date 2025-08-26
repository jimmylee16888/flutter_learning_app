import 'package:flutter/material.dart';

class CardsView extends StatelessWidget {
  const CardsView({super.key, required this.cards});
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final n = cards.length;
    return Center(
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 0.8,
        child: _buildBody(n),
      ),
    );
  }

  Widget _buildBody(int n) {
    if (n == 0) return const Center(child: Text('沒有卡片'));

    if (n == 1) {
      return Center(child: SizedBox(width: 300, height: 200, child: cards[0]));
    }

    if (n == 2) {
      return Row(
        children: [
          Expanded(
            child: Padding(padding: const EdgeInsets.all(12), child: cards[0]),
          ),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(12), child: cards[1]),
          ),
        ],
      );
    }

    return GridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3 / 2.5,
      children: cards,
    );
  }
}
