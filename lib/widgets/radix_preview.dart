import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A visual Radix scaffold. Planet positions and aspect lines are intentionally
/// absent until they come from the verified calculation engine.
class RadixPreview extends StatelessWidget {
  const RadixPreview({super.key, this.size = 340});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadixPainter(),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFE5C98F), size: 30),
              SizedBox(height: 7),
              Text(
                'DEIN RADIX',
                style: TextStyle(
                  color: Color(0xFFE5C98F),
                  letterSpacing: 2.4,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dein Himmelsbild entsteht hier',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB8B0A2), fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadixPainter extends CustomPainter {
  static const _gold = Color(0xFFC7A66A);
  static const _mutedGold = Color(0xFF806B4B);
  static const _signs = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
  static const _colors = [
    Color(0xFFE0A36F), Color(0xFF9BB9A0), Color(0xFFE0A36F),
    Color(0xFF9BB9A0), Color(0xFFE0A36F), Color(0xFF9BB9A0),
    Color(0xFFE0A36F), Color(0xFF9BB9A0), Color(0xFFE0A36F),
    Color(0xFF9BB9A0), Color(0xFFE0A36F), Color(0xFF9BB9A0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .47;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final background = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF233653), Color(0xFF111D31), Color(0xFF0B1424)],
        stops: [0, .72, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, background);

    final starPaint = Paint()..color = const Color(0x66E8D8B8);
    for (var i = 0; i < 54; i++) {
      final angle = i * 2.399963;
      final distance = radius * (.12 + ((i * 37) % 83) / 100);
      final point = center + Offset(math.cos(angle) * distance, math.sin(angle) * distance);
      canvas.drawCircle(point, i % 7 == 0 ? 1.25 : .65, starPaint);
    }

    final ringPaint = Paint()
      ..color = _mutedGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final r in [radius, radius * .88, radius * .66, radius * .34, radius * .16]) {
      canvas.drawCircle(center, r, ringPaint);
    }

    final spokePaint = Paint()
      ..color = const Color(0xFF9A8769)
      ..strokeWidth = .75;
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + i * math.pi / 6;
      final inner = center + Offset(math.cos(angle) * radius * .34, math.sin(angle) * radius * .34);
      final outer = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawLine(inner, outer, spokePaint);
    }

    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i + .5) * math.pi / 6;
      final point = center + Offset(math.cos(angle) * radius * .77, math.sin(angle) * radius * .77);
      _drawText(canvas, _signs[i], point, _colors[i], 19, FontWeight.w400);
      final houseAngle = -math.pi / 2 + i * math.pi / 6;
      final housePoint = center + Offset(math.cos(houseAngle) * radius * .48, math.sin(houseAngle) * radius * .48);
      _drawText(canvas, '${i + 1}', housePoint, const Color(0xFFB8AA91), 9, FontWeight.w400);
    }

    final tickPaint = Paint()..color = const Color(0xFFB9A27A)..strokeWidth = .7;
    for (var i = 0; i < 120; i++) {
      final angle = -math.pi / 2 + i * math.pi / 60;
      final outerR = radius * .88;
      final innerR = radius * (i % 10 == 0 ? .84 : .86);
      canvas.drawLine(
        center + Offset(math.cos(angle) * innerR, math.sin(angle) * innerR),
        center + Offset(math.cos(angle) * outerR, math.sin(angle) * outerR),
        tickPaint,
      );
    }

    final centerPaint = Paint()..color = const Color(0xFF17263D);
    canvas.drawCircle(center, radius * .155, centerPaint);
    canvas.drawCircle(center, radius * .155, Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1);
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color,
      double fontSize, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RadixPainter oldDelegate) => false;
}
