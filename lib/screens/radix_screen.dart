import 'package:flutter/material.dart';

import '../domain/astrology/chart_calculation_result.dart';
import '../widgets/radix_preview.dart';

class RadixScreen extends StatelessWidget {
  const RadixScreen({super.key, this.result});

  final ChartCalculationResult? result;

  @override
  Widget build(BuildContext context) {
    final calculated = result != null;
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
                child: RadixPreview(size: 340, result: result),
              ),
            ),
            if (calculated) ...[
              const SizedBox(height: 12),
              Card(
                color: const Color(0xFF17263D),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berechnung erfolgreich',
                        style: TextStyle(
                          color: Color(0xFFE5C98F),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Engine: ' + result!.engineId + ' ' + result!.engineVersion,
                        style: const TextStyle(color: Color(0xFFD5CCBD)),
                      ),
                      if (result!.ascendantLongitudeDegrees != null)
                        _ValueLine(
                          label: 'Aszendent',
                          value: result!.ascendantLongitudeDegrees!.toStringAsFixed(2) + '°',
                        ),
                      if (result!.midheavenLongitudeDegrees != null)
                        _ValueLine(
                          label: 'Medium Coeli',
                          value: result!.midheavenLongitudeDegrees!.toStringAsFixed(2) + '°',
                        ),
                      const Divider(color: Color(0xFF526078), height: 22),
                      const Text(
                        'Berechnete Positionen',
                        style: TextStyle(
                          color: Color(0xFFE5C98F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final position in result!.positions)
                        _ValueLine(
                          label: position.bodyId,
                          value: position.longitudeDegrees.toStringAsFixed(2) + '°' +
                              (position.isRetrograde ? ' ℞' : ''),
                        ),
                      if (result!.houseCuspsDegrees.isNotEmpty) ...[
                        const Divider(color: Color(0xFF526078), height: 22),
                        Text(
                          'Häusersystem: ' + (result!.effectiveHouseSystem ?? 'unbekannt'),
                          style: const TextStyle(color: Color(0xFFD5CCBD)),
                        ),
                        for (var i = 0; i < result!.houseCuspsDegrees.length; i++)
                          _ValueLine(
                            label: 'Haus ' + (i + 1).toString(),
                            value: result!.houseCuspsDegrees[i].toStringAsFixed(2) + '°',
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                    _LegendLine(symbol: '☉ ☽ ♀', text: 'Die Symbole zeigen die berechneten Planetenpositionen im Tierkreis.'),
                    _LegendLine(symbol: '—', text: 'Aspektlinien folgen mit der geprüften Aspektberechnung.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              calculated
                  ? 'Die Radix-Grafik und Positionswerte stammen aus der aktiven Ephemeriden-Engine. Aspektlinien werden ergänzt, sobald die Aspektberechnung fachlich und technisch angebunden ist.'
                  : 'Dies ist zunächst ein Gestaltungs-Prototyp. Es werden bewusst noch keine erfundenen Planetenpositionen oder Aspekte angezeigt. Die echten Positionen kommen erst aus der geprüften Berechnungs-Engine.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFB8B0A2), height: 1.45, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueLine extends StatelessWidget {
  const _ValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Color(0xFFD5CCBD))),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE5C98F),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
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
