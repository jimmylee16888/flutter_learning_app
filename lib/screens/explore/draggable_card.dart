import 'package:flutter/material.dart';

class DraggableCard extends StatefulWidget {
  const DraggableCard({
    super.key,
    required this.child,
    required this.onDragUpdate,
    required this.deletable,
    this.onDelete,
  });

  final Widget child;
  final ValueChanged<Offset> onDragUpdate;
  final bool deletable;
  final VoidCallback? onDelete;

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  bool _showDelete = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.deletable
          ? () => setState(() => _showDelete = !_showDelete)
          : null,
      onPanUpdate: (d) => widget.onDragUpdate(d.delta),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            child: widget.child,
          ),
          if (_showDelete && widget.deletable)
            Positioned(
              right: 6,
              top: 6,
              child: Material(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: widget.onDelete,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
