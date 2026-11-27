import 'package:flutter/material.dart';

import '../widgets/radix_preview.dart';

class RadixScreen extends StatelessWidget {
  const RadixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D31),
        foregroundColor: const Color(0xFFF2E7D2),
        title: const Text('Dein Radix'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            const Text(
              'DEIN HIMMEL AUF EINEN BLICK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFC7A66A),
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: InteractiveViewer(
                minScale: .8,
                maxScale: 3.5,
                boundaryMargin: const EdgeInsets.all(90),
                child: const RadixPreview(size: 340),
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              color: Color(0xFF17263D),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'So liest du den Kreis',
                      style: TextStyle(
                        color: Color(0xFFE5C98F),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    _LegendLine(symbol: '♈ – ♓', text: 'Die zwölf Tierkreiszeichen liegen außen im Ring.'),
                    _LegendLine(symbol: '1 – 12', text: 'Die Zahlen markieren die zwölf astrologischen Häuser.'),
                    _LegendLine(symbol: '☉ ☽ ♀', text: 'Planeten erscheinen später an ihren berechneten Positionen.'),
                    _LegendLine(symbol: '—', text: 'Aspektlinien verbinden Planeten und zeigen ihre Winkelbeziehungen.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dies ist zunächst ein Gestaltungs-Prototyp. Es werden bewusst noch keine erfundenen Planetenpositionen oder Aspekte angezeigt. Die echten Positionen kommen erst aus der geprüften Berechnungs-Engine.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB8B0A2), height: 1.45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.symbol, required this.text});

  final String symbol;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(symbol, style: const TextStyle(color: Color(0xFFE5C98F), fontSize: 14)),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFFD5CCBD), height: 1.35)),
          ),
        ],
      ),
    );
  }
}
