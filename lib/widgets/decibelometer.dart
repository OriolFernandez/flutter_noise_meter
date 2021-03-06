import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noise_ambient/painter/decibelometer_painter.dart';

class Decibelometer extends StatelessWidget {
  Decibelometer(
      {@required this.level, @required this.levelRecord, this.size = 300});
  final double level;
  final double levelRecord;
  final double size;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: DecibelometerPainter(level: level, levelRecord: levelRecord),
        size: Size(size, size));
  }
}
