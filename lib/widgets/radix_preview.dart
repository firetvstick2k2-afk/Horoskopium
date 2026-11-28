import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../domain/astrology/aspect_calculator.dart';
import '../domain/astrology/chart_calculation_result.dart';

/// Draws a data-driven Radix when calculation results are supplied.
class RadixPreview extends StatelessWidget {
  const RadixPreview({super.key, this.size = 340, this.result});
  final double size;
  final ChartCalculationResult? result;

  @override
  Widget build(BuildContext context) {
    final chart = result != null && result!.isValid ? result : null;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadixPainter(chart),
        child: chart == null && size >= 150
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome, color: Color(0xFFE5C98F), size: 30),
                SizedBox(height: 7),
                Text('DEIN RADIX', style: TextStyle(color: Color(0xFFE5C98F), letterSpacing: 2.4, fontSize: 10, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Dein Himmelsbild entsteht hier', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB8B0A2), fontSize: 9)),
              ]))
            : null,
      ),
    );
  }
}

class _RadixPainter extends CustomPainter {
  _RadixPainter(this.chart);
  final ChartCalculationResult? chart;

  static const _gold = Color(0xFFC7A66A);
  static const _signs = ['♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓'];
  static const _colors = [
    Color(0xFFE0A36F),Color(0xFF9BB9A0),Color(0xFFE0A36F),Color(0xFF9BB9A0),
    Color(0xFFE0A36F),Color(0xFF9BB9A0),Color(0xFFE0A36F),Color(0xFF9BB9A0),
    Color(0xFFE0A36F),Color(0xFF9BB9A0),Color(0xFFE0A36F),Color(0xFF9BB9A0),
  ];
  static const _glyphs = <String,String>{
    'sun':'☉','moon':'☽','mercury':'☿','venus':'♀','mars':'♂','jupiter':'♃',
    'saturn':'♄','uranus':'♅','neptune':'♆','pluto':'♇',
    'north_node_mean':'☊','north_node_true':'☊',
    'lilith_mean':'⚸','lilith_osculating':'⚸',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width/2,size.height/2);
    final radius = math.min(size.width,size.height)*.47;
    final rect = Rect.fromCircle(center:center,radius:radius);
    final bg = Paint()..shader = const RadialGradient(
      colors:[Color(0xFF233653),Color(0xFF111D31),Color(0xFF0B1424)],
      stops:[0,.72,1],
    ).createShader(rect);
    canvas.drawCircle(center,radius,bg);
    final ring = Paint()..color=const Color(0xFF806B4B)..style=PaintingStyle.stroke..strokeWidth=1;
    for(final r in [radius,radius*.88,radius*.66,radius*.34,radius*.16]) {
      canvas.drawCircle(center,r,ring);
    }
    if(chart != null && chart!.ascendantLongitudeDegrees != null) {
      _drawChart(canvas,center,radius,chart!);
    } else {
      _drawPlaceholder(canvas,center,radius);
    }
    canvas.drawCircle(center,radius*.155,Paint()..color=const Color(0xFF17263D));
    canvas.drawCircle(center,radius*.155,Paint()..color=_gold..style=PaintingStyle.stroke..strokeWidth=1.1);
    if(chart != null) _text(canvas,'✦',center,_gold,radius*.09);
  }

  void _drawChart(Canvas canvas,Offset c,double r,ChartCalculationResult data) {
    final asc=data.ascendantLongitudeDegrees!;
    double a(double longitude)=>math.pi+(longitude-asc)*math.pi/180;
    Offset p(double distance,double angle)=>c+Offset(math.cos(angle)*distance,math.sin(angle)*distance);

    // Zodiac ring: longitude is mapped with ASC at the left horizon.
    final ticks=Paint()..color=const Color(0xFFB9A27A)..strokeWidth=.7;
    for(var degree=0;degree<360;degree+=5) {
      final angle=a(degree.toDouble());
      canvas.drawLine(p(r*(degree % 30 == 0 ? .81 : .855),angle),p(r*.88,angle),ticks);
    }
    for(var sign=0;sign<12;sign++) {
      _text(canvas,_signs[sign],p(r*.745,a(sign*30.0+15)),_colors[sign],r*.105);
    }

    // Actual house cusps, never equal-house placeholders.
    if(data.houseCuspsDegrees.length==12) {
      final lines=Paint()..color=const Color(0xFF9A8769)..strokeWidth=.9;
      for(var i=0;i<12;i++) {
        final start=data.houseCuspsDegrees[i];
        final end=data.houseCuspsDegrees[(i+1)%12];
        final angle=a(start);
        canvas.drawLine(p(r*.34,angle),p(r*.66,angle),lines);
        final span=(end-start+360)%360;
        _text(canvas,(i+1).toString(),p(r*.49,a(start+span/2)),const Color(0xFFB8AA91),r*.052);
      }
    }

    // Aspect chords use only pairs explicitly calculated in the domain layer.
    _drawAspects(canvas,c,r,a,p,data);

    _axis(canvas,c,r,a,asc,'ASC');
    if(data.midheavenLongitudeDegrees!=null) {
      _axis(canvas,c,r,a,data.midheavenLongitudeDegrees!,'MC');
    }

    // Planet glyphs are placed at their actual ecliptic longitudes.
    // Nearby objects use alternating radial lanes to reduce label collisions.
    final bodies=[...data.positions]..sort((x,y)=>x.longitudeDegrees.compareTo(y.longitudeDegrees));
    var previous=-1000.0;
    var lane=0;
    for(final body in bodies) {
      if((body.longitudeDegrees-previous).abs()<9) {
        lane=(lane+1)%3;
      } else {
        lane=0;
      }
      previous=body.longitudeDegrees;
      final glyph=_glyphs[body.bodyId]??'?';
      final symbol=glyph+(body.isRetrograde?'℞':'');
      final angle=a(body.longitudeDegrees);
      _text(canvas,symbol,p(r*(.605-lane*.065),angle),const Color(0xFFF0D9A8),r*.09);
      _text(canvas,(body.longitudeDegrees%30).toStringAsFixed(0)+'°',
        p(r*.685,angle),const Color(0xFFD5CCBD),r*.037);
    }
  }

  void _drawAspects(
    Canvas canvas,
    Offset center,
    double radius,
    double Function(double) angleFor,
    Offset Function(double,double) point,
    ChartCalculationResult data,
  ) {
    if (data.aspects.isEmpty) return;
    final positions = {for (final body in data.positions) body.bodyId: body};
    for (final aspect in data.aspects) {
      final first = positions[aspect.firstBodyId];
      final second = positions[aspect.secondBodyId];
      if (first == null || second == null) continue;

      final color = switch (aspect.aspect) {
        MajorAspect.conjunction => const Color(0xFFB9A27A),
        MajorAspect.sextile => const Color(0xFF82B7A0),
        MajorAspect.square => const Color(0xFFD98575),
        MajorAspect.trine => const Color(0xFF78A9C8),
        MajorAspect.opposition => const Color(0xFFD98575),
      };
      final paint = Paint()
        ..color = color.withValues(alpha: .72)
        ..strokeWidth = 1.05
        ..style = PaintingStyle.stroke;
      final start = point(radius*.405, angleFor(first.longitudeDegrees));
      final end = point(radius*.405, angleFor(second.longitudeDegrees));
      canvas.drawLine(start,end,paint);
    }
  }

  void _axis(Canvas canvas,Offset c,double r,double Function(double) angleFor,double longitude,String label) {
    final angle=angleFor(longitude);
    final paint=Paint()..color=const Color(0xFFE5C98F)..strokeWidth=1.5;
    canvas.drawLine(c+Offset(math.cos(angle)*r*.29,math.sin(angle)*r*.29),
      c+Offset(math.cos(angle)*r*.68,math.sin(angle)*r*.68),paint);
    _text(canvas,label,c+Offset(math.cos(angle)*r*.73,math.sin(angle)*r*.73),
      const Color(0xFFE5C98F),r*.052);
  }

  void _drawPlaceholder(Canvas canvas,Offset c,double r) {
    final stars=Paint()..color=const Color(0x66E8D8B8);
    for(var i=0;i<54;i++) {
      final angle=i*2.399963;
      final distance=r*(.12+((i*37)%83)/100);
      canvas.drawCircle(c+Offset(math.cos(angle)*distance,math.sin(angle)*distance),i%7==0?1.25:.65,stars);
    }
    final spokes=Paint()..color=const Color(0xFF9A8769)..strokeWidth=.75;
    for(var i=0;i<12;i++) {
      final angle=-math.pi/2+i*math.pi/6;
      canvas.drawLine(c+Offset(math.cos(angle)*r*.34,math.sin(angle)*r*.34),
        c+Offset(math.cos(angle)*r,math.sin(angle)*r),spokes);
      _text(canvas,_signs[i],c+Offset(math.cos(angle+math.pi/12)*r*.77,math.sin(angle+math.pi/12)*r*.77),_colors[i],r*.105);
      _text(canvas,(i+1).toString(),c+Offset(math.cos(angle)*r*.48,math.sin(angle)*r*.48),const Color(0xFFB8AA91),r*.05);
    }
  }

  void _text(Canvas canvas,String value,Offset center,Color color,double fontSize) {
    final painter=TextPainter(
      text:TextSpan(text:value,style:TextStyle(color:color,fontSize:fontSize,fontWeight:FontWeight.w600)),
      textDirection:TextDirection.ltr,
    )..layout();
    painter.paint(canvas,center-Offset(painter.width/2,painter.height/2));
  }

  @override
  bool shouldRepaint(covariant _RadixPainter oldDelegate)=>oldDelegate.chart!=chart;
}
