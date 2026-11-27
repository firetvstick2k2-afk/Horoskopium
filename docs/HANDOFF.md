# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Letzte Code-Commits:** `3fbe837`, `0249d1a`, `da1095d`  
**Letzter Test-Commit:** `51e86a9`  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter und erste Placidus-/Whole-Sign-Berechnung integriert. CI-Lauf 45946079434 ist vollständig erfolgreich: Android- und iOS-Analyze, Tests sowie Plattform-Builds bestanden. Die Placidus-Formeln für RA→ekliptikale Länge und RA→Deklination wurden korrigiert und unabhängig mit Swiss Ephemeris 2.10.03 verglichen. Zusätzliche Tests prüfen nun alle zwölf Hausspitzen in mehreren ARMC-/Breitenkonstellationen sowie knapp unter und exakt an der Polarkreisgrenze. CI für den jüngsten Test-Commit steht noch aus. JPL-Datendatei und vollständige fachliche Freigabe bleiben offen.

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
- ASC/DSC, MC/IC und gegenüberliegende Spitzen werden als Achsen behandelt; Koordinatentransformation berücksichtigt die Ekliptikschiefe. Die Umrechnung der Zwischenhaus-Rektaszensionen in ekliptikale Länge verwendet die inverse Beziehung `lambda = atan2(sin(RA), cos(RA) * cos(epsilon))`. Die Deklination aus RA wird korrekt über `delta = atan2(sin(epsilon) * sin(RA), cos(epsilon))` berechnet.
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
- Nach den Codekorrekturen liefen `45943315071` (Commit `232cae8`) und `45943318974` (Commit `f56ddc7`); beide wurden durch neuere Pushes abgebrochen. Lauf `45943344345` (Commit `7d1e016`) wurde abgeschlossen mit Failure: beide Plattformen scheiterten erneut bei `flutter analyze`; die sieben Meldungen waren ausschließlich Info-Diagnosen (vier deprecated_member_use für `package:flutter/material.dart`, drei prefer_const_constructors). Keine Errors oder Warnings wurden ausgegeben. Tests und Plattform-Builds wurden daher übersprungen.
- Verifizierte Ursache: Das aktuelle Flutter-Stable-`flutter analyze` behandelt Info-Level-Diagnosen standardmäßig als fatal. CI-Datei `.github/workflows/flutter-ci.yml` wurde in Commit `ad28a75bbba4ac3fc5aaf053608d90249c8844ee` geändert: beide Analyze-Schritte verwenden nun `flutter analyze --no-fatal-infos`. Fehler und Warnings bleiben fatal; Info-Hinweise bleiben sichtbar, blockieren aber nicht den Build.
- Lauf **45943723699** (Commit `040b336`) bestätigt: Android- und iOS-Analyze erfolgreich. Beide Jobs scheiterten im Schritt `flutter test` am selben Widget-Fehler: `A RenderFlex overflowed by 25 pixels on the bottom`, verursacht durch die Text-/Icon-Column in `RadixPreview` bei Constraints von 96 × 96 px (`lib/widgets/radix_preview.dart:20`). Sieben andere Tests bestanden, darunter vier Angle-/HouseCalculator-Tests. Android-APK und iOS-Build wurden wegen des Testfehlers übersprungen.
- Korrektur in Commit `b2fa38410f64f60198b4bb34209e5128dfb90e42`: Die Beschriftungs-Column in `RadixPreview` wird nur bei `size >= 150` gerendert. Bei der 96-px-Kachel auf dem Startbildschirm bleibt die Radix-Grafik ohne zu kleine Mittelbeschriftung erhalten.
- CI-Lauf **45944214217** (HEAD `c41f875` mit obiger RadixPreview-Korrektur) vollständig erfolgreich: Android Analyze, Tests, Debug-APK und Upload erfolgreich; iOS Analyze, Tests und unsigned Build erfolgreich.
- Unabhängige mathematische Prüfung fand zwei Fehler im bisherigen Placidus-Solver. Erstens war `_rightAscensionToLongitude` in die falsche Richtung transformiert: Korrekt ist `atan2(sin(RA), cos(RA) * cos(epsilon))`, abgeleitet aus `RA = atan2(sin(lambda) * cos(epsilon), cos(lambda))`. Zweitens war die Deklination aus RA fälschlich als `asin(sin(RA) * sin(epsilon))` berechnet. Korrekt ist `atan2(sin(epsilon) * sin(RA), cos(epsilon))`, entsprechend `tan(delta) = tan(epsilon) * sin(RA)`.
- Referenzabgleich mit Swiss Ephemeris 2.10.03 (`swe.houses_armc`, Placidus) und dem unabhängigen Quellcode `swehouse.c` (`Asc1`/`Asc2`): https://github.com/astrotools/SwissEphemeris/blob/master/swisseph/swehouse.c. Swiss Ephemeris wird ausschließlich als Referenz, nicht als Runtime-Abhängigkeit verwendet.
- Die vier Zwischenhausspitzen stimmen nach beiden Korrekturen in den geprüften Fällen auf < 1e-6° mit den unabhängigen Referenzwerten überein: ARMC 0°/Breite 0°/ε 23.4391667°; ARMC 340°/48.4° N; ARMC 150°/33.9° S; ARMC 20°/60° N. Für den Äquatorfall lauten die vier Werte 32.1812349°, 62.0894279°, 117.9105721° und 147.8187651°.
- Codekorrekturen: `3fbe837` (RA→Länge), `0249d1a` und `da1095d` (RA→Deklination und Zentralisierung). Regressionstests für Äquator, mittlere nördliche Breite, südliche Hemisphäre und 60° N in Commit `7512083`. **CI-Prüfung dieser letzten Änderungen steht noch aus.**
- Ältere Placidus-Korrektur-Commits: `4a212a7f3ce6d950b78a84ff986ba06d29b49caf` (Projektion/Polar-Fallback) und `3fd0b2f9806deb24c79f724b283dc6da29c889c5` (numerischer Äquator-Test).
- Erweiterte unabhängige Referenzprüfung mit Swiss Ephemeris 2.10.03 (swe.houses_armc, System Placidus): zusätzliche ARMC-/Breitenfälle 45°/20° N, 210°/50° S und 300°/55° N. In allen Fällen stimmen alle zwölf Hausspitzen einschließlich der Wrap-around-Werte 0°/360° bis auf numerische Rundung mit dem Referenzsystem überein.
- Polargrenzprüfung: Bei ε = 23.44° ist die Grenze 90° − ε = 66.56°. Der Fall 66.559° N (ARMC 45°) liefert noch gültige Placidus-Häuser und stimmt für alle zwölf Spitzen mit Swiss Ephemeris überein. Genau bei 66.56° greift der explizite Whole-Sign-Fallback.
- Diese zusätzlichen Regressionstests wurden in Commit `51e86a9` ergänzt. Der zugehörige CI-Lauf ist nach dem Push noch zu prüfen.
- **Placidus ist ausdrücklich NICHT fachlich freigegeben:** unabhängige vollständige Referenzvektoren (z. B. Swiss-Ephemeris-`swe_houses_armc`) und reale Radix-Stichproben fehlen. Swiss Ephemeris ist nur Vergleichsreferenz, keine Runtime-Abhängigkeit.
- Vor Freigabe mehrere Breitengrade (Äquator, mittlere und hohe Breiten, beide Hemisphären), mehrere ARMC-Werte, alle zwölf Spitzen, Achsen, Reihenfolge, Gegenüberliegende und Polargrenzfälle unabhängig vergleichen.

## 4b. Hevelius und JPL-Daten

- Hevelius 0.1.2 ist laut Paketmetadaten reines Dart und Apache-2.0; Android/iOS werden unterstützt.
- DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650). Datenbereitstellung, Rechte/Attribution, Offline-Installation und Speicherbedarf prüfen.
- Paket ist jung (0.1.x); Plattformtests und unabhängige Vergleiche sind Pflicht.
- Adapter kann lokale SPK-Datei öffnen; diese wird derzeit nicht mitgeliefert oder automatisch bereitgestellt.

## 5. Nächste Schritte

1. CI-Lauf nach dem erweiterten Test-Commit `51e86a9` vollständig prüfen. Sicherstellen, dass Analyze, Tests sowie Android-/iOS-Builds tatsächlich erfolgreich sind.
2. Placidus-Referenzprüfung weiter verbreitern: zusätzliche ARMC-Werte, beide Hemisphären, mehrere Jahreszeiten-/Obliquitätswerte und geometrische Reihenfolge/Abstände der Häuser prüfen.
3. Whole Sign gegen Referenzfälle testen.
4. JPL-DE440s/DE442-Datenquelle, Rechte, Download und lokale Android-/iOS-Ablage klären.
5. Hevelius mit echter SPK-Datei gegen dokumentierte Referenzfälle testen.
6. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie.
7. TSL1-Verifikation aus Topf Secret portieren; Generator nicht ändern.
8. Profile-Datenschutz, Export/Import und Migration verbessern.
9. Radix-Chart, Aspekte, Interpretationen und PDF datengetrieben vervollständigen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
