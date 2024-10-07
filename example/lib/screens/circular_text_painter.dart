import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularTextPainter extends CustomPainter {
  final String text;
  final Color color;
  final double radius;

  CircularTextPainter({required this.text, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final textStyle = TextStyle(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double textWidth = textPainter.width;
    final double circumference = 2 * math.pi * (radius + 5); // Reduced padding
    final int maxChars = (circumference / (textWidth / text.length)).floor();
    final String displayText = text.length > maxChars ? text.substring(0, maxChars) + '...' : text;

    // Adjust this value to change letter spacing (smaller value = less space)
    final double letterSpacing = 6;
    
    final double totalAngle = (displayText.length * letterSpacing) / radius;
    final double startAngle = -math.pi / 2 - totalAngle / 2;

    for (int i = 0; i < displayText.length; i++) {
      final double angle = startAngle + (i * letterSpacing) / radius;
      final double x = centerX + (radius + 5) * math.cos(angle); // Reduced padding
      final double y = centerY + (radius + 5) * math.sin(angle); // Reduced padding

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2);

      textPainter.text = TextSpan(text: displayText[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}