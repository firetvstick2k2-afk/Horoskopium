# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Aktueller HEAD bei Dokumentation:** f56ddc785e878a75c0bc840ddb14a7e6719d040c  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter und erste Placidus-/Whole-Sign-Berechnung integriert. CI-Fehler aus Lauf 45940062310 analysiert und Korrekturen committed; neue CI-Läufe laufen. JPL-Datendatei und unabhängige Haus-Referenzfreigabe weiterhin offen.

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf development arbeiten.
2. main niemals verändern, außer der Nutzer sagt ausdrücklich: „Bitte Main überschreiben“.
3. Vor jeder Änderung bestehender Dateien aktuellen Inhalt und SHA von GitHub abrufen.
4. Änderungen sauber und nachvollziehbar committen.
5. Diese Handoff-Datei bei jedem relevanten Projektfortschritt aktualisieren.
6. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.
7. Keine erfolgreichen Tests, Builds oder Hardwareprüfungen behaupten, wenn sie nicht tatsächlich erfolgreich abgeschlossen wurden.
8. Mathematische/astronomische Berechnungen mit unabhängigen Referenzwerten validieren.
9. Funktionierende Komponenten nicht unnötig umbauen; Unsicherheiten prüfen und dokumentieren.

## 2. Produktentscheidungen

- Projektname: **Horoskopium**.
- Plattformen: Android und iOS; gemeinsame Flutter-/Dart-Codebasis.
- Gestaltung: Pergament, Nachtblau und Gold; klassisch und gut lesbar.
- Geplant: Radix, Synastrie/Composite, Transite, Aspekte, Häuser, Planeten, Elemente, Modalitäten, Mondknoten, Chiron, Lilith und PDF-Bericht.
- Berechnung und astrologische Interpretation bleiben strikt getrennt.

## 2a. Radix-/Chart-Design

- Großer zentraler Radix-Kreis mit zwölf Tierkreiszeichen und zwölf Häusern.
- Planetensymbole und Positionen; ergänzende Positionsliste.
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
- Application: `EphemerisEngine` Port und `CalculateRadix` Use Case.
- Hevelius `hevelius_ephemeris: ^0.1.2`; Dart SDK-Untergrenze `>=3.13.7`.
- Adapter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten, Lilith, Rückläufigkeit, ASC/MC und übergibt ARMC/wahre Ekliptikschiefe an die Hausberechnung.
- **JPL-SPK-Datei fehlt:** Sie ist weder im Repository noch im App-Bundle und wird nicht automatisch bereitgestellt. Ohne lokale SPK-Datei gibt es keine echten Planetenpositionen.
- Chiron und Asteroiden sind noch nicht im Adapter eingebunden.
- Hevelius-Fixsternwerte mit ESA CC BY-NC 3.0 IGO bis zur Klärung kommerzieller Rechte nicht verwenden.

## 4a. Häusersysteme

Implementierung in `lib/domain/astrology/house_calculator.dart`, keine zusätzliche Abhängigkeit:
- **Placidus** ist Standard. Vier Zwischenhäuserspitzen werden iterativ anhand der Teilung der tag-/nachtseitigen Halbkreisbögen in Rektaszension bestimmt.
- **Whole Sign** ist Alternative; Haus 1 beginnt am Zeichenanfang des Aszendentenzeichens.
- ASC/DSC, MC/IC und gegenüberliegende Spitzen werden als Achsen behandelt; Koordinatentransformation berücksichtigt die Ekliptikschiefe.
- Bei mathematischer Polarkreisgrenze oder nicht lösbarer/circumpolarer Zwischenhausspitze wird transparent auf Whole Sign zurückgefallen.
- Ergebnis speichert gewünschtes und effektives System plus `usedPolarHouseFallback`.
- Unbekannte Häusersysteme werden abgewiesen.

### Test- und Prüfstatus

- Die zuvor in diesem Dokument als behoben bezeichnete doppelte Initialisierung in `chart_calculation_result.dart` war im tatsächlichen HEAD `7943fae` weiterhin vorhanden. Die Dokumentation war an dieser Stelle falsch.
- Lauf **45940062310** (Commit `7943fae`) ist fehlgeschlagen:
  - Android-Job `140313137736`: `flutter analyze` meldete `field_initialized_in_parameter_and_initializer` in `chart_calculation_result.dart:16`.
  - iOS-Job `140313137946`: derselbe Fehler.
  - Zusätzlich unbenutzter Material-Import in `test/widget_test.dart`.
  - Tests und Plattform-Builds wurden wegen des Analyze-Fehlers übersprungen.
- Korrekturen auf development:
  - Commit `232cae814c2413ba3f181de2493f7d3502d53702`: Konstruktorparameter von `required this.positions` auf `required List<CelestialPosition> positions` geändert; unveränderliche Kopie wird genau einmal im Initializer angelegt.
  - Commit `f56ddc785e878a75c0bc840ddb14a7e6719d040c`: unbenutzten `material.dart`-Import aus `test/widget_test.dart` entfernt.
- Nach diesen Commits wurden zwei CI-Läufe ausgelöst: `45943315071` (Commit `232cae8`) und `45943318974` (Commit `f56ddc7`). Beim letzten Statusabruf war der erste in Arbeit und der zweite pending. Ergebnis noch offen.
- Ältere Placidus-Korrektur-Commits: `4a212a7f3ce6d950b78a84ff986ba06d29b49caf` (Projektion/Polar-Fallback) und `3fd0b2f9806deb24c79f724b283dc6da29c889c5` (numerischer Äquator-Test).
- **Placidus ist ausdrücklich NICHT fachlich freigegeben:** unabhängige vollständige Referenzvektoren (z. B. Swiss-Ephemeris-`swe_houses_armc`) und reale Radix-Stichproben fehlen. Swiss Ephemeris ist nur Vergleichsreferenz, keine Runtime-Abhängigkeit.
- Vor Freigabe mehrere Breitengrade (Äquator, mittlere und hohe Breiten, beide Hemisphären), mehrere ARMC-Werte, alle zwölf Spitzen, Achsen, Reihenfolge, Gegenüberliegende und Polargrenzfälle unabhängig vergleichen.

## 4b. Hevelius und JPL-Daten

- Hevelius 0.1.2 ist laut Paketmetadaten reines Dart und Apache-2.0; Android/iOS werden unterstützt.
- DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650). Datenbereitstellung, Rechte/Attribution, Offline-Installation und Speicherbedarf prüfen.
- Paket ist jung (0.1.x); Plattformtests und unabhängige Vergleiche sind Pflicht.
- Adapter kann lokale SPK-Datei öffnen; diese wird derzeit nicht mitgeliefert oder automatisch bereitgestellt.

## 5. Nächste Schritte

1. CI-Läufe `45943315071` und `45943318974` vollständig prüfen; bei Fehlern Logs lesen und Ursache beheben. Nicht allein aufgrund des Analyze-Fixes Erfolg behaupten.
2. Placidus gegen unabhängige Referenzwerte und mehrere Breitengrade/ARMC-Werte validieren; Abweichungen dokumentieren.
3. Whole Sign gegen Referenzfälle testen.
4. JPL-DE440s/DE442-Datenquelle, Rechte, Download und lokale Android-/iOS-Ablage klären.
5. Hevelius mit echter SPK-Datei gegen dokumentierte Referenzfälle testen.
6. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie.
7. TSL1-Verifikation aus Topf Secret portieren; Generator nicht ändern.
8. Profile-Datenschutz, Export/Import und Migration verbessern.
9. Radix-Chart, Aspekte, Interpretationen und PDF datengetrieben vervollständigen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
