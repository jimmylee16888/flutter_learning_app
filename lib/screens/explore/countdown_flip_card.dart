import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'explore_item.dart';

class CountdownFlipCard extends StatelessWidget {
  const CountdownFlipCard({
    super.key,
    required this.item,
    required this.bg,
    required this.radius,
    required this.onToggle,
  });

  final ExploreItem item;
  final Color bg;
  final double radius;
  final VoidCallback onToggle;

  String _weekdayZh(int wd) {
    const w = ['一', '二', '三', '四', '五', '六', '日'];
    return w[(wd + 6) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = item.countdownDate;
    final now = DateTime.now();

    final days = d == null
        ? null
        : (DateTime(
            d.year,
            d.month,
            d.day,
          ).difference(DateTime(now.year, now.month, now.day)).inDays);

    final left = days;
    final isPast = (left ?? 0) < 0;
    final absDays = left == null ? '—' : left!.abs().toString();
    final urgent = (left != null && left! <= 7 && left! >= 0);
    final accent = urgent ? cs.error : cs.primary;
    final dateText = d == null
        ? '未設定日期'
        : '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}（週${_weekdayZh(d.weekday)}）';

    return GestureDetector(
      onTap: onToggle,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: item.isBack ? 1 : 0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        builder: (context, t, _) {
          final angle = t * math.pi;
          final isBack = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  gradient: isBack
                      ? null
                      : LinearGradient(
                          colors: [bg, bg.withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: isBack
                    ? _buildBack(context, dateText, cs)
                    : _buildFront(context, absDays, isPast, accent, cs),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(
    BuildContext context,
    String absDays,
    bool isPast,
    Color accent,
    ColorScheme cs,
  ) {
    return Stack(
      children: [
        Positioned(
          right: -6,
          bottom: -6,
          child: Icon(
            Icons.cake_rounded,
            size: 84,
            color: cs.onPrimaryContainer.withOpacity(0.08),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cake_outlined, size: 16, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        '倒數',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPast ? '已過 $absDays 天' : '剩 $absDays 天',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                  color: cs.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              if ((item.title ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    item.title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onPrimaryContainer.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context, String dateText, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, color: cs.onSurface.withOpacity(0.8)),
          const SizedBox(height: 6),
          Text(
            dateText,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          if ((item.title ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.title!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
