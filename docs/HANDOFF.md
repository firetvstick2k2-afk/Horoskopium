# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter und erste Placidus-/Whole-Sign-Berechnung integriert; CI-Korrekturen laufen, JPL-Datendatei und unabhängige Haus-Referenzfreigabe offen

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf development arbeiten.
2. main niemals verändern, außer der Nutzer sagt ausdrücklich: „Bitte Main überschreiben“.
3. Vor jeder Änderung bestehender Dateien aktuellen Inhalt und SHA von GitHub abrufen.
4. Änderungen sauber und nachvollziehbar committen.
5. Diese Handoff-Datei bei jedem relevanten Projektfortschritt aktualisieren.
6. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.

## 2. Produktentscheidungen

- Projektname: **Horoskopium** (Arbeitstitel).
- Plattformen: Android und iOS; gemeinsame Flutter-/Dart-Codebasis.
- Gestaltung: Pergament, Nachtblau und Gold; klassisch und gut lesbar.
- Ausführliche, verständliche Deutungen und mehrere Geburtsprofile.
- Geplant: Radix, Synastrie/Composit, Transite, Aspekte, Häuser, Planeten, Elemente, Modalitäten, Mondknoten, Chiron, Lilith und PDF-Bericht.

## 2a. Radix-/Chart-Design

- Großer zentraler Radix-Kreis mit zwölf Tierkreiszeichen und zwölf Häusern.
- Planetensymbole und exakte Positionen; ergänzende Positionsliste.
- Farbige, klar unterscheidbare Aspektlinien.
- Nachtblauer Hintergrund mit dezenten Sternen und goldenen Akzenten.
- Zoom, Verschieben, Touch-Bedienung, responsive Darstellung und antippbare Detailinformationen.
- Technische Präferenz: skalierbare Flutter-CustomPaint-Darstellung.

## 3. Lizenzentscheidung

**Ein und derselbe Lizenzschlüssel soll sowohl Topf Secret als auch Horoskopium aktivieren.**
- Licence-Studio-Generator und vorhandener privater Hauptschlüssel bleiben unverändert.
- Bestehendes TSL1-Tokenformat und ECDSA-P-256/SHA-256 werden wiederverwendet.
- In Apps liegt nur der öffentliche Prüfschlüssel.
- TSL1-Portierung aus Topf Secret ist noch nicht implementiert.

## 4. Aktueller technischer Stand

- Flutter-Grundlage, Startbildschirm, Profile und Radix-Visual-Prototyp vorhanden.
- Profile werden lokal mit SharedPreferences gespeichert; keine verschlüsselte Datenbank bisher.
- Domain-Modelle:
  - `angle.dart`, `celestial_position.dart`
  - `chart_calculation_input.dart`: UTC-Zeit, Koordinaten, Häusersystem
  - `chart_calculation_result.dart`: Positionen, Engine-Version, ASC/MC, zwölf Hausspitzen und System-/Fallback-Metadaten
  - `house_calculator.dart`: eigenständige Placidus-/Whole-Sign-Berechnung
- Application:
  - `EphemerisEngine` Port und `CalculateRadix` Use Case.
- Hevelius `hevelius_ephemeris: ^0.1.2`; Dart SDK-Untergrenze `>=3.13.7`.
- Adapter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten, Lilith, Rückläufigkeit, ASC/MC und übergibt ARMC/wahre Ekliptikschiefe an die Hausberechnung.
- **JPL-SPK-Datei fehlt noch:** Sie ist weder im Repository noch im App-Bundle und wird nicht automatisch bereitgestellt. Ohne lokale SPK-Datei gibt es keine echten Planetenpositionen.
- Chiron und Asteroiden sind noch nicht im Adapter eingebunden.
- Die Hevelius-Fixsternwerte mit ESA CC BY-NC 3.0 IGO sind bis zur Klärung kommerzieller Rechte nicht zu verwenden.

## 4a. Häusersysteme

Implementierung in `lib/domain/astrology/house_calculator.dart`, keine zusätzliche Abhängigkeit:
- **Placidus** ist Standard. Vier Zwischenhäuserspitzen werden iterativ anhand der Teilung der tag-/nachtseitigen Halbkreisbögen in Rektaszension bestimmt.
- **Whole Sign** ist Alternative; Haus 1 beginnt am Zeichenanfang des Aszendentenzeichens.
- ASC/DSC, MC/IC und gegenüberliegende Spitzen werden als Achsen behandelt; die Koordinatentransformation berücksichtigt die Ekliptikschiefe.
- Bei mathematischer Polarkreisgrenze oder nicht lösbarer/circumpolarer Zwischenhausspitze wird transparent auf Whole Sign zurückgefallen.
- Ergebnis speichert gewünschtes und effektives System plus `usedPolarHouseFallback`.
- Unbekannte Häusersysteme werden abgewiesen.

### Test- und Prüfstatus

- GitHub Actions Lauf für Commit `9bc4304` schlug bei `flutter analyze` fehl:
  - doppelter Initializer in `chart_calculation_result.dart`
  - fehlender/inkompatibler generierter Widget-Smoke-Test.
- Beide Punkte wurden korrigiert:
  - Chart-Ergebnis-Liste wird nur noch im Initializer initialisiert.
  - `test/widget_test.dart` wurde mit dem aktuellen `HoroskopiumApp`-Widget neu angelegt.
- Bei fachlicher Codeprüfung wurde außerdem die Umrechnung Rektaszension → ekliptikale Länge korrigiert und ein numerischer Äquator-Test für die Placidus-Semi-Arc-Geometrie ergänzt.
- Neueste Korrektur-Commits:
  - `857aa565a40ba6ad937c0473f61e542be1038ee8` – Chart-result initializer
  - `624668596ca567852ba5e4ffe58775f3b1b18364` – Widget smoke test
  - `4a212a7f3ce6d950b78a84ff986ba06d29b49caf` – Placidus projection and polar fallback
  - `3fd0b2f9806deb24c79f724b283dc6da29c889c5` – numeric Placidus test
- **Noch nicht freigegeben:** unabhängige vollständige Referenzvektoren (z. B. Swiss Ephemeris Tabellen/`swe_houses_armc`) und reale Radix-Stichproben fehlen. Swiss Ephemeris ist nur Vergleichsreferenz, keine Runtime-Abhängigkeit.
- CI nach den Korrekturen muss Analyze, Tests und Android-/iOS-Build erfolgreich abschließen. Keine erfolgreiche CI behaupten, solange der Lauf nicht abgeschlossen ist.

## 4b. Hevelius und JPL-Daten

- Hevelius 0.1.2 ist reines Dart und Apache-2.0; Android/iOS laut Paketmetadaten.
- DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650). Datenbereitstellung, Lizenz/Attribution, Offline-Installation und Speicherbedarf prüfen.
- Paket ist jung (0.1.x); Plattformtests und unabhängige Vergleiche sind Pflicht.

## 5. Nächste Schritte

1. Neueste GitHub Actions Läufe beobachten; Analyze-/Testfehler korrigieren.
2. Placidus gegen unabhängige Swiss-Ephemeris-Tabellenwerte und mehrere Breitengrade/ARMC-Werte validieren; Abweichungen dokumentieren.
3. Whole Sign gegen Referenzfälle testen.
4. JPL-DE440s/DE442-Datenquelle, Rechte, Download und lokale Android-/iOS-Ablage klären.
5. Hevelius mit echter SPK-Datei gegen dokumentierte Referenzfälle testen.
6. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie.
7. TSL1-Verifikation aus Topf Secret portieren; Generator nicht ändern.
8. Profile-Datenschutz, Export/Import und Migration verbessern.
9. Radix-Chart, Aspekte, Interpretationen und PDF datengetrieben vervollständigen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
