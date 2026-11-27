# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** firetvstick2k2-afk/Horoskopium  
**Arbeitsbranch:** development  
**Status:** Flutter-Grundgerüst, UI-Prototyp, Domain-/Application-Schnittstellen und Hevelius-Adapter integriert; JPL-Datendatei und CI-Prüfung noch offen

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
- Neue Domain-Bausteine:
  - lib/domain/astrology/angle.dart: Winkel-Normalisierung und kleinster Winkelabstand.
  - chart_calculation_input.dart: UTC-Zeit, Koordinaten und Häusersystem als Berechnungseingabe.
  - celestial_position.dart: validierbares Positionsmodell.
  - chart_calculation_result.dart: Ergebnis inklusive Engine-ID und Version.
- Neue Application-Bausteine:
  - lib/application/ports/ephemeris_engine.dart: austauschbare Schnittstelle für die spätere Ephemeriden-Engine.
  - lib/application/use_cases/calculate_radix.dart: validiert Eingabe und Ergebnis.
- Test angelegt: test/domain/astrology/angle_test.dart.
- Hevelius-Abhängigkeit `hevelius_ephemeris: ^0.1.2` in `pubspec.yaml` eingetragen; Dart SDK-Untergrenze auf `>=3.13.7` angehoben.
- Adapter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart` implementiert `EphemerisEngine`, berechnet Sonne, Mond, Planeten bis Pluto, Mondknoten, Lilith sowie ASC/MC und Rückläufigkeit.
- `ChartCalculationResult` enthält optionale ASC-/MC-Längengrade.
- Der Adapter kann ein `Ephemeris`-Objekt übernehmen oder über `fromSpkFilePath` eine lokale JPL-SPK-Datei öffnen.
- **Wichtig:** Eine JPL-SPK-Datei ist noch nicht im Repository/App-Bundle enthalten und wird noch nicht automatisch bereitgestellt. Ohne diese Datei ist keine echte Planetenberechnung ausführbar. Keine erfundenen Positionen verwenden.
- GitHub Actions Workflow .github/workflows/flutter-ci.yml vorhanden: Android- und macOS/iOS-Jobs führen Analyze, Tests und Builds aus; Android Debug-APK wird als Artefakt hochgeladen, iOS wird ohne Codesignierung gebaut. Ein erfolgreicher Lauf muss noch separat verifiziert werden.

## 4a. Engine-Auswahl – Hevelius Ephemeris

Der Nutzer hat die Empfehlung bestätigt: **Hevelius Ephemeris ist die ausgewählte erste Engine**. Ephemera bleibt Rückfalloption.

Verwendeter Paketstand: `hevelius_ephemeris 0.1.2`, Apache-2.0, reines Dart ohne native Bibliotheken; laut Paketmetadaten Android/iOS-kompatibel. Der Adapter nutzt Sonne, Mond, Merkur bis Pluto, mittleren/wahren Mondknoten, mittlere/osculierende Lilith, Längengeschwindigkeiten, Aszendent und MC. Chiron und Asteroiden sind noch nicht angebunden, da dafür zusätzliche SPK-Daten/NAIF-Abdeckung nötig sein können. Das Paket dokumentiert Vergleiche mit JPL Horizons.

**Noch nicht integriert und vor Integration zu erledigen:**
- Die Paketversion 0.1.2 verlangt Dart SDK `^3.13.7`; die Projektuntergrenze ist jetzt `>=3.13.7`. CI muss noch bestätigen, dass die eingesetzte Flutter-Stable-Version dies erfüllt.
- Die freie API liefert Aszendent und MC, aber keine vollständigen Hausspitzen/Häusersysteme; Hevelius führt astrologische Häusersysteme als Pro-Funktion. Hausberechnung separat und lizenzkompatibel lösen und validieren.
- Die 22 mitgelieferten Fixsterne enthalten Hipparcos-Werte unter ESA CC BY-NC 3.0 IGO; kommerzielle Nutzungserlaubnis ist laut NOTICE noch offen. Diese Daten bis zur Klärung nicht in einer kommerziellen App verwenden.
- JPL-Dateien werden separat heruntergeladen: DE440s ca. 32 MB (1849–2150), DE442 ca. 115 MB (1550–2650). Offline-Verteilung, Speicherbedarf und Datenhinweise klären.
- Junges 0.1.x-Projekt: Tests, Performance und Vergleichsrechnungen auf Android/iOS vor produktiver Nutzung prüfen.
- Hevelius-Code und NOTICE-/Lizenzhinweise bei Auslieferung beachten.

Adapter liegt unter `lib/infrastructure/ephemeris/hevelius_ephemeris_engine.dart`. Kein UI-Code darf die Bibliothek direkt aufrufen. Bestehende `EphemerisEngine`-Schnittstelle bleibt die Grenze zur Bibliothek. `fromSpkFilePath` erwartet eine lokale, bereits auf dem Gerät verfügbare `.bsp`-Datei.

## 5. Nächste Schritte

1. JPL-DE440s/DE442-Datenquelle, Lizenz-/NOTICE-Bedingungen, Download und lokale Ablage für Android/iOS klären.
2. CI-Lauf prüfen; Dart SDK 3.13.7+, Analyze, Tests sowie Android-/iOS-Builds bestätigen und Fehler beheben.
3. Adapter mit JPL-Datei gegen dokumentierte Referenzfälle (z. B. Hevelius-Beispiel) testen.
4. Häuserspitzen/Häusersysteme separat spezifizieren und verlässlich implementieren.
5. Chiron und Asteroiden-Datenabdeckung klären und bei Bedarf ergänzen.
6. Historische Zeitzonen-/Sommerzeit-Auflösung und Geocoding/Koordinatenstrategie festlegen.
7. Topf Secret Quellcode zur TSL1-Prüfung lesen und die identische Dart-Prüfung planen.
8. Profil-Datenspeicherung um robuste Migration, Export/Import und angemessenen Schutz erweitern.
9. Radix-Berechnung, Häuser, Aspekte und Chart-Wheel datengetrieben vervollständigen.
10. Deutungsinhalte und PDF-Berichte auf Basis echter Berechnungsergebnisse ergänzen.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
