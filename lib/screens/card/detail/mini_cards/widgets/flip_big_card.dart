// lib/screens/detail/mini_cards/widgets/flip_big_card.dart
import 'dart:math' as math;
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

class _FlipBigCardState extends State<FlipBigCard> with SingleTickerProviderStateMixin {
  late bool _isFront = widget.initialFront;
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.initialFront ? 0.0 : 1.0,
  );
  late final Animation<double> _anim = CurvedAnimation(parent: _ctl, curve: Curves.easeInOut);

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

  @override
  Widget build(BuildContext context) {
    // 不註冊任何水平拖曳 → PageView 取得左右滑動；這裡只處理「點一下」翻面
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value; // 0(正面) ~ 1(背面)
        final angle = t * math.pi; // 0 → π
        final showingFront = angle <= math.pi / 2;

        final face = showingFront
            ? _Face(rotated: false, onTap: () => _flipTo(false), child: widget.front)
            : _Face(
                rotated: true, // 背面修正 180°
                onTap: () => _flipTo(true),
                child: widget.back,
              );

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 透視
            ..rotateY(angle),
          child: face,
        );
      },
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({required this.rotated, required this.onTap, required this.child});

  final bool rotated;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        onTap: onTap, // 單擊翻面
        child: child,
      ),
    );

    return rotated
        ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(math.pi), child: content)
        : content;
  }
}

// import 'dart:math' as math;
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';

// class FlipBigCard extends StatefulWidget {
//   const FlipBigCard({
//     super.key,
//     required this.front,
//     required this.back,
//     this.initialFront = true,
//     this.duration = const Duration(milliseconds: 320),
//   });

//   final Widget front;
//   final Widget back;
//   final bool initialFront;
//   final Duration duration;

//   @override
//   State<FlipBigCard> createState() => _FlipBigCardState();
// }

// class _FlipBigCardState extends State<FlipBigCard>
//     with SingleTickerProviderStateMixin {
//   late bool _isFront = widget.initialFront;
//   late final AnimationController _ctl = AnimationController(
//     vsync: this,
//     duration: widget.duration,
//   );
//   late final Animation<double> _anim = CurvedAnimation(
//     parent: _ctl,
//     curve: Curves.easeInOut,
//   );

//   @override
//   void initState() {
//     super.initState();
//     if (!_isFront) _ctl.value = 1.0;
//   }

//   @override
//   void dispose() {
//     _ctl.dispose();
//     super.dispose();
//   }

//   void _flipTo(bool front) {
//     if (_isFront == front) return;
//     setState(() => _isFront = front);
//     front ? _ctl.reverse() : _ctl.forward();
//   }

//   // 拖曳結束依速度決定翻面；不影響背面子元件（例如 IconButton）點擊
//   void _onHorizontalDragEnd(DragEndDetails d) {
//     final vx = d.velocity.pixelsPerSecond.dx;
//     if (vx.abs() < 120) return; // 太小當作沒拖
//     if (vx < 0) {
//       _flipTo(false); // 往左 → 背面
//     } else {
//       _flipTo(true); // 往右 → 正面
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 外層只接「水平拖曳」；單擊手勢分別放在前/背面容器內
//     return GestureDetector(
//       behavior: HitTestBehavior.deferToChild,
//       dragStartBehavior: DragStartBehavior.down,
//       onHorizontalDragEnd: _onHorizontalDragEnd,
//       child: AnimatedBuilder(
//         animation: _anim,
//         builder: (context, _) {
//           final t = _anim.value; // 0(正面) ~ 1(背面)
//           final angle = t * math.pi;
//           final showingFront = angle <= math.pi / 2;

//           final face = showingFront
//               ? _FrontFace(
//                   onTapShowBack: () => _flipTo(false),
//                   child: widget.front,
//                 )
//               : _BackFace(
//                   onTapShowFront: () => _flipTo(true),
//                   child: widget.back,
//                 );

//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..setEntry(3, 2, 0.001) // 透視
//               ..rotateY(angle),
//             child: face,
//           );
//         },
//       ),
//     );
//   }
// }

// /// 正面：單擊 → 顯示「背面」
// class _FrontFace extends StatelessWidget {
//   const _FrontFace({required this.onTapShowBack, required this.child});
//   final VoidCallback onTapShowBack;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     // opaque：點任意空白也能翻
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: onTapShowBack,
//       child: child,
//     );
//   }
// }

// /// 背面：單擊 → 回到「正面」
// /// 為了避免鏡像，做 180° 修正；包一層 GestureDetector 讓背面同樣可單擊切換。
// class _BackFace extends StatelessWidget {
//   const _BackFace({required this.onTapShowFront, required this.child});
//   final VoidCallback onTapShowFront;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Transform(
//       alignment: Alignment.center,
//       transform: Matrix4.identity()..rotateY(math.pi),
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: onTapShowFront,
//         child: child,
//       ),
//     );
//   }
// }
