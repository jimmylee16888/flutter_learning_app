import 'package:flutter/material.dart';

/// 一般卡片：可拖曳；長按顯示工具（刪除/縮放把手）
/// - onDragUpdate：拖曳卡片位置時回傳 delta
/// - onResize：拖曳右下角把手時回傳 delta（為 null 表示不支援調整大小）
/// - deletable：是否可刪
/// - onDelete：刪除回調（deletable=true 時才會顯示）
class DraggableCard extends StatefulWidget {
  const DraggableCard({
    super.key,
    required this.child,
    required this.onDragUpdate,
    required this.deletable,
    this.onDelete,
    this.onResize,
    this.radius = 20,
  });

  final Widget child;
  final ValueChanged<Offset> onDragUpdate;
  final bool deletable;
  final VoidCallback? onDelete;
  final ValueChanged<Offset>? onResize;
  final double radius;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  bool _showTools = false;
  bool _resizing = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;

    return GestureDetector(
      onLongPress: () => setState(() => _showTools = !_showTools),
      onPanUpdate: (d) {
        // 若正在拉把手，就不要同時搬移卡片
        if (_resizing) return;
        widget.onDragUpdate(d.delta);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 卡片本體 + 陰影
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              boxShadow: [BoxShadow(blurRadius: 12, offset: const Offset(0, 8), color: Colors.black.withOpacity(0.12))],
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(r), child: widget.child),
          ),

          // 右上角：刪除鈕（長按才顯示）
          if (_showTools && widget.deletable && widget.onDelete != null)
            Positioned(
              right: 6,
              top: 6,
              child: _ToolButton(icon: Icons.close_rounded, onTap: widget.onDelete!),
            ),

          // 右下角：縮放把手（長按才顯示）
          if (_showTools && widget.onResize != null)
            Positioned(
              right: 2,
              bottom: 2,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _resizing = true),
                onPanUpdate: (d) => widget.onResize!(d.delta),
                onPanEnd: (_) => setState(() => _resizing = false),
                child: const _ResizeGrip(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35), // 低對比
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _ResizeGrip extends StatelessWidget {
  const _ResizeGrip();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28), // 低對比
      shape: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(6),
        // 斜向放大縮小的感覺，之前常用的圖標
        child: Icon(Icons.open_in_full_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}
