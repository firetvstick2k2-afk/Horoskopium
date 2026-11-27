# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen, Hevelius-Adapter und erste eigenständige Häusersystem-Berechnung integriert; JPL-Datendatei und Build-/Referenzprüfung noch offen

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf development arbeiten.
2. main niemals verändern, außer der Nutzer sagt ausdrücklich: „Bitte Main überschreiben“.
3. Vor jeder Änderung bestehender Dateien aktuellen Inhalt und SHA von GitHub abrufen.
4. Änderungen sauber und nachvollziehbar committen.
5. Diese Handoff-Datei bei jedem relevanten Projektfortschritt aktualisieren.
6. Keine privaten Schlüssel, Passwörter oder Kundendaten committen.

## 2. Produktentscheidungen

- Projektname: **Horoskopium** (Arbeitstitel).
- Plattformen: Android und iOS von Anfang an.
- Technologie: Flutter / Dart, gemeinsame Codebasis.
- Gestaltung: klassisch, mit Pergament-, Nachtblau- und Goldtönen.
- Deutungen: maximal ausführlich und verständlich.
- Mehrere Geburtsprofile sollen möglich sein.
- Geplant sind Radix/Geburtshoroskop, Partnerschaft (Synastrie und Composit), Transite, Aspekte, Häuser, Planeten, Elemente, Modalitäten, Mondknoten, Chiron und Lilith.
- Umfangreiche Textdeutungen und exportierbarer PDF-Bericht.

## 2a. Radix-/Chart-Design und Bedienung

Der Nutzer hat das beigefügte Radix-Beispiel als visuelle Orientierung bestätigt (ähnliche Anmutung, keine pixelgenaue Kopie). Ziel ist eine professionelle, gut lesbare und interaktive Horoskop-Grafik:
- Großer, zentraler Radix-Kreis mit zwölf Tierkreiszeichen und zwölf Häusern.
- Planetensymbole und ihre exakten Positionen; ergänzende Liste der Positionen neben oder unter dem Kreis, abhängig von der Bildschirmgröße.
- Farbige Aspektlinien innerhalb des Kreises, visuell klar unterscheidbar und nicht überladen.
- Dunkler, edler Nachtblau-Hintergrund mit dezenten Sternen und zurückhaltenden goldenen Akzenten; Gesamtstil bleibt klassisch.
- Chart muss sich vergrößern lassen (Zoom) und auf Touch-Geräten gut bedienbar sein; zusätzlich sinnvolle responsive Darstellung für kleinere Displays.
- Verständliche Legenden, Kurz-Erklärungen und antippbare Elemente mit Detailinformationen.
- Technische Präferenz: skalierbare Vektor-/CustomPaint-Darstellung.

## 3. Lizenzentscheidung – besonders wichtig

**Ein und derselbe Lizenzschlüssel soll sowohl Topf Secret als auch Horoskopium aktivieren.**

- Vorhandener Licence-Studio-Generator bleibt unverändert.
- Vorhandener privater Hauptschlüssel bleibt unverändert.
- Vorhandenes TSL1-Tokenformat und ECDSA-P-256/SHA-256-Verfahren werden wiederverwendet.
- Horoskopium soll dieselben bestehenden Tokens akzeptieren, die Topf Secret akzeptiert.
- Derselbe Key soll auf Android und iOS funktionieren.
- In den Apps liegt ausschließlich der öffentliche Prüfschlüssel; niemals der private Hauptschlüssel.
- Kundenname/Bezeichnung kann frei sein; sie ist nicht der kryptografische Produkttrenner.
- Noch nicht implementiert: Die tatsächliche Topf-Secret-Tokenprüfung muss aus dessen aktuellem Quellcode übernommen und gegen Testtokens geprüft werden.

## 4. Aktueller technischer Stand

- Flutter-Grundlage und Startbildschirm mit klassischer Farbwelt vorhanden.
- Geburtsprofile: Erstellen, Anzeigen und Löschen mit lokaler Speicherung via SharedPreferences.
- Profilfelder: Name, Geburtsdatum, optionale Geburtszeit (HH:MM) und optionaler Geburtsort.
- Profilangaben liegen lokal in App-Präferenzen; eine verschlüsselte Datenbank-/Backup-Lösung ist noch nicht umgesetzt.
- Radix-Visual-Prototyp: skalierbarer Tierkreis-/Häuserkreis mit Nachtblau-Sternenhintergrund, Goldlinien, Legenden und Zoom-/Verschiebefunktion. Er zeigt bewusst keine erfundenen Planetenpositionen oder Aspekte.
- Domain-Bausteine:
  - `lib/domain/astrology/angle.dart`: Winkel-Normalisierung und Winkelabstand.
  - `chart_calculation_input.dart`: UTC-Zeit, Koordinaten und Häusersystem als Eingabe.
  - `celestial_position.dart`: validierbares Positionsmodell.
  - `chart_calculation_result.dart`: Ergebnis inklusive Positionen, Engine-ID/Version, ASC/MC und zwölf Hausspitzen.
  - `house_calculator.dart`: unabhängige reine Dart-Berechnung für Placidus und Whole Sign inklusive dokumentiertem Polarfallback.
- Application-Bausteine:
  - `lib/application/ports/ephemeris_engine.dart`: austauschbare Schnittstelle für die Ephemeriden-Engine.
  - `lib/application/use_cases/calculate_radix.dart`: validiert Eingabe und Ergebnis.
- Tests:
  - `test/domain/astrology/angle_test.dart`
  - `test/domain/astrology/house_calculator_test.dart`: Whole Sign, Placidus-Winkel/Antipoden, Polarfallback und ungültige Systeme.
- Hevelius-Abhängigkeit `hevelius_ephemeris: ^0.1.2` in `pubspec.yaml`; Dart SDK-Untergrenze `>=3.13.7`.
- Adapter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten, Lilith sowie ASC/MC.
- Der Adapter nutzt Hevelius-ARMC und wahre Ekliptikschiefe zum Geburtszeitpunkt, um die Hausspitzen mit dem Domain-Modul zu berechnen.
- Hausberechnungsergebnis speichert angefordertes und tatsächlich verwendetes System; Placidus wechselt bei mathematischer Polarkreisgrenze explizit auf Whole Sign.
- **Wichtig:** Eine JPL-SPK-Datei ist noch nicht im Repository/App-Bundle enthalten und wird noch nicht automatisch bereitgestellt. Ohne diese Datei ist keine echte Planetenberechnung ausführbar. Keine erfundenen Positionen verwenden.
- **Wichtig:** Die neue Hausberechnung ist implementiert, aber noch nicht durch unabhängige numerische Referenzvektoren oder reale Chart-Vergleiche fachlich freigegeben. Nicht als produktionsreif bezeichnen, bevor diese Tests bestanden sind.
- GitHub Actions Workflow `.github/workflows/flutter-ci.yml` vorhanden. Erfolgreiche Analyse, Tests und Android-/iOS-Builds müssen nach den letzten Commits noch verifiziert werden.

## 4a. Engine-Auswahl – Hevelius Ephemeris

Der Nutzer hat die Empfehlung bestätigt: **Hevelius Ephemeris ist die ausgewählte erste Engine**. Ephemera bleibt Rückfalloption.

Verwendeter Paketstand: `hevelius_ephemeris 0.1.2`, Apache-2.0, reines Dart ohne native Bibliotheken; laut Paketmetadaten Android/iOS-kompatibel. Der Adapter nutzt Sonne, Mond, Merkur bis Pluto, mittleren/wahren Mondknoten, mittlere/osculierende Lilith, Längengeschwindigkeiten, ASC/MC, ARMC und wahre Ekliptikschiefe. Chiron und Asteroiden sind noch nicht angebunden, da dafür zusätzliche SPK-Daten/NAIF-Abdeckung nötig sein können.

**Noch offen:**
- CI muss bestätigen, dass die eingesetzte Flutter-Stable-Version Dart SDK 3.13.7+ erfüllt.
- Die 22 mitgelieferten Fixsterne enthalten Hipparcos-Werte unter ESA CC BY-NC 3.0 IGO; kommerzielle Nutzungserlaubnis ist laut NOTICE noch offen. Diese Daten bis zur Klärung nicht in einer kommerziellen App verwenden.
- JPL-Dateien werden separat bereitgestellt: DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650). Offline-Verteilung, Speicherbedarf und Datenhinweise klären.
- Junges 0.1.x-Projekt: Tests, Performance und Vergleichsrechnungen auf Android/iOS vor produktiver Nutzung prüfen.
- Hevelius-Code und NOTICE-/Lizenzhinweise bei Auslieferung beachten.

## 4b. Häusersysteme

Eigenständige Implementierung in `lib/domain/astrology/house_calculator.dart`, ohne zusätzliche Abhängigkeit:

- **Placidus** ist voreingestellt. Die Zwischenhäuserspitzen werden über die Teilung der tag-/nachtseitigen Halbkreisbögen iterativ bestimmt.
- **Whole Sign** ist die Alternative. Haus 1 beginnt am Anfang des Zeichens, in dem der Aszendent steht.
- Placidus ist ab `|Breite| >= 90° - wahre Ekliptikschiefe` mathematisch nicht definiert. Dann wird explizit Whole Sign verwendet; `usedPolarHouseFallback` markiert das.
- Das Ergebnis enthält zwölf Hausspitzen, angefordertes System und effektives System.
- Unbekannte Systemnamen werden abgewiesen, nicht stillschweigend auf ein anderes System gemappt.
- Referenzgrundlagen zur fachlichen Prüfung: semi-arc definition / Placidus house cusp algorithms; unabhängige Vergleichsvektoren müssen noch ergänzt werden.
- Noch nicht fachlich freigegeben: Die Tests decken Struktur und grundlegende Geometrie ab, aber noch keine unabhängigen Swiss-Ephemeris-Referenzwerte.

## 5. Nächste Schritte

1. Hausberechnung gegen unabhängige Referenzfälle vergleichen und mögliche Iterations-/Quadrantenfehler beheben.
2. CI-Lauf prüfen; Dart SDK 3.13.7+, Analyze, Tests sowie Android-/iOS-Builds bestätigen.
3. JPL-DE440s/DE442-Datenquelle, Lizenz-/NOTICE-Bedingungen, Download und lokale Ablage für Android/iOS klären.
4. Adapter mit JPL-Datei gegen dokumentierte Hevelius-/JPL-Referenzfälle testen.
5. Chiron und Asteroiden-Datenabdeckung klären und bei Bedarf ergänzen.
6. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie festlegen.
7. Topf Secret Quellcode zur TSL1-Prüfung lesen und die identische Dart-Prüfung planen.
8. Profil-Datenspeicherung um robuste Migration, Export/Import und angemessenen Schutz erweitern.
9. Radix-Berechnung, Aspekte und Chart-Wheel datengetrieben vervollständigen.
10. Deutungsinhalte und PDF-Berichte auf Basis echter Berechnungsergebnisse ergänzen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
