import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class DecibelometerPainter extends CustomPainter {
  DecibelometerPainter({this.level, this.levelRecord});

  final double level;
  final double levelRecord;
  static const double OUTER_CIRCLE_STROKE = 2.5;
  static const Color OUTER_CIRCLE_COLOR = Colors.green;
  static const int MAX_LEVEL = 100;
  static const double MAX_ARC = 0.7;
  static const double MIN_ARC = 0.1;
  static const double INCREMENT = 0.01;

  Size size;
  Canvas canvas;
  Offset center;
  Paint paintObject;

  @override
  void paint(Canvas canvas, Size size) {
    _init(canvas, size);
    _drawOuterCircle();
    _drawInnerCircle();
    _drawMarkers();
    _drawValueIndicators(size);
    _drawNeedle(0.15 + (levelRecord / 100), Colors.white54, size.width / 120);
    _drawNeedle(0.15 + (level / 100), Colors.red, size.width / 70);
    _drawNeedleHolder();
    _drawLevel();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void _init(Canvas canvas, Size size) {
    this.canvas = canvas;
    this.size = size;
    center = size.center(Offset.zero);
    paintObject = Paint();
  }

  void _drawOuterCircle() {
    paintObject
      ..color = OUTER_CIRCLE_COLOR
      ..strokeWidth = OUTER_CIRCLE_STROKE
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.2, paintObject);
  }

  void _drawInnerCircle() {
    paintObject
      ..color = OUTER_CIRCLE_COLOR.withOpacity(0.4)
      ..strokeWidth = OUTER_CIRCLE_STROKE / 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 4, paintObject);
  }

  void _drawMarkers() {
    paintObject.style = PaintingStyle.fill;
    for (double relativeRotation = MIN_ARC;
        relativeRotation <= MAX_ARC + MIN_ARC + INCREMENT;
        relativeRotation += INCREMENT) {
      double normalizedDouble =
          double.parse((relativeRotation - MIN_ARC).toStringAsFixed(2));
      print("Value: $normalizedDouble");
      int normalizedPercentage = (normalizedDouble * 100).toInt();
      bool isBigMarker = normalizedPercentage % 10 == 0;
      _drawRotated(relativeRotation, () => _drawMarker(isBigMarker));
      if (isBigMarker)
        _drawRotated(
            relativeRotation,
            () => _drawSpeedScaleText(
                relativeRotation, normalizedPercentage.toString()));
    }
  }

  void _drawRotated(double angle, Function drawFunction) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * pi * 2);
    canvas.translate(-center.dx, -center.dy);
    drawFunction();
    canvas.restore();
  }

  void _drawMarker(bool isBigMarker) {
    paintObject
      ..color = Colors.red
      ..shader = null;
    Path markerPath = Path()
      ..addRect(Rect.fromLTRB(
        center.dx - size.width / (isBigMarker ? 200 : 300),
        center.dy + (size.width / 2.2),
        center.dx + size.width / (isBigMarker ? 200 : 300),
        center.dy + (size.width / (isBigMarker ? 2.5 : 2.35)),
      ));
    canvas.drawPath(markerPath, paintObject);
  }

  void _drawSpeedScaleText(double rotation, String text) {
    TextSpan span = new TextSpan(
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: size.width / 20),
        text: text);
    TextPainter textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();
    final textCenter = Offset(
        center.dx, size.width - (size.width / 5.5) + (textPainter.width / 2));
    final textTopLeft = Offset(textCenter.dx - (textPainter.width / 2),
        textCenter.dy - (textPainter.height / 2));
    canvas.save();
    canvas.translate(textCenter.dx, textCenter.dy);
    canvas.rotate(-rotation * pi * 2);
    canvas.translate(-textCenter.dx, -textCenter.dy);
    textPainter.paint(canvas, textTopLeft);
    canvas.restore();
  }

  void _drawValueIndicators(Size size) {
    for (double percentage = 0.15;
        percentage <= 0.85;
        percentage += 4 / (size.width)) {
      _drawSpeedIndicator(percentage);
    }

    for (double percentage = 0.15;
        percentage < 0.15 + (level / 100);
        percentage += 4 / (size.width)) {
      _drawSpeedIndicator(percentage, true);
    }
  }

  void _drawSpeedIndicator(double relativeRotation, [bool highlight = false]) {
    paintObject.shader = null;
    paintObject.strokeWidth = 1;
    paintObject.style = PaintingStyle.stroke;
    paintObject.color = Colors.white54;

    if (highlight) {
      paintObject.color = Color.lerp(
          Colors.yellow, Colors.red, (relativeRotation - 0.15) / 0.7);
      paintObject.style = PaintingStyle.fill;
    }

    Path markerPath = Path()
      ..addRect(Rect.fromLTRB(
          center.dx - size.width / 40,
          size.width - (size.width / 30),
          center.dx,
          size.width - (size.width / 100)));

    _drawRotated(relativeRotation, () {
      canvas.drawPath(markerPath, paintObject);
    });
  }

  void _drawNeedle(double rotation, Color color, double width) {
    paintObject
      ..style = PaintingStyle.fill
      ..color = color;
    Path needlePath = Path()
      ..moveTo(center.dx - width, center.dy)
      ..lineTo(center.dx + width, center.dy)
      ..lineTo(center.dx, center.dy + size.width / 2.5)
      ..moveTo(center.dx - width, center.dy);
    _drawRotated(rotation, () {
      canvas.drawPath(needlePath, paintObject);
    });
  }

  void _drawNeedleHolder() {
    RadialGradient gradient = RadialGradient(
        colors: [Colors.orange, Colors.red, Colors.red, Colors.black],
        radius: 1.2,
        stops: [0.0, 0.7, 0.9, 1.0]);
    paintObject
      ..color = Colors.blueGrey
      ..shader = gradient.createShader(Rect.fromCenter(
          center: center, width: size.width / 20, height: size.width / 20));
    canvas.drawCircle(size.center(Offset.zero), size.width / 15, paintObject);
  }

  void _drawLevel() {
    TextSpan span = new TextSpan(
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: size.width / 12),
        text: '${level.toStringAsFixed(0)}');
    TextPainter textPainter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();
    final textCenter = Offset(
        center.dx, center.dy + (size.width / 10) + (textPainter.width / 2));
    final textTopLeft = Offset(textCenter.dx - (textPainter.width / 2),
        textCenter.dy - (textPainter.width / 2));
    textPainter.paint(canvas, textTopLeft);
  }
}
