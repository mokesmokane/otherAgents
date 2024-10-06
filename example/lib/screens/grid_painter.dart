import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  GridPainter({required this.cellSize, required this.showGrid});

  final double cellSize;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    // Add a black background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );
    if (!showGrid) return;

    final paint = Paint()
      ..color = Colors.pink.withOpacity(0.5)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}