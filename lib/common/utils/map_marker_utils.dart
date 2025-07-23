import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerUtils {
  /// Create a custom marker for the current location
  static Future<BitmapDescriptor> createCurrentLocationMarker() async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 150.0;
    
    // Draw outer circle (blue with transparency)
    final Paint outerCirclePaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, outerCirclePaint);
    
    // Draw middle circle (blue with more opacity)
    final Paint middleCirclePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 3, middleCirclePaint);
    
    // Draw inner circle (solid blue)
    final Paint innerCirclePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 6, innerCirclePaint);
    
    // Draw white dot in center
    final Paint centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 12, centerDotPaint);
    
    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8List);
  }
  
  /// Create a custom marker for the route points
  static Future<BitmapDescriptor> createRoutePointMarker({
    required bool isOrigin,
    String? label,
  }) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 120.0;
    final Color color = isOrigin ? Colors.blue : Colors.red;
    
    // Draw shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(const Offset(size / 2, size / 2 + 4), size / 4, shadowPaint);
    
    // Draw pin circle
    final Paint circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 4, circlePaint);
    
    // Draw white border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 4, borderPaint);
    
    // Draw icon
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: isOrigin ? 'A' : 'B',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - textPainter.height / 2,
      ),
    );
    
    // Add label if provided
    if (label != null) {
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      
      // Draw label background
      final Paint bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final double labelWidth = labelPainter.width + 8;
      final double labelHeight = labelPainter.height + 4;
      final Rect bgRect = Rect.fromLTWH(
        size / 2 - labelWidth / 2,
        size / 2 + size / 4 + 8,
        labelWidth,
        labelHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        bgPaint,
      );
      
      // Draw label text
      labelPainter.paint(
        canvas,
        Offset(
          size / 2 - labelPainter.width / 2,
          size / 2 + size / 4 + 10,
        ),
      );
    }
    
    // Convert to image
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      return isOrigin
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    
    final Uint8List uint8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(uint8List);
  }
}
