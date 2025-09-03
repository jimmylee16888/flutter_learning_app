import 'package:flutter/material.dart';

class Heart {
  Heart({
    required this.pos,
    required this.vel,
    required this.size,
    required this.life,
    required this.color,
  });

  Offset pos;
  Offset vel;
  double size;
  double life; // 0..1
  Color color;
}

class HeartsPainter extends CustomPainter {
  HeartsPainter(this.hearts);
  final List<Heart> hearts;

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in hearts) {
      final paint = Paint()
        ..color = h.color.withOpacity(h.life.clamp(0, 1))
        ..style = PaintingStyle.fill;

      final path = _heartPath(h.size);
      canvas.save();
      canvas.translate(h.pos.dx, h.pos.dy);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  Path _heartPath(double s) {
    final Path p = Path();
    final double r = s / 2;
    p.moveTo(0, r * 0.9);
    p.cubicTo(-r * 2, -r * 0.6, -r * 0.6, -r * 2, 0, -r * 0.8);
    p.cubicTo(r * 0.6, -r * 2, r * 2, -r * 0.6, 0, r * 0.9);
    return p;
  }

  @override
  bool shouldRepaint(covariant HeartsPainter oldDelegate) =>
      oldDelegate.hearts != hearts;
}
