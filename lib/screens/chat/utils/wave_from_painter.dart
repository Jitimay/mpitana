import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 2.0;
    final barSpacing = 3.0;
    final barCount = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + barSpacing);
      final height = (i < barCount * 0.6) ? size.height * 0.8 : size.height * 0.4;
      final y = (size.height - height) / 2;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}