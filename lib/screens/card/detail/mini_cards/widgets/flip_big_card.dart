// lib/screens/detail/mini_cards/widgets/flip_big_card.dart
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class FlipBigCard extends StatefulWidget {
  const FlipBigCard({
    super.key,
    required this.front,
    required this.back,
    this.initialFront = true,
    this.duration = const Duration(milliseconds: 320),
  });

  final Widget front;
  final Widget back;
  final bool initialFront;
  final Duration duration;

  @override
  State<FlipBigCard> createState() => _FlipBigCardState();
}

class _FlipBigCardState extends State<FlipBigCard>
    with SingleTickerProviderStateMixin {
  late bool _isFront = widget.initialFront;
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _anim = CurvedAnimation(
    parent: _ctl,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    if (!_isFront) _ctl.value = 1.0;
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _flipTo(bool front) {
    if (_isFront == front) return;
    setState(() => _isFront = front);
    front ? _ctl.reverse() : _ctl.forward();
  }

  void _toggle() => _flipTo(!_isFront);

  // 拖曳結束依速度決定翻面；不影響背面 IconButton 點擊
  void _onHorizontalDragEnd(DragEndDetails d) {
    final vx = d.velocity.pixelsPerSecond.dx;
    if (vx.abs() < 120) return; // 太小當作沒拖
    if (vx < 0) {
      _flipTo(false); // 往左 → 背面
    } else {
      _flipTo(true); // 往右 → 正面
    }
  }

  @override
  Widget build(BuildContext context) {
    // 只在外層接「水平拖曳」與「雙擊」；單擊只掛在正面，不阻擋背面按鈕
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      dragStartBehavior: DragStartBehavior.down,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onDoubleTap: _toggle,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final t = _anim.value; // 0(正面) ~ 1(背面)
          final angle = t * math.pi;

          final showingFront = angle <= math.pi / 2;
          final face = showingFront
              ? _FrontFace(onTap: _toggle, child: widget.front)
              : _BackFace(child: widget.back);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 透視
              ..rotateY(angle),
            child: face,
          );
        },
      ),
    );
  }
}

/// 正面：可單擊翻面
class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}

/// 背面：為了避免鏡像，做 180° 修正；不攔截點擊，讓內部 IconButton 可用
class _BackFace extends StatelessWidget {
  const _BackFace({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(math.pi),
      child: child,
    );
  }
}
