# Horoskopium – Handoff

**Stand:** 27.11.2026  
**Repository:** `firetvstick2k2-afk/Horoskopium`  
**Arbeitsbranch:** `development`  
**Status:** Projektgrundgerüst und erster UI-Prototyp

## 1. Verbindliche Arbeitsregeln

1. Ausschließlich auf `development` arbeiten.
2. `main` niemals verändern, außer der Nutzer sagt ausdrücklich: **„Bitte Main überschreiben“**.
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
- Die Darstellung soll nicht nur dekorativ sein: Nutzer sollen Zeichen, Häuser, Planeten und Aspekte nachvollziehen und selbst ablesen können. Geplant sind verständliche Legenden, Kurz-Erklärungen und antippbare Elemente mit Detailinformationen.
- Technische Präferenz: Chart möglichst als skalierbare Vektor-/CustomPaint-Darstellung statt als starres Bild umsetzen, damit Zoom und scharfe Darstellung bei verschiedenen Displaygrößen möglich sind.

## 3. Lizenzentscheidung – besonders wichtig

Der Nutzer hat ausdrücklich entschieden:

**Ein und derselbe Lizenzschlüssel soll sowohl Topf Secret als auch Horoskopium aktivieren.**

Daraus folgt:
- Vorhandener Licence-Studio-Generator bleibt unverändert.
- Vorhandener privater Hauptschlüssel bleibt unverändert.
- Vorhandenes TSL1-Tokenformat und ECDSA-P-256/SHA-256-Verfahren werden wiederverwendet.
- Horoskopium soll dieselben bestehenden Tokens akzeptieren, die Topf Secret akzeptiert.
- Derselbe Key soll auf Android und iOS funktionieren.
- In den Apps liegt ausschließlich der öffentliche Prüfschlüssel; niemals der private Hauptschlüssel.
- Kundenname/Bezeichnung kann frei sein (z. B. „Andre.Horoskopium“ oder „Andre Topf Secret“); sie ist nicht der kryptografische Produkttrenner.

**Wichtig für die Umsetzung:** Die bestehende Topf-Secret-Tokenprüfung muss aus dem aktuellen Quellcode übernommen werden. Keine neue Produktkennung verlangen, wenn dadurch alte Tokens nicht mehr funktionieren. Vor Implementierung die tatsächliche Payload-Prüfung und Signaturkodierung im Topf-Secret-Repository nachsehen und mit Testtokens prüfen. Keine Annahme als bereits umgesetzt darstellen.

## 4. Aktueller technischer Stand

- Flutter-Paketgrundlage und erster Startbildschirm mit klassischer Farbwelt angelegt.
- Geburtsprofile: Erstellen, Anzeigen und Löschen mit lokaler Speicherung via SharedPreferences implementiert.
- Erfasste Felder: Name, Geburtsdatum, optionale Geburtszeit (HH:MM) und optionaler Geburtsort.
- Die Profilangaben liegen lokal in App-Präferenzen; eine verschlüsselte Datenbank-/Backup-Lösung ist noch nicht umgesetzt.
- Radix-Visual-Prototyp: skalierbarer Tierkreis-/Häuserkreis mit Nachtblau-Sternenhintergrund, Goldlinien, Legenden und Zoom-/Verschiebefunktion angelegt.
- Der Radix-Prototyp zeigt bewusst keine erfundenen Planetenpositionen oder Aspekte. Die echte Chart-Geometrie wird später an die geprüfte Ephemeridenberechnung angeschlossen.
- Noch keine Ephemeridenberechnung, Lizenzaktivierung oder PDF-Erzeugung.
- Android-/iOS-Plattformrunner werden im CI-Workflow bei jedem Lauf reproduzierbar mit `flutter create . --project-name horoskopium --platforms=android,ios` erzeugt; sie müssen dafür noch nicht im Repository eingecheckt sein.
- GitHub Actions Workflow `.github/workflows/flutter-ci.yml` ergänzt: Android- und macOS/iOS-Jobs führen `flutter analyze`, `flutter test` und einen Build aus. Android Debug-APK wird als Artefakt hochgeladen; iOS wird ohne Codesignierung gebaut.
- Der Cloud-Workflow ist eingerichtet, aber ein erfolgreicher Lauf steht noch aus. iOS-Installation auf einem echten iPhone benötigt später Apple-Signierung und Verteilung (z. B. TestFlight).

## 5. Nächste Schritte

1. CI-Lauf prüfen und eventuelle Analyse-/Buildfehler beheben; danach Android-Testgerät und iPhone-Testverteilung vorbereiten.
2. Topf Secret Quellcode zur TSL1-Prüfung lesen und Horoskopium-kompatible Dart-Prüfung planen.
3. Lizenztest mit einem bestehenden, ausdrücklich bereitgestellten Testtoken; keine echten Kundentokens in GitHub einchecken.
4. Profil-Datenspeicherung später um robuste Migration, Export/Import und angemessenen Schutz erweitern.
5. Ephemeriden-Engine und deren Lizenzbedingungen prüfen (Swiss Ephemeris: AGPL bzw. kommerzielle Lizenz beachten).
6. Radix-Berechnung, Häuser, Aspekte und Chart-Wheel; den visuellen Prototyp datengetrieben vervollständigen.
7. Deutungsinhalte und PDF-Berichte.

## 6. Fachlicher Hinweis

Astrologische Deutungen sind symbolische/traditionelle Interpretationen und keine wissenschaftlich validierten Vorhersagen.
